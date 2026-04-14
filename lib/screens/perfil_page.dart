import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  User? user = FirebaseAuth.instance.currentUser;

  // Función para actualizar el nombre en Firebase
  Future<void> _actualizarNombre(String nuevoNombre) async {
    if (nuevoNombre.isEmpty) return;

    try {
      await user?.updateDisplayName(nuevoNombre);
      await user?.reload(); // Recarga los datos del usuario desde Firebase
      
      setState(() {
        user = FirebaseAuth.instance.currentUser; // Actualizamos la variable local
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nombre actualizado con éxito")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al actualizar el nombre")),
        );
      }
    }
  }

  // Cuadro de diálogo para editar el nombre
  void _mostrarDialogoEditarNombre() {
    TextEditingController nombreController = TextEditingController(
      text: user?.displayName ?? "",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Editar Nombre", style: TextStyle(color: Color(0xFF1B3022))),
          content: TextField(
            controller: nombreController,
            decoration: InputDecoration(
              hintText: "Escribe tu nuevo nombre",
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF2D5A27)),
              ),
            ),
            cursorColor: const Color(0xFF2D5A27),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5A27),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                _actualizarNombre(nombreController.text.trim());
                Navigator.pop(context);
              },
              child: const Text("Guardar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1B3022)),
        title: const Text(
          "Mi Perfil",
          style: TextStyle(color: Color(0xFF1B3022), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Foto de perfil grande
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2D5A27), width: 2),
              ),
              child: const CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFF2D5A27),
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            
            // Fila con el Nombre y el botón de editar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  // Mostramos el nombre de Firebase, si no hay, mostramos el por defecto
                  user?.displayName != null && user!.displayName!.isNotEmpty 
                      ? user!.displayName! 
                      : "Amante de las Plantas",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B3022)),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Color(0xFF2D5A27)),
                  onPressed: _mostrarDialogoEditarNombre,
                  tooltip: "Editar nombre",
                ),
              ],
            ),
            
            // Correo del usuario
            Text(
              user?.email ?? "Sin correo registrado",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 40),
            
            // Tarjeta de información extra
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.star_border, color: Color(0xFF2D5A27)),
                        title: Text("Miembro desde"),
                        trailing: Text("2024", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.local_shipping_outlined, color: Color(0xFF2D5A27)),
                        title: Text("Dirección de envío"),
                        subtitle: Text("Agregar dirección..."),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}