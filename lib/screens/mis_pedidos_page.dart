import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MisPedidosPage extends StatelessWidget {
  const MisPedidosPage({super.key});

  // Paleta de colores Planti-Life
  static const Color primaryGreen = Color(0xFF2D5A27);
  static const Color darkText = Color(0xFF1B3022);
  static const Color softBackground = Color(0xFFF4F7F2);
  static const Color accentSage = Color(0xFF8BA888);

  // Estilo base Arial 11 (Flutter usa double, 11 es el tamaño solicitado)
  static const TextStyle arial11 = TextStyle(
    fontFamily: 'Arial',
    fontSize: 11,
    color: darkText,
  );

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: softBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkText),
        title: const Text(
          "Planti-Life", // Nombre actualizado
          style: TextStyle(
            fontFamily: 'Arial',
            color: darkText,
            fontWeight: FontWeight.w800,
            fontSize: 18, // El título se mantiene un poco más grande por jerarquía
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("pedidos")
            .where("uid", isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryGreen));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          var pedidos = snapshot.data!.docs;
          pedidos.sort((a, b) => (b["fecha"] as Timestamp).compareTo(a["fecha"] as Timestamp));

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              var pedido = pedidos[index];
              DateTime fecha = (pedido["fecha"] as Timestamp).toDate();
              String fechaFormateada = "${fecha.day}/${fecha.month}/${fecha.year}";
              List articulos = pedido["articulos"] ?? [];

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    // Cabecera
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.05),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "PEDIDO: $fechaFormateada",
                            style: arial11.copyWith(fontWeight: FontWeight.bold, color: accentSage),
                          ),
                          _buildStatusBadge(pedido["estado"]),
                        ],
                      ),
                    ),
                   
                    // Cuerpo
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...articulos.map((art) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline, size: 14, color: primaryGreen),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    art["nombre"],
                                    style: arial11, // Aplicando Arial 11
                                  ),
                                ),
                                Text(
                                  "\$${art["precio"] ?? ''}",
                                  style: arial11.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          )),
                          const Divider(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("TOTAL COMPRA", style: arial11.copyWith(fontWeight: FontWeight.bold)),
                              Text(
                                "\$${pedido["total"]}",
                                style: arial11.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: primaryGreen
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String estado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        estado.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Arial',
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco_outlined, size: 60, color: accentSage.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            "No hay actividad en Planti-Life aún",
            style: TextStyle(fontFamily: 'Arial', fontSize: 14, fontWeight: FontWeight.bold, color: darkText),
          ),
        ],
      ),
    );
  }
}
