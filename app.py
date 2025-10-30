# =====================================================
# app.py — Panel de Administración MySQL (Procedimientos)
# =====================================================
from flask import Flask, render_template, request, jsonify
import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv
import os
from werkzeug.security import check_password_hash
import logging

# =====================================================
# 🧩 Configuración inicial
# =====================================================
load_dotenv()

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "127.0.0.1"),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME", "camaras_seguridad_db"),
    "port": int(os.getenv("DB_PORT", 3306))
}

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
app = Flask(__name__, static_folder="static", template_folder="templates")

# =====================================================
# 🔐 Clave de administrador
# =====================================================
ADMIN_PASSWORD_HASH = os.getenv("ADMIN_PASSWORD_HASH")
ADMIN_PASSWORD_PLAIN = os.getenv("ADMIN_PASSWORD", "admin123")

def validate_admin_password(password: str) -> bool:
    if not password:
        return False
    if ADMIN_PASSWORD_HASH:
        try:
            return check_password_hash(ADMIN_PASSWORD_HASH, password)
        except Exception:
            return False
    return password == ADMIN_PASSWORD_PLAIN

# =====================================================
# 🔌 Conexión
# =====================================================
def get_db_connection():
    try:
        return mysql.connector.connect(**DB_CONFIG)
    except Error as e:
        app.logger.error(f"❌ Error de conexión a la BD: {e}")
        return None

# =====================================================
# 🏠 Página principal
# =====================================================
@app.route('/')
def index():
    tablas = [
        "tipo_usuario", "usuarios", "sectores", "plazas", "camaras",
        "tipos_reportes", "tipos_eventos", "reportes", "reportes_plazas",
        "reportes_camaras", "accesos_usuarios", "eventos_camara"
    ]
    return render_template('index.html', tablas=tablas)

# =====================================================
# 🧭 Mapeo operaciones
# =====================================================
OPERATION_MAP = {
    "list": "leer",
    "get": "leer",         # decidiremos si es leer_por_id según payload
    "create": "insertar",
    "update": "actualizar",
    "delete": "eliminar",
    "leer": "leer",
    "insertar": "insertar",
    "actualizar": "actualizar",
    "eliminar": "eliminar",
}

# =====================================================
# 🧱 Especificación de parámetros por tabla/operación (orden exacto)
#    Solo estos se enviarán al CALL; los demás del payload se ignoran.
# =====================================================
PARAM_SPEC = {
    "tipo_usuario": {
        "leer": [],
        "leer_por_id": ["id_tipo_usuario"],
        "insertar": ["nombre", "descripcion"],
        "actualizar": ["id_tipo_usuario", "nombre", "descripcion"],
        "eliminar": ["id_tipo_usuario"],
    },
    "usuarios": {
        "leer": [],
        "leer_por_id": ["id_usuario"],
        "insertar": ["nombre_usuario", "contrasena_hash", "nombre_completo", "correo", "id_tipo_usuario", "telefono"],
        "actualizar": ["id_usuario", "nombre_usuario", "contrasena_hash", "nombre_completo", "correo", "id_tipo_usuario", "telefono"],
        "eliminar": ["id_usuario"],
    },
    "sectores": {
        "leer": [],
        "leer_por_id": ["id_sector"],
        "insertar": ["nombre", "descripcion"],
        "actualizar": ["id_sector", "nombre", "descripcion"],
        "eliminar": ["id_sector"],
    },
    "plazas": {
        "leer": [],
        "leer_por_id": ["id_plaza"],
        "insertar": ["nombre", "id_sector", "direccion", "latitud", "longitud"],
        "actualizar": ["id_plaza", "nombre", "id_sector", "direccion", "latitud", "longitud"],
        "eliminar": ["id_plaza"],
    },
    "camaras": {
        "leer": [],
        "leer_por_id": ["id_camara"],
        "insertar": ["id_plaza", "numero_serie", "modelo", "direccion_ip", "fecha_instalacion"],
        "actualizar": ["id_camara", "id_plaza", "numero_serie", "modelo", "direccion_ip", "fecha_instalacion"],
        "eliminar": ["id_camara"],
    },
    "tipos_reportes": {
        "leer": [],
        "leer_por_id": ["id_tipo_reporte"],
        "insertar": ["codigo", "nombre", "descripcion"],
        "actualizar": ["id_tipo_reporte", "codigo", "nombre", "descripcion"],
        "eliminar": ["id_tipo_reporte"],
    },
    "tipos_eventos": {
        "leer": [],
        "leer_por_id": ["id_tipo_evento"],
        "insertar": ["codigo", "nombre", "descripcion"],
        "actualizar": ["id_tipo_evento", "codigo", "nombre", "descripcion"],
        "eliminar": ["id_tipo_evento"],
    },
    "reportes": {
        "leer": [],
        "leer_por_id": ["id_reporte"],
        "insertar": ["id_tipo_reporte", "reportado_por", "descripcion_reporte", "fecha_hora_reporte", "nivel_gravedad"],
        "actualizar": ["id_reporte", "id_tipo_reporte", "reportado_por", "descripcion_reporte", "fecha_hora_reporte", "nivel_gravedad"],
        "eliminar": ["id_reporte"],
    },
    "reportes_plazas": {
        "leer": [],
        "leer_por_id": ["id_reporte", "id_plaza"],  # clave compuesta
        "insertar": ["id_reporte", "id_plaza", "especificacion"],
        "actualizar": ["id_reporte", "id_plaza", "especificacion"],
        "eliminar": ["id_reporte", "id_plaza"],
    },
    "reportes_camaras": {
        "leer": [],
        "leer_por_id": ["id_reporte", "id_camara"],  # clave compuesta
        "insertar": ["id_reporte", "id_camara", "especificacion"],
        "actualizar": ["id_reporte", "id_camara", "especificacion"],
        "eliminar": ["id_reporte", "id_camara"],
    },
    "accesos_usuarios": {
        "leer": [],
        "leer_por_id": ["id_acceso"],
        "insertar": ["id_usuario", "id_plaza", "otorgado_por", "fecha_otorgado", "revocado_por", "fecha_revocado", "activo"],
        "actualizar": ["id_acceso", "id_usuario", "id_plaza", "otorgado_por", "fecha_otorgado", "revocado_por", "fecha_revocado", "activo"],
        "eliminar": ["id_acceso"],
    },
    "eventos_camara": {
        "leer": [],
        "leer_por_id": ["id_evento"],
        "insertar": ["id_camara", "id_tipo_evento", "descripcion_evento", "fecha_hora_evento", "nivel_confianza"],
        "actualizar": ["id_evento", "id_camara", "id_tipo_evento", "descripcion_evento", "fecha_hora_evento", "nivel_confianza"],
        "eliminar": ["id_evento"],
    },
}

# =====================================================
# 🧪 Utilidades de normalización
# =====================================================
def empty_to_none(value):
    """Convierte cadenas vacías a None (para que lleguen como NULL a MySQL)."""
    if value is None:
        return None
    if isinstance(value, str) and value.strip() == "":
        return None
    return value

def build_params(table: str, op: str, payload: dict):
    """
    Construye la lista de parámetros en el orden exacto que espera el SP,
    tomando SOLO las claves definidas en PARAM_SPEC.
    Si falta alguno, usará None (cuando el SP/columna lo permita).
    """
    spec = PARAM_SPEC.get(table)
    if not spec:
        raise ValueError(f"Tabla '{table}' no soportada.")

    # Para 'leer': si el payload completa todas las llaves de 'leer_por_id', usaremos ese SP
    if op == "leer":
        id_spec = spec.get("leer_por_id", [])
        has_all_ids = len(id_spec) > 0 and all(payload.get(k) not in (None, "", []) for k in id_spec)
        if has_all_ids:
            return "leer_por_id", [empty_to_none(payload.get(k)) for k in id_spec]
        else:
            return "leer", []  # leer todo

    # Para otras operaciones: tomar el orden del spec
    op_spec = spec.get(op)
    if op_spec is None:
        raise ValueError(f"Operación '{op}' no soportada para tabla '{table}'.")

    params = [empty_to_none(payload.get(k)) for k in op_spec]
    return op, params

# =====================================================
# ⚙️ Endpoint principal
# =====================================================
@app.route('/procesar', methods=['POST'])
def procesar():
    data = request.get_json(silent=True)
    if data is None:
        return jsonify({"success": False, "message": "❌ Se esperaba JSON en el cuerpo de la petición."}), 400

    # Validación admin
    admin_password = data.get("admin_password", "")
    if not validate_admin_password(admin_password):
        return jsonify({"success": False, "message": "🔒 Clave de administrador incorrecta."}), 403

    # Inputs
    operation = data.get("operation") or data.get("operacion")
    table = (data.get("table") or data.get("tabla") or "").strip()
    payload = data.get("payload") or {}

    if not operation or not table:
        return jsonify({"success": False, "message": "⚠️ Debe indicarse 'operation' y 'table' en el JSON."}), 400

    op_mapped = OPERATION_MAP.get(operation.lower(), operation.lower())

    # Construir nombre base y parámetros correctos según spec
    try:
        chosen_op, params = build_params(table, op_mapped, payload)
    except ValueError as ve:
        return jsonify({"success": False, "message": str(ve)}), 400

    proc_name = f"sp_{table}_{chosen_op}"
    app.logger.info(f"📡 CALL {proc_name}({params})")

    # Conectar y ejecutar
    conn = get_db_connection()
    if conn is None:
        return jsonify({"success": False, "message": "❌ No se pudo conectar a la base de datos."}), 500

    cursor = None
    try:
        cursor = conn.cursor(dictionary=True)
        if params:
            cursor.callproc(proc_name, params)
        else:
            cursor.callproc(proc_name)

        # Confirmar si modifica
        if chosen_op in ["insertar", "actualizar", "eliminar"]:
            conn.commit()

        # Recoger resultados
        rows = []
        for result in cursor.stored_results():
            try:
                rows.extend(result.fetchall())
            except Exception:
                pass

        return jsonify({
            "success": True,
            "message": f"✅ Procedimiento '{proc_name}' ejecutado correctamente.",
            "procedure": proc_name,
            "params": params,
            "rows": rows
        }), 200

    except Error as e:
        app.logger.exception(f"❌ Error al ejecutar {proc_name}: {e}")
        return jsonify({"success": False, "message": f"Error en la ejecución: {str(e)}"}), 500

    finally:
        if cursor:
            cursor.close()
        conn.close()

# =====================================================
# ▶️ Arranque
# =====================================================
if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000, debug=True)
