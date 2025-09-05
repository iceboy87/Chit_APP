import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/views/widgets.dart';

import '../controller/auth_controller.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final _c = Get.find<AuthController>();

  final email = TextEditingController();
  final pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: Get.back),
        title: const Text('Signup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: appInput('Email Id'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pass,
              decoration: appInput('Create Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Obx(
              () => primaryButton(
                _c.isLoading.value ? 'Please wait…' : 'Sign Up',
                () {
                  if (_c.isLoading.value) return;
                  _c.signup(email.text.trim(), pass.text.trim());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
