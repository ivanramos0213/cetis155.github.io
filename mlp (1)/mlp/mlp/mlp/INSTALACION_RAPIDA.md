# 🚀 Instalación Rápida - Plantas Medicinales

## Opción 1: Instalación Rápida (Recomendado para empezar)

### 1. Instalar dependencias
```bash
pip install -r requirements.txt
```

### 2. Crear la base de datos
```bash
mysql -u root -p < database_simple.sql
```

### 3. Configurar app.py
Abre `app.py` y ajusta las credenciales de MySQL (líneas 9-13):
```python
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',          # Tu usuario MySQL
    'password': '',          # Tu contraseña MySQL
    'database': 'medi_db'
}
```

### 4. Iniciar la aplicación
```bash
python app.py
```

### 5. Crear tu primer usuario
1. Abre el navegador en: http://127.0.0.1:5000
2. Ve a "Registrarse"
3. Crea una cuenta con estos requisitos:
   - **Usuario**: Mínimo 3 caracteres
   - **Contraseña**: Mínimo 8 caracteres con:
     - Una mayúscula (A-Z)
     - Una minúscula (a-z)
     - Un número (0-9)
     - Un carácter especial (!@#$%^&*)
   - **Correo**: Formato válido (ejemplo@correo.com)
   - **Teléfono**: 7-20 dígitos

**Ejemplo de contraseña válida**: `MiPassword123!`

### 6. Convertir tu usuario en administrador
Abre MySQL y ejecuta:
```sql
USE medi_db;
UPDATE usuarios SET rol='admin' WHERE usuario='tu_usuario';
```

¡Listo! Ya puedes usar la aplicación completa.

---

## Opción 2: Instalación con Contraseñas Hasheadas (Producción)

### 1. Instalar dependencias
```bash
pip install -r requirements.txt
```

### 2. Generar hashes de contraseñas
```bash
python generar_passwords.py
```
Copia los hashes generados.

### 3. Editar database.sql
Abre `database.sql` y reemplaza:
- `REEMPLAZAR_CON_HASH_DE_ADMIN123!` → Hash del admin
- `REEMPLAZAR_CON_HASH_DE_USUARIO123!` → Hash del usuario

### 4. Crear la base de datos
```bash
mysql -u root -p < database.sql
```

### 5. Configurar y ejecutar
```bash
# Edita app.py con tus credenciales de MySQL
python app.py
```

### 6. Acceder con las credenciales
- **Admin**: admin / Admin123!
- **Usuario**: usuario1 / Usuario123!

---

## 🎯 Acceso Rápido

Una vez instalado:

| URL | Descripción |
|-----|-------------|
| http://127.0.0.1:5000 | Página principal |
| http://127.0.0.1:5000/register | Registrarse |
| http://127.0.0.1:5000/login | Iniciar sesión |
| http://127.0.0.1:5000/plantas | Catálogo de plantas |
| http://127.0.0.1:5000/admin | Panel admin (requiere rol admin) |

---

## ⚠️ Problemas Comunes

### "Access denied for user"
→ Verifica usuario/contraseña en `app.py` línea 10-11

### "No module named 'flask'"
→ Ejecuta: `pip install -r requirements.txt`

### "Unknown database"
→ Ejecuta el script SQL: `mysql -u root -p < database_simple.sql`

### No puedo iniciar sesión después de registrarme
→ Asegúrate de cumplir todos los requisitos de la contraseña

### La contraseña no cumple los requisitos
→ Usa este formato: `Minúscula123!`
- Al menos 1 mayúscula
- Al menos 1 minúscula
- Al menos 1 número
- Al menos 1 carácter especial
- Mínimo 8 caracteres total

---

## 📚 Documentación Completa

Para más detalles, consulta `README.md`

---

**¡Disfruta tu sistema! 🌿**
