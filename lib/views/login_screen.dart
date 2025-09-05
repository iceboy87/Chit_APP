import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sizer/sizer.dart';
import '../routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  Future<String> loginWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return "Login Successful";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Login failed";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              SizedBox(height: 5.h),
              Text(
                "Login",
                style: GoogleFonts.sora(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),

              /// Email
              SizedBox(
                height: 7.h,
                width: 90.w,
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                  value!.isEmpty ? "Email cannot be empty." : null,
                  controller: _emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Email"),
                  ),
                ),
              ),
              SizedBox(height: 2.h),

              /// Password
              SizedBox(
                height: 7.h,
                width: 90.w,
                child: TextFormField(
                  validator: (value) => value!.length < 8
                      ? "Password should have at least 8 characters."
                      : null,
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Password"),
                  ),
                ),
              ),
              SizedBox(height: 2.h),

              /// Login Button
              SizedBox(
                height: 6.h,
                width: 90.w,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.green),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      setState(() => isLoading = true);
                      loginWithEmail(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      ).then((value) {
                        setState(() => isLoading = false);
                        if (value == "Login Successful") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Login Successful")),
                          );
                          Get.offAllNamed(AppRoutes.chitType);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value,
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red.shade400,
                            ),
                          );
                        }
                      });
                    }
                  },
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Login",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 2.h),

              /// Sign Up Redirect
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.signup);
                    },
                    child: Text("Sign Up"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
