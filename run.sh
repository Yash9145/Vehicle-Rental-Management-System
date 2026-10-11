#!/bin/sh
python3 -m venv venv 2>/dev/null || true
. venv/bin/activate
pip install -r requirements.txt
python app.py
