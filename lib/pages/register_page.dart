// lib/pages/register_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- Add this import
import 'package:moviemaze_app/pages/login_page.dart';
import 'package:moviemaze_app/managers/watchlist_manager_firestore.dart';
import 'package:moviemaze_app/managers/rating_manager_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController(); // <-- NEW
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _passwordMatch = true;

  void _register() async {
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      setState(() {
        _passwordMatch = false;
      });
      return;
    }

    try {
      // 1) Create user in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2) Create a doc for user in Firestore with the nickname
      final uid = credential.user?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'nickname': _nicknameController.text.trim(), // <-- Store nickname
        });
      }

      // Initialize watchers after registration
      WatchlistManagerFirestore.initialize();
      RatingManagerFirestore.initialize();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration Successful!")),
      );
      Navigator.pop(context); // Return to Login page
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Failed: ${e.message}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // background
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo-no-background.png',
                    width: 300,
                  ),
                  const SizedBox(height: 20),
                  // Email field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: const TextStyle(color: Colors.deepOrange),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepOrange),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.deepOrangeAccent),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // NICKNAME field - NEW
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: TextField(
                      controller: _nicknameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Nickname",
                        labelStyle: const TextStyle(color: Colors.deepOrange),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepOrange),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.deepOrangeAccent),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: const TextStyle(color: Colors.deepOrange),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepOrange),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.orangeAccent),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        labelStyle: const TextStyle(color: Colors.deepOrange),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepOrange),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepOrangeAccent),
                        ),
                        errorText:
                        _passwordMatch ? null : "Passwords do not match",
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    onPressed: _register,
                    child: const Text(
                      "Register",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.deepOrangeAccent,
                    ),
                    child: const Text(
                      "Already have an account? Login",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
