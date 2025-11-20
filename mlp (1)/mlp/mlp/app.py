from flask import request, redirect, url_for, flash

@app.route('/admin/eliminar_usuario', methods=['POST'])
def admin_eliminar_usuario():
    user_id = request.form.get('id')
    if not user_id:
        flash("ID de usuario faltante")
        return redirect(url_for('admin_usuarios'))
    try:
        cursor = conexion.cursor()
        cursor.execute("DELETE FROM usuarios WHERE id = %s", (user_id,))
        conexion.commit()
        flash("Usuario eliminado correctamente")
    except Exception as e:
        flash(f"Error al eliminar usuario: {e}")
    return redirect(url_for('admin_usuarios'))