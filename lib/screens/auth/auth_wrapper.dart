import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import '../dashboard_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mostrar loading enquanto verifica autenticação
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F9FA),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF2E7D32),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Carregando...',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Se há um usuário logado, mostrar dashboard
        if (snapshot.hasData) {
          return const DashboardScreen();
        }

        // Se não há usuário, mostrar tela de login
        return const LoginScreen();
      },
    );
  }
}
