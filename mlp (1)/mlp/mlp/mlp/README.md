# CETIS 155 CLASSROOM

Plataforma educativa tipo Google Classroom para el CETIS 155.

## Características

### Para Alumnos
- Unirse a clases con código único
- Ver tareas pendientes
- Entregar tareas
- Recibir calificaciones y comentarios

### Para Profesores
- Crear y gestionar clases
- Asignar tareas con fecha límite
- Recibir entregas
- Calificar y comentar trabajos

### Para Administradores
- Panel completo de administración
- Gestionar usuarios, clases y tareas
- Ver todas las entregas del sistema
- **Acceso: usuario `admin`, contraseña `admin`**

## Instalación

### 1. Importar Base de Datos
```bash
mysql -u root -p < database.sql
```

### 2. Instalar Dependencias
```bash
pip install -r requirements.txt
```

### 3. Ejecutar Aplicación
```bash
python app.py
```

Abrir en navegador: http://127.0.0.1:5000

## Credenciales de Prueba

- **Admin:** admin / admin
- **Profesores:** prof_matematicas / 123
- **Alumnos:** alumno01 / 123

## Estructura del Proyecto

```
mlp/
├── app.py              # Backend Flask
├── database.sql        # Base de datos completa
├── requirements.txt    # Dependencias
├── templates/          # Plantillas HTML (14 archivos)
└── static/            # CSS, fuentes, imágenes
```

## Base de Datos

- **5 Tablas:** usuarios, clases, alumnos_clases, tareas, entregas
- **10 Usuarios:** 1 admin, 4 profesores, 5 alumnos
- **6 Clases** con códigos únicos (MAT2024, FIS2024, etc.)
- **11 Tareas** de ejemplo
- **Vistas SQL** para estadísticas
- **Triggers** de validación

## Tecnologías

- **Backend:** Flask (Python)
- **Base de Datos:** MySQL
- **Frontend:** HTML, CSS, Bootstrap 5
- **Seguridad:** Werkzeug (hashing)

## Diseño

Mantiene colores y estilo del CETIS 155:
- Color principal: #3b5998 (azul)
- Tipografía: Poppins
- Diseño responsivo

---
© 2025 CETIS 155 - Educación digital para todos
