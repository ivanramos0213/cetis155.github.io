import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importaciones de tus páginas existentes
import 'agregar_planta_page.dart';
import 'ver_plantas_page.dart';
import 'login_page.dart';

// Importaciones de las nuevas secciones que creaste
import 'gestion_proveedores_page.dart'; 
import 'gestion_empleado_page.dart';

class AdminMenu extends StatelessWidget {
  const AdminMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo sutil para que resalten las tarjetas blancas
      backgroundColor: const Color(0xFFFDFDFB), 
      appBar: AppBar(
        title: const Text("Panel Administrativo"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1B3022)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(builder: (_) => const LoginPage())
                );
              }
            },
          )
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(25),
        crossAxisCount: 2, // Dos columnas
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          // 1. Sección de Inventario/Plantas
          _menuItem(
            context, 
            "Nueva Planta", 
            Icons.add_business_outlined, 
            const AgregarPlantaPage()
          ),
          _menuItem(
            context, 
            "Inventario", 
            Icons.inventory_2_outlined, 
            const VerPlantasPage(esAdmin: true)
          ),
          
          // 2. Sección de Proveedores (La que anotaste en la libreta)
          _menuItem(
            context, 
            "Proveedores", 
            Icons.local_shipping_outlined, 
            const GestionProveedoresPage()
          ),
          
          // 3. Sección de Empleados
          _menuItem(
            context, 
            "Empleados", 
            Icons.badge_outlined, 
            const GestionEmpleadoPage()
          ),
        ],
      ),
    );
  }

  // Widget personalizado para los botones del menú
  Widget _menuItem(BuildContext context, String title, IconData icon, Widget page) {
    return InkWell(
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => page)
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2D4F32).withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono con tu color verde bosque
            Icon(icon, size: 45, color: const Color(0xFF2D4F32)), 
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                color: Color(0xFF1B3022),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}