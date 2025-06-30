import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:social_app/core/widgets/custom_button.dart';
import 'package:social_app/core/widgets/custom_icon_button.dart';
import 'package:social_app/core/widgets/custom_text_field.dart';
import 'package:social_app/feature/auth/services/login_services.dart';
import 'package:social_app/utils/asset_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text("Login"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Lottie.asset(AssetManager.login),
              const SizedBox(height: 20),
              Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _emailController,
                labelText: "Email",
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _passwordController,
                labelText: "Password",
                prefixIcon: Icons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: () {
                  LoginServices.resetPassword(
                    context: context,
                    email: _emailController.text.trim(),
                  );
                },
                child: const Text(
                  "Forget Password?",
                  style: TextStyle(color: Colors.blueGrey, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: "Login",
                onPressed:
                    () => LoginServices.login(
                      context: context,
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                      formKey: _formKey,
                    ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: CustomIconButton(
                      onPressed: () => LoginServices.signInWithGoogle(context),
                      icon: Image.asset(
                        AssetManager.googleLogo,
                        width: 24,
                        height: 24,
                      ),
                      label: 'Google',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomIconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.facebook,
                        color: Color.fromARGB(255, 25, 121, 200),
                        size: 24,
                      ),
                      label: 'Facebook',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed:
                    () => Navigator.pushReplacementNamed(context, '/register'),
                child: const Text(
                  "Don't have an account? Register",
                  style: TextStyle(color: Colors.blueGrey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
