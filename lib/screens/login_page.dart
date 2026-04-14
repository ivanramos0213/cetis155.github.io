import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../custom_input.dart';
import 'user_menu.dart';
import 'admin_menu.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future loginUser() async {
    setState(() => isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(userCredential.user!.uid)
          .get();

      String rol = (userDoc.data() as Map<String, dynamic>)["rol"];

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => rol == "admin" ? const AdminMenu() : const UserMenu()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMsg = "Ocurrió un error inesperado";
      if (e.code == 'user-not-found') errorMsg = "El usuario no existe";
      if (e.code == 'wrong-password') errorMsg = "La contraseña es incorrecta 🔑";
      if (e.code == 'invalid-email') errorMsg = "El formato del correo es inválido";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF7),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(35),
          child: Column(
            children: [
              // 👇 AQUÍ PUSIMOS TU LOGO 👇
              Image.asset(
                'assets/logo.png',
                height: 120, // Mismo tamaño que usamos en el registro
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              const Text("Plantilive", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1B3022))),
              const Text("Inicia sesión para cuidar tu jardín", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              TextField(controller: emailController, decoration: customInput("Correo electrónico", Icons.alternate_email_rounded)),
              const SizedBox(height: 15),
              TextField(controller: passwordController, decoration: customInput("Contraseña", Icons.lock_open_rounded), obscureText: true),
              const SizedBox(height: 30),
              isLoading 
                ? const CircularProgressIndicator(color: Color(0xFF2D4F32))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D4F32),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: loginUser, 
                    child: const Text("INGRESAR", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2))
                  ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                child: const Text("¿No tienes cuenta? Créala aquí", style: TextStyle(color: Color(0xFF2D4F32))),
              )
            ],
          ),
        ),
      ),
    );
  }
}