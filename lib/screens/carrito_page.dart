import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'direccion_envio_page.dart'; // Nos lleva a la pantalla de dirección

class CarritoPage extends StatelessWidget {
  const CarritoPage({super.key});

  @override
  Widget build(BuildContext context) {
    var uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1B3022)),
        title: const Text(
          "Mi Carrito",
          style: TextStyle(color: Color(0xFF1B3022), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("carrito")
            .where("uid", isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2D4F32)));
          }
          
          var items = snapshot.data!.docs;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.production_quantity_limits, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text("Tu carrito está vacío 🪴", style: TextStyle(fontSize: 18, color: Colors.black54)),
                ],
              ),
            );
          }

          // Calcular el total dinámicamente
          double totalPagar = 0;
          for (var item in items) {
            totalPagar += double.tryParse(item["precio"].toString()) ?? 0.0;
          }

          return Column(
            children: [
              // Lista de productos
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    var item = items[index];
 final data = item.data(); // Solo esto, corto y limpio
                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), 
                        side: BorderSide(color: Colors.grey.shade200)
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        
                        // 👇 AQUÍ ES DONDE APARECE LA IMAGEN AHORA 👇
                        leading: Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F4F1),
                            borderRadius: BorderRadius.circular(12),
                            // Si la imagen existe en Firebase, la mostramos
                            image: data.containsKey("imagen") && data["imagen"] != null && data["imagen"].toString().isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(data["imagen"]),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          ),
                          // Si por alguna razón no hay imagen (ej. items viejos en el carrito), mostramos la hojita
                          child: (!data.containsKey("imagen") || data["imagen"] == null || data["imagen"].toString().isEmpty)
                              ? const Icon(Icons.eco, color: Color(0xFF2D4F32))
                              : null,
                        ),
                        // 👆 FIN DEL CAMBIO 👆

                        title: Text(item["nombre"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text(
                          "\$${item["precio"]}", 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D4F32), fontSize: 15)
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => item.reference.delete(),
                          tooltip: "Eliminar del carrito",
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Botón inferior
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total a pagar:", style: TextStyle(fontSize: 16, color: Colors.black54)),
                          Text(
                            "\$${totalPagar.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1B3022)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D4F32),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DireccionEnvioPage(
                                  items: items, 
                                  totalPagar: totalPagar,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "CONTINUAR AL ENVÍO",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}