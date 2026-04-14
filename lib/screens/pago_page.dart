import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PagoPage extends StatefulWidget {
  final List<QueryDocumentSnapshot> items;
  final double totalPagar;
  final Map<String, dynamic> direccion; // Recibe la dirección de la pantalla anterior

  const PagoPage({
    super.key, 
    required this.items, 
    required this.totalPagar,
    required this.direccion,
  });

  @override
  State<PagoPage> createState() => _PagoPageState();
}

class _PagoPageState extends State<PagoPage> {
  String _metodoSeleccionado = "Tarjeta de Crédito/Débito";
  bool _procesando = false; 

  void procesarPago() async {
    setState(() => _procesando = true);
    
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 1. Simulamos que el banco procesa el pago (2 segundos)
      await Future.delayed(const Duration(seconds: 2));

      // 2. Guardamos TODO el pedido en Firebase (incluyendo la dirección)
      await FirebaseFirestore.instance.collection("pedidos").add({
        "uid": user.uid,
        "fecha": DateTime.now(),
        "total": widget.totalPagar,
        "estado": "Preparando envío",
        "metodo_pago": _metodoSeleccionado,
        "direccion_envio": widget.direccion, // <-- ¡Se guarda la dirección!
        "articulos": widget.items.map((item) => {
          "nombre": item["nombre"],
          "precio": item["precio"],
        }).toList(),
      });

      // 3. Vaciamos el carrito (borramos los items actuales)
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var item in widget.items) {
        batch.delete(item.reference);
      }
      await batch.commit();

      // 4. Mostramos mensaje de éxito
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Text("¡Pago exitoso con $_metodoSeleccionado! 🌿"),
            ],
          ),
          backgroundColor: const Color(0xFF2D4F32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      );
      
      // 5. Lo regresamos al menú principal cerrando todas las pantallas intermedias
      Navigator.popUntil(context, (route) => route.isFirst);

    } catch (e) {
      setState(() => _procesando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hubo un error al procesar tu pago.")),
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
        title: const Text("Método de Pago", style: TextStyle(color: Color(0xFF1B3022), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Resumen a pagar
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D5A27),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text("Total a Pagar", style: TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        "\$${widget.totalPagar.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text("Elige cómo quieres pagar:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B3022))),
                const SizedBox(height: 16),

                // Opciones
                _construirOpcionPago(Icons.credit_card, "Tarjeta de Crédito/Débito"),
                _construirOpcionPago(Icons.account_balance, "Transferencia Bancaria (SPEI)"),
                _construirOpcionPago(Icons.storefront, "Pago en Tienda de Conveniencia"),
              ],
            ),
          ),

          // Botón final
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D4F32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _procesando ? null : procesarPago,
                  child: _procesando
                      ? const SizedBox(
                          height: 24, width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Text(
                          "PAGAR AHORA",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Widget para la UI de las opciones de pago
  Widget _construirOpcionPago(IconData icono, String titulo) {
    bool seleccionado = _metodoSeleccionado == titulo;

    return GestureDetector(
      onTap: () {
        setState(() {
          _metodoSeleccionado = titulo;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: seleccionado ? const Color(0xFF2D5A27).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: seleccionado ? const Color(0xFF2D5A27) : Colors.grey.shade300,
            width: seleccionado ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icono, color: seleccionado ? const Color(0xFF2D5A27) : Colors.grey.shade500),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                titulo,
                style: TextStyle(
                  fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                  color: seleccionado ? const Color(0xFF2D5A27) : Colors.black87,
                ),
              ),
            ),
            if (seleccionado)
              const Icon(Icons.check_circle, color: Color(0xFF2D5A27)),
          ],
        ),
      ),
    );
  }
}