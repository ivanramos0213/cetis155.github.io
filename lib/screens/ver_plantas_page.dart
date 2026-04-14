import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerPlantasPage extends StatelessWidget {
  final bool esAdmin;
  const VerPlantasPage({super.key, this.esAdmin = false});

  void agregarCarrito(Map<String, dynamic> planta, BuildContext context) async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection("carrito").add({
      "uid": user.uid,
      "nombre": planta["nombre"],
      "precio": planta["precio"],
      "cantidad": 1,
      // 👇 AQUÍ AGREGAMOS LA IMAGEN AL CARRITO 👇
      "imagen": planta["imagen"], 
      "fecha": DateTime.now(),
    });

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Text("${planta['nombre']} lista en tu carrito 🌿"),
          ],
        ),
        backgroundColor: const Color(0xFF2D4F32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Muestra los detalles de la planta en un panel inferior elegante
  void mostrarDetalles(BuildContext context, Map<String, dynamic> planta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // 👇 AQUÍ MOSTRAMOS LA IMAGEN EN GRANDE 👇
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4F1),
                    borderRadius: BorderRadius.circular(25),
                    image: planta["imagen"] != null && planta["imagen"].toString().isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(planta["imagen"]),
                          fit: BoxFit.cover,
                        )
                      : null, // Si no hay imagen, no pone DecorationImage
                  ),
                  // Si no hay imagen, mostramos el ícono como respaldo
                  child: planta["imagen"] == null || planta["imagen"].toString().isEmpty
                      ? const Icon(Icons.yard_outlined, color: Color(0xFF2D4F32), size: 80)
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                planta["nombre"],
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1B3022)),
              ),
              const SizedBox(height: 8),
              Text(
                "\$${planta["precio"]}",
                style: const TextStyle(fontSize: 22, color: Color(0xFF2D4F32), fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              
              Text(
                "Stock disponible: ${planta["stock"]} unidades",
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              
              Text(
                planta["descripcion"] ?? "Una hermosa planta natural, ideal para oxigenar tus espacios y darles un toque vivo y relajante. Requiere cuidados básicos y mucho amor.",
                style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
              ),
              const SizedBox(height: 30),
              
              if (!esAdmin)
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
                      Navigator.pop(context); 
                      agregarCarrito(planta, context); 
                    },
                    child: const Text(
                      "Agregar al carrito",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF7),
      appBar: esAdmin ? AppBar(title: const Text("Inventario"), centerTitle: true) : null,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("plantas").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF2D4F32)));
          var plantas = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: plantas.length,
            itemBuilder: (context, index) {
              var planta = plantas[index];
              final data = planta.data() as Map<String, dynamic>?;
              if (data == null) return const SizedBox();

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D4F32).withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  clipBehavior: Clip.antiAlias, 
                  
                  child: InkWell(
                    onTap: () => mostrarDetalles(context, data),
                    
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      
                      // 👇 AQUÍ MOSTRAMOS LA IMAGEN EN MINIATURA 👇
                      leading: Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F4F1), 
                          borderRadius: BorderRadius.circular(15),
                          image: data["imagen"] != null && data["imagen"].toString().isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(data["imagen"]),
                                fit: BoxFit.cover,
                              )
                            : null,
                        ),
                        child: data["imagen"] == null || data["imagen"].toString().isEmpty
                            ? const Icon(Icons.yard_outlined, color: Color(0xFF2D4F32), size: 30)
                            : null,
                      ),
                      
                      title: Text(data["nombre"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1B3022))),
                      subtitle: Text("Stock: ${data["stock"]} unidades"),
                      
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("\$${data["precio"]}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF2D4F32))),
                          const SizedBox(height: 5),
                          esAdmin 
                            ? InkWell(
                                onTap: () => planta.reference.delete(),
                                child: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                              )
                            : InkWell(
                                onTap: () => agregarCarrito(data, context),
                                child: const Icon(Icons.add_circle_rounded, color: Color(0xFF2D4F32), size: 28),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}