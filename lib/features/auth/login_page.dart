import 'package:flutter/material.dart';
import '../dashboard/dashboard_page.dart';
import 'auth_controller.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final email = TextEditingController(text: 'admin@test.com');
  final password = TextEditingController(text: '123456');
  final controller = AuthController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: email),
            TextField(controller: password),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await controller.login(email.text, password.text);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                );
              },
              child: const Text('Login'),
            )
          ],
        ),
      ),
    );
  }
}
