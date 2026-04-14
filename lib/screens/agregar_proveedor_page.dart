import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarProveedorPage extends StatefulWidget {
  final String? proveedorId; // Si es null, agrega. Si tiene algo, edita.
  final Map<String, dynamic>? datos;

  const AgregarProveedorPage({super.key, this.proveedorId, this.datos});

  @override
  State<AgregarProveedorPage> createState() => _AgregarProveedorPageState();
}

class _AgregarProveedorPageState extends State<AgregarProveedorPage> {
  final _empresa = TextEditingController();
  final _nombre = TextEditingController();
  final _tel = TextEditingController();
  final _correo = TextEditingController();
  final _dir = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Si estamos editando, cargamos los datos viejos en los cuadros de texto
    if (widget.proveedorId != null) {
      _empresa.text = widget.datos?['empresa'] ?? '';
      _nombre.text = widget.datos?['nombre'] ?? '';
      _tel.text = widget.datos?['telefono'] ?? '';
      _correo.text = widget.datos?['correo'] ?? '';
      _dir.text = widget.datos?['direccion'] ?? '';
    }
  }

  void _guardar() async {
    Map<String, dynamic> data = {
      'empresa': _empresa.text,
      'nombre': _nombre.text,
      'telefono': _tel.text,
      'correo': _correo.text,
      'direccion': _dir.text,
      'fecha_registro': FieldValue.serverTimestamp(),
    };

    if (widget.proveedorId == null) {
      // CREAR NUEVO
      await FirebaseFirestore.instance.collection('proveedor').add(data);
    } else {
      // ACTUALIZAR EXISTENTE
      await FirebaseFirestore.instance.collection('proveedor').doc(widget.proveedorId).update(data);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.proveedorId == null ? "Nuevo Proveedor" : "Editar Proveedor")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _empresa, decoration: const InputDecoration(labelText: "Empresa")),
          TextField(controller: _nombre, decoration: const InputDecoration(labelText: "Nombre")),
          TextField(controller: _tel, decoration: const InputDecoration(labelText: "Teléfono")),
          TextField(controller: _correo, decoration: const InputDecoration(labelText: "Correo")),
          TextField(controller: _dir, decoration: const InputDecoration(labelText: "Dirección")),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _guardar,
            child: Text(widget.proveedorId == null ? "Guardar Nuevo" : "Actualizar Datos"),
          )
        ],
      ),
    );
  }
}