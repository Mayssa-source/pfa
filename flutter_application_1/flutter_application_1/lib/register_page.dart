import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'package:web3dart/web3dart.dart' show bytesToHex;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

String generatePrivateKey() {
  final rng = Random.secure();
  final privateKeyBytes = List<int>.generate(32, (_) => rng.nextInt(256));
  final privateKeyHex = bytesToHex(privateKeyBytes, include0x: true);
  return privateKeyHex;
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void register() async {
  try {
    // Crée un utilisateur avec Firebase Auth
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    // Ajoute des informations supplémentaires dans Firestore
    await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
      'email': emailController.text.trim(),
      'createdAt': DateTime.now(),
      'privateKey': generatePrivateKey(), // Exemple d'ajout de clé privée
    });

    // Redirige vers la page d'accueil
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur : ${e.toString()}")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("S'inscrire")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Mot de passe"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: const Text("S'inscrire")),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Déjà un compte ? Se connecter"),
            )
          ],
        ),
      ),
    );
  }
}
