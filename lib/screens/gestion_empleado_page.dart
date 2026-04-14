import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'agregar_empleados_page.dart';

class GestionEmpleadoPage extends StatelessWidget {
  const GestionEmpleadoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Empleados")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('empleados').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;

              String fechaE = "N/A";
              if (data['fecha_contratacion'] != null) {
                fechaE = DateFormat('dd/MM/yyyy').format((data['fecha_contratacion'] as Timestamp).toDate());
              }

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(data['nombre'] ?? 'Sin Nombre'),
                subtitle: Text("Puesto: ${data['puesto']}\nSueldo: \$${data['sueldo']}\nIngreso: $fechaE"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (_) => AgregarEmpleadosPage(empleadoId: doc.id, datos: data))
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => FirebaseFirestore.instance.collection('empleados').doc(doc.id).delete(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgregarEmpleadosPage())),
        child: const Icon(Icons.add),
      ),
    );
  }
}