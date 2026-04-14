import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- TUS OTRAS PÁGINAS ---
import 'ver_plantas_page.dart';
import 'carrito_page.dart';
import 'login_page.dart';
import 'perfil_page.dart';       
import 'mis_pedidos_page.dart';  

class UserMenu extends StatelessWidget {
  const UserMenu({super.key});

  static const Color _primaryGreen = Color(0xFF2D5A27);
  static const Color _accentGreen = Color(0xFF4C9A2A);
  static const Color _bgColor = Color(0xFFF8FAF8);
  static const Color _textDark = Color(0xFF1E2D24);

  void cerrarSesion(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void abrirCarrito(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CarritoPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: _bgColor,

      /// MENÚ LATERAL (DRAWER)
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.userChanges(),
              builder: (context, snapshot) {
                final user = snapshot.data ?? currentUser;
                String nombreMostrar = (user?.displayName != null && user!.displayName!.isNotEmpty)
                    ? user.displayName!
                    : "Amante de las Plantas";

                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?q=80&w=600&auto=format&fit=crop"), 
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                    ),
                  ),
                  currentAccountPicture: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const CircleAvatar(
                      backgroundColor: _primaryGreen,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                  ),
                  accountName: Text(
                    nombreMostrar, 
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                  accountEmail: Text(user?.email ?? "usuario@correo.com"),
                );
              },
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.home_outlined, color: _primaryGreen),
                    title: const Text('Inicio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    onTap: () {
                      Navigator.pop(context); 
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_outline, color: _primaryGreen),
                    title: const Text('Mi Perfil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    onTap: () {
                      Navigator.pop(context); 
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PerfilPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined, color: _primaryGreen),
                    title: const Text('Mis Pedidos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    onTap: () {
                      Navigator.pop(context); 
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MisPedidosPage()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
              onTap: () => cerrarSesion(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      
      /// APPBAR
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: _primaryGreen),
        // --- TU LOGO EN EL APPBAR AQUÍ ---
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 35, // Tamaño pequeñito para la barra
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8), 
            const Text(
              "Plantilive",
              style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.5),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
              ],
            ),
            child: IconButton(
              tooltip: "Ver carrito",
              icon: const Icon(Icons.shopping_bag_outlined, color: _textDark),
              onPressed: () => abrirCarrito(context),
            ),
          ),
        ],
      ),

      /// CUERPO DE LA PANTALLA
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_primaryGreen, _accentGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: _primaryGreen.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: const Text("Bienvenido 🌱", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                  const SizedBox(height: 16),
                  const Text("Encuentra tu\nnueva compañera verde", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text("Nuestra Colección", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textDark)),
          ),
          const SizedBox(height: 12),
          const Expanded(
            child: VerPlantasPage(esAdmin: false),
          ),
        ],
      ),
    );
  }
}