from datetime import date
from functools import wraps
from flask import Flask, render_template, request, redirect, url_for, session, flash, jsonify
import mysql.connector
from mysql.connector import Error
from config import Config

app = Flask(__name__)
app.config.from_object(Config)

def get_db():
    return mysql.connector.connect(
        host=app.config["DB_HOST"], port=app.config["DB_PORT"],
        user=app.config["DB_USER"], password=app.config["DB_PASSWORD"],
        database=app.config["DB_NAME"], autocommit=False
    )

def query_db(sql, params=None, fetchone=False, commit=False):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        cur.execute(sql, params or ())
        result = cur.fetchone() if fetchone else cur.fetchall()
        if commit: conn.commit()
        return result
    finally:
        cur.close(); conn.close()

def login_required(view):
    @wraps(view)
    def wrapped(*args, **kwargs):
        if "user_id" not in session: return redirect(url_for("login"))
        return view(*args, **kwargs)
    return wrapped

@app.context_processor
def inject_globals():
    return {"today": date.today().isoformat(), "current_user": session.get("full_name")}

@app.route("/")
def index():
    return redirect(url_for("dashboard" if "user_id" in session else "login"))

@app.route("/login", methods=["GET","POST"])
def login():
    if request.method == "POST":
        user = query_db(
            "SELECT * FROM users WHERE username=%s AND password=%s",
            (request.form["username"].strip(), request.form["password"]),
            fetchone=True
        )
        if user:
            session.update(user_id=user["user_id"], full_name=user["full_name"], role=user["role"])
            return redirect(url_for("dashboard"))
        flash("Invalid username or password.", "danger")
    return render_template("login.html")

@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))

@app.route("/dashboard")
@login_required
def dashboard():
    stats = {
        "vehicles": query_db("SELECT COUNT(*) c FROM vehicles", fetchone=True)["c"],
        "available": query_db("SELECT COUNT(*) c FROM vehicles WHERE status='Available'", fetchone=True)["c"],
        "rentals": query_db("SELECT COUNT(*) c FROM rentals WHERE rental_status IN ('Booked','Active')", fetchone=True)["c"],
        "customers": query_db("SELECT COUNT(*) c FROM customers", fetchone=True)["c"],
        "revenue": query_db("SELECT COALESCE(SUM(amount),0) total FROM payments WHERE payment_status='Paid'", fetchone=True)["total"],
    }
    recent = query_db("""
        SELECT r.rental_id,c.full_name customer_name, CONCAT(v.brand,' ',v.model) vehicle_name,
               r.rental_date,r.rental_status,r.total_amount
        FROM rentals r JOIN customers c ON c.customer_id=r.customer_id
        JOIN vehicles v ON v.vehicle_id=r.vehicle_id
        ORDER BY r.created_at DESC LIMIT 8
    """)
    return render_template("dashboard.html", stats=stats, recent=recent)

@app.route("/vehicles")
@login_required
def vehicles():
    q=request.args.get("q","").strip()
    rows=query_db("""SELECT v.*,vc.category_name,vc.daily_rate
        FROM vehicles v JOIN vehicle_categories vc ON vc.category_id=v.category_id
        WHERE v.vehicle_number LIKE %s OR v.brand LIKE %s OR v.model LIKE %s
        ORDER BY v.vehicle_id DESC""",(f"%{q}%",f"%{q}%",f"%{q}%"))
    return render_template("vehicles.html", vehicles=rows, q=q)

@app.route("/vehicles/add",methods=["GET","POST"])
@login_required
def add_vehicle():
    categories=query_db("SELECT * FROM vehicle_categories ORDER BY category_name")
    if request.method=="POST":
        try:
            query_db("""INSERT INTO vehicles
                (category_id,vehicle_number,brand,model,manufacture_year,color,fuel_type,transmission,seating_capacity,status)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                (request.form["category_id"],request.form["vehicle_number"].upper(),request.form["brand"],
                 request.form["model"],request.form.get("manufacture_year") or None,request.form["color"],
                 request.form["fuel_type"],request.form["transmission"],request.form["seating_capacity"],request.form["status"]),commit=True)
            flash("Vehicle added successfully.","success"); return redirect(url_for("vehicles"))
        except Error as e: flash(f"Could not add vehicle: {e.msg}","danger")
    return render_template("vehicle_form.html",vehicle=None,categories=categories,title="Add Vehicle")

@app.route("/vehicles/edit/<int:vehicle_id>",methods=["GET","POST"])
@login_required
def edit_vehicle(vehicle_id):
    vehicle=query_db("SELECT * FROM vehicles WHERE vehicle_id=%s",(vehicle_id,),fetchone=True)
    if not vehicle: return "Vehicle not found",404
    categories=query_db("SELECT * FROM vehicle_categories ORDER BY category_name")
    if request.method=="POST":
        try:
            query_db("""UPDATE vehicles SET category_id=%s,vehicle_number=%s,brand=%s,model=%s,
                manufacture_year=%s,color=%s,fuel_type=%s,transmission=%s,seating_capacity=%s,status=%s
                WHERE vehicle_id=%s""",
                (request.form["category_id"],request.form["vehicle_number"].upper(),request.form["brand"],
                 request.form["model"],request.form.get("manufacture_year") or None,request.form["color"],
                 request.form["fuel_type"],request.form["transmission"],request.form["seating_capacity"],
                 request.form["status"],vehicle_id),commit=True)
            flash("Vehicle updated successfully.","success"); return redirect(url_for("vehicles"))
        except Error as e: flash(f"Update failed: {e.msg}","danger")
    return render_template("vehicle_form.html",vehicle=vehicle,categories=categories,title="Edit Vehicle")

@app.post("/vehicles/delete/<int:vehicle_id>")
@login_required
def delete_vehicle(vehicle_id):
    try:
        query_db("DELETE FROM vehicles WHERE vehicle_id=%s",(vehicle_id,),commit=True)
        flash("Vehicle deleted.","success")
    except Error:
        flash("Cannot delete this vehicle because it is referenced by rental/maintenance records.","danger")
    return redirect(url_for("vehicles"))

@app.route("/customers")
@login_required
def customers():
    q=request.args.get("q","").strip()
    rows=query_db("""SELECT * FROM customers
        WHERE full_name LIKE %s OR email LIKE %s OR phone LIKE %s OR driving_license_no LIKE %s
        ORDER BY customer_id DESC""",(f"%{q}%",)*4)
    return render_template("customers.html",customers=rows,q=q)

@app.route("/customers/add",methods=["GET","POST"])
@login_required
def add_customer():
    if request.method=="POST":
        try:
            query_db("""INSERT INTO customers(full_name,email,phone,address,driving_license_no)
                VALUES(%s,%s,%s,%s,%s)""",
                (request.form["full_name"],request.form["email"],request.form["phone"],
                 request.form["address"],request.form["driving_license_no"].upper()),commit=True)
            flash("Customer added.","success"); return redirect(url_for("customers"))
        except Error as e: flash(f"Could not add customer: {e.msg}","danger")
    return render_template("customer_form.html",customer=None,title="Add Customer")

@app.route("/customers/edit/<int:customer_id>",methods=["GET","POST"])
@login_required
def edit_customer(customer_id):
    customer=query_db("SELECT * FROM customers WHERE customer_id=%s",(customer_id,),fetchone=True)
    if not customer:return "Customer not found",404
    if request.method=="POST":
        try:
            query_db("""UPDATE customers SET full_name=%s,email=%s,phone=%s,address=%s,driving_license_no=%s
                WHERE customer_id=%s""",
                (request.form["full_name"],request.form["email"],request.form["phone"],
                 request.form["address"],request.form["driving_license_no"].upper(),customer_id),commit=True)
            flash("Customer updated.","success"); return redirect(url_for("customers"))
        except Error as e: flash(f"Update failed: {e.msg}","danger")
    return render_template("customer_form.html",customer=customer,title="Edit Customer")

@app.post("/customers/delete/<int:customer_id>")
@login_required
def delete_customer(customer_id):
    try:
        query_db("DELETE FROM customers WHERE customer_id=%s",(customer_id,),commit=True)
        flash("Customer deleted.","success")
    except Error: flash("Cannot delete a customer with rental history.","danger")
    return redirect(url_for("customers"))

@app.route("/rentals")
@login_required
def rentals():
    rows=query_db("""SELECT r.*,c.full_name customer_name,c.phone,CONCAT(v.brand,' ',v.model) vehicle_name,v.vehicle_number
        FROM rentals r JOIN customers c ON c.customer_id=r.customer_id
        JOIN vehicles v ON v.vehicle_id=r.vehicle_id ORDER BY r.rental_id DESC""")
    return render_template("rentals.html",rentals=rows)

@app.route("/rentals/add",methods=["GET","POST"])
@login_required
def add_rental():
    customers=query_db("SELECT customer_id,full_name FROM customers ORDER BY full_name")
    vehicles=query_db("""SELECT v.vehicle_id,v.vehicle_number,v.brand,v.model,vc.category_name,vc.daily_rate
        FROM vehicles v JOIN vehicle_categories vc ON vc.category_id=v.category_id
        WHERE v.status='Available' ORDER BY v.vehicle_number""")
    if request.method=="POST":
        conn=get_db(); cur=conn.cursor()
        try:
            cur.callproc("sp_create_rental",(
                int(request.form["customer_id"]),int(request.form["vehicle_id"]),
                request.form["rental_date"],request.form["expected_return_date"],
                request.form["notes"],0
            ))
            cur.execute("SELECT LAST_INSERT_ID()")
            rental_id=cur.fetchone()[0]
            if request.form.get("payment_amount"):
                cur.execute("""INSERT INTO payments(rental_id,amount,payment_method,payment_status,transaction_reference)
                    VALUES(%s,%s,%s,'Paid',%s)""",
                    (rental_id,request.form["payment_amount"],request.form["payment_method"],
                     request.form.get("transaction_reference") or None))
            conn.commit()
            flash(f"Rental #{rental_id} created successfully.","success")
            return redirect(url_for("rentals"))
        except Error as e:
            conn.rollback(); flash(f"Rental transaction failed: {e.msg}","danger")
        finally: cur.close(); conn.close()
    return render_template("rental_form.html",customers=customers,vehicles=vehicles)

@app.post("/rentals/return/<int:rental_id>")
@login_required
def return_rental(rental_id):
    conn=get_db(); cur=conn.cursor()
    try:
        cur.callproc("sp_complete_rental",(rental_id,request.form.get("actual_return_date") or date.today().isoformat()))
        conn.commit(); flash("Vehicle returned and rental completed.","success")
    except Error as e:
        conn.rollback(); flash(f"Return failed: {e.msg}","danger")
    finally: cur.close(); conn.close()
    return redirect(url_for("rentals"))

@app.route("/payments")
@login_required
def payments():
    rows=query_db("""SELECT p.*,r.rental_id,c.full_name customer_name,CONCAT(v.brand,' ',v.model) vehicle_name
        FROM payments p JOIN rentals r ON r.rental_id=p.rental_id
        JOIN customers c ON c.customer_id=r.customer_id
        JOIN vehicles v ON v.vehicle_id=r.vehicle_id ORDER BY p.payment_id DESC""")
    return render_template("payments.html",payments=rows)

@app.route("/maintenance")
@login_required
def maintenance():
    rows=query_db("""SELECT m.*,v.vehicle_number,CONCAT(v.brand,' ',v.model) vehicle_name
        FROM maintenance m JOIN vehicles v ON v.vehicle_id=m.vehicle_id ORDER BY m.maintenance_id DESC""")
    vehicles=query_db("SELECT vehicle_id,vehicle_number,brand,model FROM vehicles ORDER BY vehicle_number")
    return render_template("maintenance.html",maintenance=rows,vehicles=vehicles)

@app.post("/maintenance/add")
@login_required
def add_maintenance():
    conn=get_db();cur=conn.cursor()
    try:
        cur.execute("""INSERT INTO maintenance(vehicle_id,service_date,description,cost,maintenance_status,next_service_date)
            VALUES(%s,%s,%s,%s,%s,%s)""",
            (request.form["vehicle_id"],request.form["service_date"],request.form["description"],
             request.form["cost"],request.form["maintenance_status"],request.form.get("next_service_date") or None))
        if request.form["maintenance_status"]!="Completed":
            cur.execute("UPDATE vehicles SET status='Maintenance' WHERE vehicle_id=%s",(request.form["vehicle_id"],))
        conn.commit(); flash("Maintenance record added.","success")
    except Error as e:
        conn.rollback(); flash(f"Could not save maintenance: {e.msg}","danger")
    finally: cur.close();conn.close()
    return redirect(url_for("maintenance"))

@app.route("/reports")
@login_required
def reports():
    rental_details=query_db("SELECT * FROM vw_rental_details ORDER BY rental_id DESC")
    revenue=query_db("SELECT * FROM vw_revenue_summary ORDER BY revenue_month DESC")
    vehicle_usage=query_db("""SELECT v.vehicle_number,CONCAT(v.brand,' ',v.model) vehicle,
        COUNT(r.rental_id) rental_count,COALESCE(SUM(r.total_amount),0) rental_value
        FROM vehicles v LEFT JOIN rentals r ON r.vehicle_id=v.vehicle_id
        GROUP BY v.vehicle_id ORDER BY rental_count DESC""")
    return render_template("reports.html",rental_details=rental_details,revenue=revenue,vehicle_usage=vehicle_usage)

@app.get("/api/vehicle/<int:vehicle_id>")
@login_required
def vehicle_api(vehicle_id):
    row=query_db("""SELECT v.*,vc.daily_rate,vc.category_name FROM vehicles v
        JOIN vehicle_categories vc ON vc.category_id=v.category_id WHERE v.vehicle_id=%s""",(vehicle_id,),fetchone=True)
    return jsonify(row or {})

if __name__=="__main__":
    app.run(debug=True,host="127.0.0.1",port=5000)
