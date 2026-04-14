import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pago_page.dart';

class DireccionEnvioPage extends StatefulWidget {
  final List<QueryDocumentSnapshot> items;
  final double totalPagar;

  const DireccionEnvioPage({super.key, required this.items, required this.totalPagar});

  @override
  State<DireccionEnvioPage> createState() => _DireccionEnvioPageState();
}

class _DireccionEnvioPageState extends State<DireccionEnvioPage> {
  // Controladores para leer lo que el usuario escribe
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _calleCtrl = TextEditingController();
  final _coloniaCtrl = TextEditingController();
  final _cpCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  void _irAlPago() {
    if (_formKey.currentState!.validate()) {
      // Juntamos toda la dirección en un solo "Mapa" (diccionario)
      Map<String, dynamic> direccionCompleta = {
        "recibe": _nombreCtrl.text,
        "calle": _calleCtrl.text,
        "colonia": _coloniaCtrl.text,
        "codigo_postal": _cpCtrl.text,
        "telefono": _telefonoCtrl.text,
      };

      // Vamos al pago llevándonos los items, el total y la dirección
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PagoPage(
            items: widget.items,
            totalPagar: widget.totalPagar,
            direccion: direccionCompleta, // ¡Nuevo dato que pasamos!
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1B3022)),
        title: const Text("Dirección de Envío", style: TextStyle(color: Color(0xFF1B3022), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text("¿A dónde enviamos tus plantas? 🚚", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B3022))),
            const SizedBox(height: 20),
            
            _crearCampo("Nombre de quien recibe", Icons.person, _nombreCtrl),
            _crearCampo("Calle y Número", Icons.home, _calleCtrl),
            _crearCampo("Colonia", Icons.location_city, _coloniaCtrl),
            
            Row(
              children: [
                Expanded(child: _crearCampo("C.P.", Icons.markunread_mailbox, _cpCtrl, esNumero: true)),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _crearCampo("Teléfono", Icons.phone, _telefonoCtrl, esNumero: true)),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5A27),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _irAlPago,
              child: const Text("CONTINUAR AL PAGO", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }

  // Widget para no repetir código en cada cajita de texto
  Widget _crearCampo(String texto, IconData icono, TextEditingController controlador, {bool esNumero = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controlador,
        keyboardType: esNumero ? TextInputType.number : TextInputType.text,
        validator: (value) => value!.isEmpty ? "Campo requerido" : null,
        decoration: InputDecoration(
          labelText: texto,
          prefixIcon: Icon(icono, color: const Color(0xFF2D5A27)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2D5A27), width: 2)),
        ),
      ),
    );
  }
}