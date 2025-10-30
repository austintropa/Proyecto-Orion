# test_conn.py
from dotenv import load_dotenv
import os
import mysql.connector
from mysql.connector import Error

load_dotenv()  # si usas .env
cfg = {
    "host": os.getenv("DB_HOST", "127.0.0.1"),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME", ""),
    "port": int(os.getenv("DB_PORT", 3306))
}

print("Probando conexión con:", {k: ("****" if k=="password" else v) for k,v in cfg.items()})
try:
    conn = mysql.connector.connect(**cfg)
    print("Conectado:", conn.is_connected())
    conn.close()
except Error as e:
    print("FALLO de conexión:", type(e).__name__, str(e))
