import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarEmpleadosPage extends StatefulWidget {
  // Estos son los "brazos" que reciben los datos para editar
  final String? empleadoId;
  final Map<String, dynamic>? datos;

  const AgregarEmpleadosPage({super.key, this.empleadoId, this.datos});

  @override
  State<AgregarEmpleadosPage> createState() => _AgregarEmpleadosPageState();
}

class _AgregarEmpleadosPageState extends State<AgregarEmpleadosPage> {
  final _nombre = TextEditingController();
  final _puesto = TextEditingController();
  final _sueldo = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Si recibimos un ID, significa que vamos a EDITAR, así que llenamos los campos
    if (widget.empleadoId != null) {
      _nombre.text = widget.datos?['nombre'] ?? '';
      _puesto.text = widget.datos?['puesto'] ?? '';
      _sueldo.text = widget.datos?['sueldo']?.toString() ?? '';
    }
  }

  void _guardarEmpleado() async {
    // Juntamos los datos en un mapa
    Map<String, dynamic> data = {
      'nombre': _nombre.text,
      'puesto': _puesto.text,
      'sueldo': _sueldo.text,
      'fecha_contratacion': widget.empleadoId == null 
          ? FieldValue.serverTimestamp() 
          : widget.datos?['fecha_contratacion'], // Mantiene la fecha original si editas
    };

    if (widget.empleadoId == null) {
      // Si no hay ID, creamos uno NUEVO
      await FirebaseFirestore.instance.collection('empleados').add(data);
    } else {
      // Si hay ID, ACTUALIZAMOS el existente
      await FirebaseFirestore.instance.collection('empleados').doc(widget.empleadoId).update(data);
    }

    Navigator.pop(context); // Regresar a la lista
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.empleadoId == null ? "Nuevo Empleado" : "Editar Empleado"),
        backgroundColor: const Color(0xFF2D4F32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nombre, 
              decoration: const InputDecoration(labelText: "Nombre Completo", border: OutlineInputBorder())
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _puesto, 
              decoration: const InputDecoration(labelText: "Puesto", border: OutlineInputBorder())
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _sueldo, 
              decoration: const InputDecoration(labelText: "Sueldo Semanal", border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D4F32),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _guardarEmpleado,
              child: Text(
                widget.empleadoId == null ? "Registrar Empleado" : "Actualizar Datos",
                style: const TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}