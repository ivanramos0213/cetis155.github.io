from flask import Flask, render_template, request, redirect, url_for, session, jsonify, flash
import mysql.connector
import re
import random
import string

app = Flask(__name__)
app.secret_key = 'clave_super_secreta_cetis155'

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '',
    'database': 'medi_db'
}

def obtener_conexion():
    return mysql.connector.connect(**DB_CONFIG)

# Funciones de validación
def validar_nombre(nombre):
    """Valida que el nombre tenga al menos 3 caracteres y solo letras, números y espacios"""
    if len(nombre) < 3:
        return False, "El nombre debe tener al menos 3 caracteres"
    if len(nombre) > 100:
        return False, "El nombre no puede exceder 100 caracteres"
    if not re.match(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s]+$', nombre):
        return False, "El nombre solo puede contener letras, números y espacios"
    return True, ""

def validar_correo(correo):
    """Valida que el correo tenga un formato válido"""
    patron = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    if not re.match(patron, correo):
        return False, "El formato del correo electrónico no es válido"
    if len(correo) > 100:
        return False, "El correo no puede exceder 100 caracteres"
    return True, ""

def validar_password(password):
    """Valida que la contraseña tenga al menos 3 caracteres"""
    if len(password) < 3:
        return False, "La contraseña debe tener al menos 3 caracteres"
    if len(password) > 100:
        return False, "La contraseña no puede exceder 100 caracteres"
    return True, ""

def generar_codigo_clase():
    """Genera un código único de 6 caracteres para una clase"""
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))

# ============================================
# RUTAS PRINCIPALES
# ============================================

@app.route('/')
def index():
    return render_template('index.html')

# ============================================
# AUTENTICACIÓN
# ============================================

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        usuario = request.form['usuario'].strip()
        password = request.form['password']
        correo = request.form['correo'].strip().lower()
        nombre_completo = request.form['nombre_completo'].strip()
        telefono = request.form.get('telefono', '').strip()
        rol = request.form.get('rol', 'alumno')  # alumno o profesor

        # Validaciones
        valido, mensaje = validar_nombre(usuario)
        if not valido:
            return render_template('register.html', error=mensaje)

        valido, mensaje = validar_correo(correo)
        if not valido:
            return render_template('register.html', error=mensaje)

        valido, mensaje = validar_password(password)
        if not valido:
            return render_template('register.html', error=mensaje)

        conexion = obtener_conexion()
        cursor = conexion.cursor(dictionary=True)

        # Verificar si el usuario ya existe
        cursor.execute('SELECT id FROM usuarios WHERE usuario = %s', (usuario,))
        if cursor.fetchone():
            cursor.close()
            conexion.close()
            return render_template('register.html', error='El nombre de usuario ya está registrado')

        # Verificar si el correo ya existe
        cursor.execute('SELECT id FROM usuarios WHERE correo = %s', (correo,))
        if cursor.fetchone():
            cursor.close()
            conexion.close()
            return render_template('register.html', error='El correo electrónico ya está registrado')

        try:
            cursor.execute('''INSERT INTO usuarios (usuario, password, correo, telefono, rol, nombre_completo)
                           VALUES (%s, %s, %s, %s, %s, %s)''',
                           (usuario, password, correo, telefono, rol, nombre_completo))
            conexion.commit()
            cursor.close()
            conexion.close()
            return render_template('login.html', success='Registro exitoso. Por favor inicia sesión.')
        except Exception as e:
            conexion.rollback()
            cursor.close()
            conexion.close()
            return render_template('register.html', error=f'Error al registrar usuario: {str(e)}')

    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        usuario = request.form['usuario'].strip()
        password = request.form['password']

        if not usuario or not password:
            return render_template('login.html', error='Por favor ingresa usuario y contraseña')

        # Verificar credenciales de admin
        if usuario == 'admin' and password == 'admin':
            session['usuario'] = 'admin'
            session['rol'] = 'admin'
            session['user_id'] = 1
            return redirect(url_for('admin_panel'))

        conexion = obtener_conexion()
        cursor = conexion.cursor(dictionary=True)
        cursor.execute('SELECT * FROM usuarios WHERE usuario=%s', (usuario,))
        user = cursor.fetchone()
        cursor.close()
        conexion.close()

        if user and user['password'] == password:
            session['usuario'] = user['usuario']
            session['rol'] = user['rol']
            session['user_id'] = user['id']

            if user['rol'] == 'admin':
                return redirect(url_for('admin_panel'))
            elif user['rol'] == 'profesor':
                return redirect(url_for('profesor_dashboard'))
            else:
                return redirect(url_for('alumno_dashboard'))
        else:
            return render_template('login.html', error='Usuario o contraseña incorrectos')

    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('index'))

# ============================================
# DASHBOARD ALUMNO
# ============================================

@app.route('/alumno/dashboard')
def alumno_dashboard():
    if 'usuario' not in session or session['rol'] != 'alumno':
        return redirect(url_for('login'))

    conexion = obtener_conexion()
    cursor = conexion.cursor(dictionary=True)

    # Obtener clases del alumno
    cursor.execute('''
        SELECT c.*, u.nombre_completo as profesor_nombre
        FROM clases c
        JOIN alumnos_clases ac ON c.id = ac.clase_id
        JOIN usuarios u ON c.profesor_id = u.id
        WHERE ac.alumno_id = %s
        ORDER BY c.nombre
    ''', (session['user_id'],))
    clases = cursor.fetchall()

    # Obtener tareas pendientes
    cursor.execute('''
        SELECT t.*, c.nombre as clase_nombre,
               e.id as entrega_id, e.calificacion
        FROM tareas t
        JOIN clases c ON t.clase_id = c.id
        JOIN alumnos_clases ac ON c.id = ac.clase_id
        LEFT JOIN entregas e ON t.id = e.tarea_id AND e.alumno_id = %s
        WHERE ac.alumno_id = %s
        ORDER BY t.fecha_entrega ASC
    ''', (session['user_id'], session['user_id']))
    tareas = cursor.fetchall()

    cursor.close()
    conexion.close()

    return render_template('alumno_dashboard.html', clases=clases, tareas=tareas)

@app.route('/alumno/unirse', methods=['POST'])
def unirse_clase():
    if 'usuario' not in session or session['rol'] != 'alumno':
        return redirect(url_for('login'))

    codigo = request.form['codigo'].strip().upper()

    conexion = obtener_conexion()
    cursor = conexion.cursor(dictionary=True)

    # Buscar la clase por código
    cursor.execute('SELECT id FROM clases WHERE codigo = %s', (codigo,))
    clase = cursor.fetchone()

    if not clase:
        cursor.close()
        conexion.close()
        return jsonify({'error': 'Código de clase no válido'}), 400

    try:
        cursor.execute('INSERT INTO alumnos_clases (alumno_id, clase_id) VALUES (%s, %s)',
                      (session['user_id'], clase['id']))
        conexion.commit()
        cursor.close()
        conexion.close()
        return redirect(url_for('alumno_dashboard'))
    except mysql.connector.IntegrityError:
        cursor.close()
        conexion.close()
        return jsonify({'error': 'Ya estás inscrito en esta clase'}), 400

@app.route('/alumno/clase/<int:clase_id>')
def ver_clase_alumno(clase_id):
    if 'usuario' not in session or session['rol'] != 'alumno':
        return redirect(url_for('login'))

    conexion = obtener_conexion()
    cursor = conexion.cursor(dictionary=True)

    # Verificar que el alumno está inscrito
    cursor.execute('''
        SELECT c.*, u.nombre_completo as profesor_nombre, u.correo as profesor_correo
        FROM clases c
        JOIN usuarios u ON c.profesor_id = u.id
        JOIN alumnos_clases ac ON c.id = ac.clase_id
        WHERE c.id = %s AND ac.alumno_id = %s
    ''', (clase_id, session['user_id']))
    clase = cursor.fetchone()

    if not clase:
        cursor.close()
        conexion.close()
        return redirect(url_for('alumno_dashboard'))

    # Obtener tareas de la clase
    cursor.execute('''
        SELECT t.*, e.id as entrega_id, e.calificacion, e.comentarios, e.fecha_entrega as fecha_enviada
        FROM tareas t
        LEFT JOIN entregas e ON t.id = e.tarea_id AND e.alumno_id = %s
        WHERE t.clase_id = %s
        ORDER BY t.fecha_entrega ASC
    ''', (session['user_id'], clase_id))
    tareas = cursor.fetchall()

    cursor.close()
    conexion.close()

    return render_template('clase_alumno.html', clase=clase, tareas=tareas)

@app.route('/alumno/tarea/<int:tarea_id>/entregar', methods=['GET', 'POST'])
def entregar_tarea(tarea_id):
    if 'usuario' not in session or session['rol'] != 'alumno':
        return redirect(url_for('login'))

    if request.method == 'POST':
        contenido = request.form['contenido']

        conexion = obtener_conexion()
        cursor = conexion.cursor()

        try:
            cursor.execute('''
                INSERT INTO entregas (tarea_id, alumno_id, contenido)
                VALUES (%s, %s, %s)
                ON DUPLICATE KEY UPDATE contenido = %s, fecha_entrega = NOW()
            ''', (tarea_id, session['user_id'], contenido, contenido))
            conexion.commit()
            cursor.close()
            conexion.close()
            return redirect(url_for('alumno_dashboard'))
        except Exception as e:
            cursor.close()
            conexion.close()
            return jsonify({'error': str(e)}), 400

    # GET - mostrar formulario
    conexion = obtener_conexion()
    cursor = conexion.cursor(dictionary=True)

    cursor.execute('''
        SELECT t.*, c.nombre as clase_nombre, e.contenido as contenido_anterior
        FROM tareas t
        JOIN clases c ON t.clase_id = c.id
        LEFT JOIN entregas e ON t.id = e.tarea_id AND e.alumno_id = %s
        WHERE t.id = %s
    ''', (session['user_id'], tarea_id))
    tarea = cursor.fetchone()

    cursor.close()
    conexion.close()

    if not tarea:
        return redirect(url_for('alumno_dashboard'))

    return render_template('entregar_tarea.html', tarea=tarea)

# ============================================
# DASHBOARD PROFESOR
# ============================================

@app.route('/profesor/dashboard')
def profesor_dashboard():
    if 'usuario' not in session or session['rol'] != 'profesor':
        return redirect(url_for('login'))

    conexion = obtener_conexion()
    cursor = conexion.cursor(dictionary=True)

    # Obtener clases del profesor
    cursor.execute('''
        SELECT c.*, COUNT(DISTINCT ac.alumno_id) as num_alumnos
        FROM clases c
        LEFT JOIN alumnos_clases ac ON c.id = ac.clase_id
        WHERE c.profesor_id = %s
        GROUP BY c.id
        ORDER BY c.nombre
    ''', (session['user_id'],))
    clases = cursor.fetchall()

    cursor.close()
    conexion.close()

    return render_template('profesor_dashboard.html', clases=clases)

@app.route('/profesor/clase/crear', methods=['POST'])
def crear_clase():
    if 'usuario' not in session or session['rol'] != 'profesor':
        return redirect(url_for('login'))

    nombre = request.form['nombre'].strip()
    descripcion = request.form['descripcion'].strip()

    conexion = obtener_conexion()
    cursor = conexion.cursor()

    # Generar código único
    while True:
        codigo = generar_codigo_clase()
        cursor.execute('SELECT id FROM clases WHERE codigo = %s', (codigo,))
        if not cursor.fetchone():
            break

    try:
        cursor.execute('''
            INSERT INTO clases (nombre, descripcion, codigo, profesor_id)
            VALUES (%s, %s, %s, %s)
        ''', (nombre, descripcion, codigo, session['user_id']))
        conexion.commit()
        cursor.close()
        conexion.close()
        return redirect(url_for('profesor_dashboard'))
    except Exception as e:
        cursor.close()
        conexion.close()
        return jsonify({'error': str(e)}), 400

@app.route('/profesor/clase/<int:clase_id>')
def ver_clase_profesor(clase_id):
    if 'usuario' not in session or session['rol'] != 'profesor':
        return redirect(url_for('login'))

    conexion = obtener_conexion()
    cursor = conexion.cursor(dictionary=True)

    # Verificar que la clase pertenece al profesor
    cursor.execute('SELECT * FROM clases WHERE id = %s AND profesor_id = %s', (clase_id, session['user_id']))
    clase = cursor.fetchone()

    if not clase:
        cursor.close()
        conexion.close()
        return redirect(url_for('profesor_dashboard'))

    # Obtener alumnos inscritos
    cursor.execute('''
        SELECT u.id, u.nombre_completo, u.correo, ac.fecha_inscripcion
        FROM usuarios u
        JOIN alumnos_clases ac ON u.id = ac.alumno_id
        WHERE ac.clase_id = %s
        ORDER BY u.nombre_completo
    ''', (clase_id,))
    alumnos = cursor.fetchall()

    # Obtener tareas de la clase
    cursor.execute('''
        SELECT t.*, COUNT(e.id) as entregas_count
        FROM tareas t
        LEFT JOIN entregas e ON t.id = e.tarea_id
        WHERE t.clase_id = %s
        GROUP BY t.id
        ORDER BY t.fecha_entrega DESC
    ''', (clase_id,))
    tareas = cursor.fetchall()

    cursor.close()
    conexion.close()

    return render_template('clase_profesor.html', clase=clase, alumnos=alumnos, tareas=tareas)


# MOSTRAR FORMULARIO DE EDICIÓN
# ----------------------------------------------------
@app.route('/editar/<int:id>')
def editar_usuario(id):
    conexion = obtener_conexion()
    cursor = conexion.cursor(dictionary=True)

    cursor.execute("SELECT * FROM usuarios WHERE id = %s", (id,))
    usuario = cursor.fetchone()
    cursor.close()
    conexion.close()

    if not usuario:
        flash("Usuario no encontrado", "warning")
        return redirect(url_for('admin_usuarios'))

    # 👇 Aquí cambiamos la plantilla por la correcta
    return render_template('editar_usuarios.html', usuario=usuario)


# ----------------------------------------------------
# ACTUALIZAR REGISTRO
# ----------------------------------------------------
@app.route('/actualizar/<int:id>', methods=['POST'])
def actualizar_usuario(id):
    usuario_form = request.form.get('usuario', None)
    password_form = request.form.get('password', None)
    correo_form = request.form.get('correo', None)
    telefono_form = request.form.get('telefono', None)

    conexion = obtener_conexion()
    cursor = conexion.cursor(dictionary=True)

    # verificar existencia y obtener actuales
    cursor.execute("SELECT * FROM usuarios WHERE id = %s", (id,))
    actual = cursor.fetchone()
    if not actual:
        cursor.close()
        conexion.close()
        flash("Usuario no encontrado", "warning")
        return redirect(url_for('admin_usuarios'))

    campos = []
    params = []
    if usuario_form is not None and usuario_form.strip() != '':
        campos.append('usuario = %s')
        params.append(usuario_form.strip())
    if password_form is not None and password_form.strip() != '':
        campos.append('password = %s')
        params.append(password_form)
    if correo_form is not None and correo_form.strip() != '':
        campos.append('correo = %s')
        params.append(correo_form.strip().lower())
    if telefono_form is not None and telefono_form.strip() != '':
        campos.append('telefono = %s')
        params.append(telefono_form.strip())

    if not campos:
        cursor.close()
        conexion.close()
        flash("No hay cambios para aplicar", "info")
        return redirect(url_for('admin_usuarios'))

    sql = "UPDATE usuarios SET " + ", ".join(campos) + " WHERE id = %s"
    params.append(id)

    try:
        cursor.execute(sql, tuple(params))
        conexion.commit()
        flash("Usuario actualizado correctamente", "success")
    except Exception as e:
        conexion.rollback()
        flash(f"Error al actualizar usuario: {e}", "danger")
    finally:
        cursor.close()
        conexion.close()

    return redirect(url_for('admin_usuarios'))

@app.route('/profesor/clase/<int:clase_id>/tarea/crear', methods=['POST'])
def crear_tarea(clase_id):
    if 'usuario' not in session or session['rol'] != 'profesor':
        return redirect(url_for('login'))

    titulo = request.form['titulo'].strip()
    descripcion = request.form['descripcion'].strip()
    fecha_entrega = request.form['fecha_entrega']
    puntos = request.form.get('puntos', 100)

    conexion = obtener_conexion()
    cursor = conexion.cursor()

    try:
        cursor.execute('''
            INSERT INTO tareas (clase_id, titulo, descripcion, fecha_entrega, puntos)
            VALUES (%s, %s, %s, %s, %s)
        ''', (clase_id, titulo, descripcion, fecha_entrega, puntos))
        conexion.commit()
        cursor.close()
        conexion.close()
        return redirect(url_for('ver_clase_profesor', clase_id=clase_id))
    except Exception as e:
        cursor.close()
        conexion.close()
        return jsonify({'error': str(e)}), 400

@app.route('/profesor/tarea/<int:tarea_id>')
def ver_entregas(tarea_id):
    if 'usuario' not in session or session['rol'] != 'profesor':
        return redirect(url_for('login'))

    conexion = obtener_conexion()
    cursor = conexion.cursor(dictionary=True)

    # Obtener tarea y verificar que pertenece al profesor
    cursor.execute('''
        SELECT t.*, c.nombre as clase_nombre, c.profesor_id
        FROM tareas t
        JOIN clases c ON t.clase_id = c.id
        WHERE t.id = %s
    ''', (tarea_id,))
    tarea = cursor.fetchone()

    if not tarea or tarea['profesor_id'] != session['user_id']:
        cursor.close()
        conexion.close()
        return redirect(url_for('profesor_dashboard'))

    # Obtener entregas
    cursor.execute('''
        SELECT e.*, u.nombre_completo, u.correo
        FROM entregas e
        JOIN usuarios u ON e.alumno_id = u.id
        WHERE e.tarea_id = %s
        ORDER BY e.fecha_entrega DESC
    ''', (tarea_id,))
    entregas = cursor.fetchall()

    cursor.close()
    conexion.close()

    return render_template('ver_entregas.html', tarea=tarea, entregas=entregas)

@app.route('/profesor/entrega/<int:entrega_id>/calificar', methods=['POST'])
def calificar_entrega(entrega_id):
    if 'usuario' not in session or session['rol'] != 'profesor':
        return redirect(url_for('login'))

    calificacion = request.form['calificacion']
    comentarios = request.form.get('comentarios', '')

    conexion = obtener_conexion()
    cursor = conexion.cursor()

    cursor.execute('''
        UPDATE entregas
        SET calificacion = %s, comentarios = %s
        WHERE id = %s
    ''', (calificacion, comentarios, entrega_id))
    conexion.commit()

    cursor.close()
    conexion.close()

    return redirect(request.referrer)

# ============================================
# PANEL DE ADMINISTRACIÓN
# ============================================

@app.route('/admin/panel')
def admin_panel():
    if 'usuario' not in session or session['rol'] != 'admin':
        return redirect(url_for('login'))

    conexion = obtener_conexion()
    cursor = conexion.cursor(dictionary=True)

    # Obtener estadísticas
    cursor.execute('SELECT COUNT(*) as total FROM usuarios WHERE rol = "alumno"')
    total_alumnos = cursor.fetchone()['total']

    cursor.execute('SELECT COUNT(*) as total FROM usuarios WHERE rol = "profesor"')
    total_profesores = cursor.fetchone()['total']

    cursor.execute('SELECT COUNT(*) as total FROM clases')
    total_clases = cursor.fetchone()['total']

    cursor.execute('SELECT COUNT(*) as total FROM tareas')
    total_tareas = cursor.fetchone()['total']

    cursor.close()
    conexion.close()

    return render_template('admin_panel.html',
                         total_alumnos=total_alumnos,
                         total_profesores=total_profesores,
                         total_clases=total_clases,
                         total_tareas=total_tareas)

@app.route('/admin/usuarios')
def admin_usuarios():
    if 'usuario' not in session or session['rol'] != 'admin':
        return redirect(url_for('login'))

    conexion = obtener_conexion()
    cursor = conexion.cursor(dictionary=True)

    cursor.execute('SELECT * FROM usuarios ORDER BY fecha_registro DESC')
    usuarios = cursor.fetchall()

    cursor.close()
    conexion.close()

    return render_template('admin_usuarios.html', usuarios=usuarios)

@app.route('/admin/usuario/crear', methods=['POST'])
def admin_crear_usuario():
    if 'usuario' not in session or session['rol'] != 'admin':
        return jsonify({'error': 'No autorizado'}), 403

    data = request.json
    conexion = obtener_conexion()
    cursor = conexion.cursor()

    try:
        cursor.execute('''
            INSERT INTO usuarios (usuario, password, correo, telefono, rol, nombre_completo)
            VALUES (%s, %s, %s, %s, %s, %s)
        ''', (data['usuario'], data['password'], data['correo'], data.get('telefono', ''),
              data['rol'], data['nombre_completo']))
        conexion.commit()
        cursor.close()
        conexion.close()
        return jsonify({'success': True})
    except Exception as e:
        cursor.close()
        conexion.close()
        return jsonify({'error': str(e)}), 400

@app.route('/admin/usuario/<int:user_id>/editar', methods=['POST'])
def admin_editar_usuario(user_id):
    if 'usuario' not in session or session['rol'] != 'admin':
        return jsonify({'error': 'No autorizado'}), 403

    data = request.json
    conexion = obtener_conexion()
    cursor = conexion.cursor()

    try:
        if 'password' in data and data['password']:
            cursor.execute('''
                UPDATE usuarios
                SET usuario=%s, password=%s, correo=%s, telefono=%s, rol=%s, nombre_completo=%s
                WHERE id=%s
            ''', (data['usuario'], data['password'], data['correo'], data.get('telefono', ''),
                  data['rol'], data['nombre_completo'], user_id))
        else:
            cursor.execute('''
                UPDATE usuarios
                SET usuario=%s, correo=%s, telefono=%s, rol=%s, nombre_completo=%s
                WHERE id=%s
            ''', (data['usuario'], data['correo'], data.get('telefono', ''),
                  data['rol'], data['nombre_completo'], user_id))
        conexion.commit()
        cursor.close()
        conexion.close()
        return jsonify({'success': True})
    except Exception as e:
        cursor.close()
        conexion.close()
        return jsonify({'error': str(e)}), 400

@app.route('/admin/usuario/<int:user_id>/eliminar', methods=['POST'])
def admin_eliminar_usuario(user_id):
    if 'usuario' not in session or session['rol'] != 'admin':
        return jsonify({'error': 'No autorizado'}), 403

    conexion = obtener_conexion()
    cursor = conexion.cursor()

    try:
        cursor.execute('DELETE FROM usuarios WHERE id = %s', (user_id,))
        conexion.commit()
        cursor.close()
        conexion.close()
        return jsonify({'success': True})
    except Exception as e:
        cursor.close()
        conexion.close()
        return jsonify({'error': str(e)}), 400

@app.route('/admin/clases')
def admin_clases():
    if 'usuario' not in session or session['rol'] != 'admin':
        return redirect(url_for('login'))

    conexion = obtener_conexion()
    cursor = conexion.cursor(dictionary=True)

    cursor.execute('''
        SELECT c.*, u.nombre_completo as profesor_nombre,
               COUNT(DISTINCT ac.alumno_id) as num_alumnos
        FROM clases c
        JOIN usuarios u ON c.profesor_id = u.id
        LEFT JOIN alumnos_clases ac ON c.id = ac.clase_id
        GROUP BY c.id
        ORDER BY c.fecha_creacion DESC
    ''')
    clases = cursor.fetchall()

    cursor.execute('SELECT id, nombre_completo FROM usuarios WHERE rol = "profesor" ORDER BY nombre_completo')
    profesores = cursor.fetchall()

    cursor.close()
    conexion.close()

    return render_template('admin_clases.html', clases=clases, profesores=profesores)

@app.route('/admin/clase/crear', methods=['POST'])
def admin_crear_clase():
    if 'usuario' not in session or session['rol'] != 'admin':
        return jsonify({'error': 'No autorizado'}), 403

    data = request.json
    conexion = obtener_conexion()
    cursor = conexion.cursor()

    # Generar código único
    while True:
        codigo = generar_codigo_clase()
        cursor.execute('SELECT id FROM clases WHERE codigo = %s', (codigo,))
        if not cursor.fetchone():
            break

    try:
        cursor.execute('''
            INSERT INTO clases (nombre, descripcion, codigo, profesor_id)
            VALUES (%s, %s, %s, %s)
        ''', (data['nombre'], data['descripcion'], codigo, data['profesor_id']))
        conexion.commit()
        cursor.close()
        conexion.close()
        return jsonify({'success': True, 'codigo': codigo})
    except Exception as e:
        cursor.close()
        conexion.close()
        return jsonify({'error': str(e)}), 400

@app.route('/admin/clase/<int:clase_id>/editar', methods=['POST'])
def admin_editar_clase(clase_id):
    if 'usuario' not in session or session['rol'] != 'admin':
        return jsonify({'error': 'No autorizado'}), 403

    data = request.json
    conexion = obtener_conexion()
    cursor = conexion.cursor()

    try:
        cursor.execute('''
            UPDATE clases
            SET nombre=%s, descripcion=%s, profesor_id=%s
            WHERE id=%s
        ''', (data['nombre'], data['descripcion'], data['profesor_id'], clase_id))
        conexion.commit()
        cursor.close()
        conexion.close()
        return jsonify({'success': True})
    except Exception as e:
        cursor.close()
        conexion.close()
        return jsonify({'error': str(e)}), 400

@app.route('/admin/clase/<int:clase_id>/eliminar', methods=['POST'])
def admin_eliminar_clase(clase_id):
    if 'usuario' not in session or session['rol'] != 'admin':
        return jsonify({'error': 'No autorizado'}), 403

    conexion = obtener_conexion()
    cursor = conexion.cursor()

    try:
        cursor.execute('DELETE FROM clases WHERE id = %s', (clase_id,))
        conexion.commit()
        cursor.close()
        conexion.close()
        return jsonify({'success': True})
    except Exception as e:
        cursor.close()
        conexion.close()
        return jsonify({'error': str(e)}), 400

@app.route('/admin/tareas')
def admin_tareas():
    if 'usuario' not in session or session['rol'] != 'admin':
        return redirect(url_for('login'))

    conexion = obtener_conexion()
    cursor = conexion.cursor(dictionary=True)

    cursor.execute('''
        SELECT t.*, c.nombre as clase_nombre, u.nombre_completo as profesor_nombre,
               COUNT(e.id) as num_entregas
        FROM tareas t
        JOIN clases c ON t.clase_id = c.id
        JOIN usuarios u ON c.profesor_id = u.id
        LEFT JOIN entregas e ON t.id = e.tarea_id
        GROUP BY t.id
        ORDER BY t.fecha_creacion DESC
    ''')
    tareas = cursor.fetchall()

    cursor.execute('SELECT id, nombre FROM clases ORDER BY nombre')
    clases = cursor.fetchall()

    cursor.close()
    conexion.close()

    return render_template('admin_tareas.html', tareas=tareas, clases=clases)

@app.route('/admin/tarea/crear', methods=['POST'])
def admin_crear_tarea():
    if 'usuario' not in session or session['rol'] != 'admin':
        return jsonify({'error': 'No autorizado'}), 403

    data = request.json
    conexion = obtener_conexion()
    cursor = conexion.cursor()

    try:
        cursor.execute('''
            INSERT INTO tareas (clase_id, titulo, descripcion, fecha_entrega, puntos)
            VALUES (%s, %s, %s, %s, %s)
        ''', (data['clase_id'], data['titulo'], data['descripcion'],
              data['fecha_entrega'], data['puntos']))
        conexion.commit()
        cursor.close()
        conexion.close()
        return jsonify({'success': True})
    except Exception as e:
        cursor.close()
        conexion.close()
        return jsonify({'error': str(e)}), 400

@app.route('/admin/tarea/<int:tarea_id>/editar', methods=['POST'])
def admin_editar_tarea(tarea_id):
    if 'usuario' not in session or session['rol'] != 'admin':
        return jsonify({'error': 'No autorizado'}), 403

    data = request.json
    conexion = obtener_conexion()
    cursor = conexion.cursor()

    try:
        cursor.execute('''
            UPDATE tareas
            SET clase_id=%s, titulo=%s, descripcion=%s, fecha_entrega=%s, puntos=%s
            WHERE id=%s
        ''', (data['clase_id'], data['titulo'], data['descripcion'],
              data['fecha_entrega'], data['puntos'], tarea_id))
        conexion.commit()
        cursor.close()
        conexion.close()
        return jsonify({'success': True})
    except Exception as e:
        cursor.close()
        conexion.close()
        return jsonify({'error': str(e)}), 400

@app.route('/admin/tarea/<int:tarea_id>/eliminar', methods=['POST'])
def admin_eliminar_tarea(tarea_id):
    if 'usuario' not in session or session['rol'] != 'admin':
        return jsonify({'error': 'No autorizado'}), 403

    conexion = obtener_conexion()
    cursor = conexion.cursor()

    try:
        cursor.execute('DELETE FROM tareas WHERE id = %s', (tarea_id,))
        conexion.commit()
        cursor.close()
        conexion.close()
        return jsonify({'success': True})
    except Exception as e:
        cursor.close()
        conexion.close()
        return jsonify({'error': str(e)}), 400

@app.route('/admin/entregas')
def admin_entregas():
    if 'usuario' not in session or session['rol'] != 'admin':
        return redirect(url_for('login'))

    conexion = obtener_conexion()
    cursor = conexion.cursor(dictionary=True)

    cursor.execute('''
        SELECT e.*, t.titulo as tarea_titulo, u.nombre_completo as alumno_nombre,
               c.nombre as clase_nombre
        FROM entregas e
        JOIN tareas t ON e.tarea_id = t.id
        JOIN usuarios u ON e.alumno_id = u.id
        JOIN clases c ON t.clase_id = c.id
        ORDER BY e.fecha_entrega DESC
    ''')
    entregas = cursor.fetchall()

    cursor.close()
    conexion.close()

    return render_template('admin_entregas.html', entregas=entregas)

# Ejecutar servidor
if __name__ == '__main__':
    app.run(debug=True)
