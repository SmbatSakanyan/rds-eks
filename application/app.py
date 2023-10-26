# app.py
from flask import Flask, render_template, request
import psycopg2
import os

app = Flask(__name__)

# Replace with your RDS PostgreSQL database credentials
db_credentials = {
    'dbname': 'postgres',
    'user': 'pestgres',
    'password': os.environ["POSTGRES_PASSWORD"],
    'host': 'dtabase1.ck5guhjqmy3m.us-east-2.rds.amazonaws.com',
    'port': '5432'  # Default PostgreSQL port
}

@app.route('/')
def index():
    try:
        connection = psycopg2.connect(**db_credentials)
        cursor = connection.cursor()
        cursor.execute("SELECT * FROM users")
        data = cursor.fetchall()
        connection.close()
        return render_template('index.html', data=data)
    except Exception as e:
        return str(e)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)