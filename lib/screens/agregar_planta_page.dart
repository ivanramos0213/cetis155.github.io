import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../custom_input.dart';

class AgregarPlantaPage extends StatefulWidget {
  const AgregarPlantaPage({super.key});

  @override
  State<AgregarPlantaPage> createState() => _AgregarPlantaPageState();
}

class _AgregarPlantaPageState extends State<AgregarPlantaPage> {

  final nombre = TextEditingController();
  final precio = TextEditingController();
  final stock = TextEditingController();

  Future guardarPlanta() async {

    await FirebaseFirestore.instance.collection("plantas").add({
      "nombre": nombre.text,
      "precio": int.parse(precio.text),
      "stock": int.parse(stock.text),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Planta")),

      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [

            TextField(
              controller: nombre,
              decoration: customInput("Nombre", Icons.eco),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: precio,
              decoration: customInput("Precio", Icons.attach_money),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: stock,
              decoration: customInput("Stock", Icons.inventory),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: guardarPlanta,
              child: const Text("GUARDAR"),
            )

          ],
        ),
      ),
    );
  }
}