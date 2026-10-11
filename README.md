# Vehicle Rental Management System

A complete DBMS mini project built with **HTML + CSS + JavaScript**, **Python Flask**, **MySQL**, and **mysql-connector-python**.

## Technology Stack

- Frontend: HTML5, CSS3, JavaScript
- Backend: Python Flask
- Database: MySQL 8.0+
- Connectivity: mysql-connector-python
- ER Model: draw.io / diagrams.net
- Version Control: Git + GitHub

## Features

- Admin/Staff login
- Dashboard with fleet, rental, customer and revenue statistics
- Vehicle CRUD
- Customer CRUD
- Rental creation and return
- Automatic rental rate calculation
- Payment records
- Vehicle maintenance records
- Search
- Rental reports
- MySQL joins, views, stored procedures, triggers, constraints, indexes and transactions
- Responsive professional frontend

## Project Structure

```text
Vehicle-Rental-Management-System/
├── app.py
├── config.py
├── requirements.txt
├── .env.example
├── README.md
├── database/
│   ├── schema.sql
│   ├── seed.sql
│   ├── views.sql
│   ├── triggers.sql
│   ├── procedures.sql
│   └── queries.sql
├── templates/
├── static/
│   ├── css/style.css
│   └── js/app.js
├── docs/
│   ├── vehicle_rental_er.drawio
│   ├── vehicle_rental_er.dot
│   └── vehicle_rental_er.png
└── report/
    └── Vehicle_Rental_Management_System_Report.pdf
```

## 1. Install prerequisites

Install:
- Python 3.10 or newer
- MySQL Server 8.0+
- MySQL Workbench (recommended)
- Git

## 2. Create the database

Open MySQL Workbench and run these scripts in this order:

1. `database/schema.sql`
2. `database/seed.sql`
3. `database/views.sql`
4. `database/triggers.sql`
5. `database/procedures.sql`

You can also run them from the MySQL command line.

## 3. Configure the application

Create a copy of `.env.example` as `.env`, or set the environment variables in your terminal.

Example for Windows PowerShell:

```powershell
$env:DB_HOST="127.0.0.1"
$env:DB_PORT="3306"
$env:DB_USER="root"
$env:DB_PASSWORD="YOUR_MYSQL_PASSWORD"
$env:DB_NAME="vehicle_rental_db"
$env:SECRET_KEY="change-this-secret"
```

The included `config.py` reads these variables.

## 4. Install Python packages

```bash
python -m venv venv
```

Windows:

```powershell
venv\Scripts\activate
```

macOS/Linux:

```bash
source venv/bin/activate
```

Then:

```bash
pip install -r requirements.txt
```

## 5. Run the application

```bash
python app.py
```

Open:

http://127.0.0.1:5000

## Demo accounts

```text
Admin
Username: admin
Password: admin123

Staff
Username: staff
Password: staff123
```

> These credentials are for the college/demo project only. For a production application, passwords should be hashed and authentication should be hardened.

## DBMS Concepts Demonstrated

### CRUD
- Create, update and delete vehicles
- Create, update and delete customers
- Create rentals
- Record maintenance

### Joins
The Flask reports use `INNER JOIN` and `LEFT JOIN` queries across customers, vehicles, categories and rentals.

### Views
- `vw_rental_details`
- `vw_revenue_summary`

### Stored Procedures
- `sp_create_rental`
- `sp_complete_rental`

### Triggers
- `trg_rental_before_insert`
- `trg_rental_after_insert`
- `trg_rental_after_update`

### Transactions
Creating a rental and its optional initial payment is performed in a single transaction. If either operation fails, the transaction is rolled back.

## ER Model

Open `docs/vehicle_rental_er.drawio` with diagrams.net. The PNG version is also included for the project report.

## GitHub

After testing:

```bash
git init
git add .
git commit -m "Initial Vehicle Rental Management System"
git branch -M main
git remote add origin YOUR_GITHUB_REPOSITORY_URL
git push -u origin main
```

## Suggested screenshots for submission

1. Login page
2. Dashboard
3. Vehicle list
4. Add/edit vehicle
5. Customer list
6. New rental
7. Rental history
8. Payment records
9. Maintenance page
10. Reports page
11. MySQL Workbench tables
12. ER diagram in draw.io

## Academic note

This project is designed as a DBMS mini project. The schema is normalized and uses primary keys, foreign keys, unique constraints, check constraints, indexes, joins, views, stored procedures, triggers and transactions.
