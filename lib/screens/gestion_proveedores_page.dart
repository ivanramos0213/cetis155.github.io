import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'agregar_proveedor_page.dart';

class GestionProveedoresPage extends StatelessWidget {
  const GestionProveedoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Proveedores")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('proveedor').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              
              // --- AQUÍ SE USA LA FECHA PARA QUE NO SALGA AMARILLO ---
              String fechaDisplay = "N/A";
              if (data['fecha_registro'] != null) {
                fechaDisplay = DateFormat('dd/MM/yyyy').format((data['fecha_registro'] as Timestamp).toDate());
              }

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data['empresa'] ?? 'Sin Empresa', style: const TextStyle(fontWeight: FontWeight.bold)),
                  // Usamos la variable fechaDisplay aquí:
                  subtitle: Text("Contacto: ${data['nombre'] ?? ''}\nRegistrado: $fechaDisplay"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => AgregarProveedorPage(proveedorId: doc.id, datos: data))
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmarBorrado(context, doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgregarProveedorPage())),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmarBorrado(BuildContext context, String id) {
    FirebaseFirestore.instance.collection('proveedor').doc(id).delete();
  }
}