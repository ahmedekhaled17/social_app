import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:social_app/core/widgets/custom_button.dart';
import 'package:social_app/core/widgets/custom_text_field.dart';
import 'package:social_app/feature/auth/services/register_services.dart';
import 'package:social_app/utils/asset_manager.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text("Register"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Lottie.asset(AssetManager.register, repeat: false),
              const SizedBox(height: 20),
              Text(
                "Create New Account",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _usernameController,
                labelText: "Username",
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _emailController,
                labelText: "Email",
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: RegisterServices.emailValidator,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _passwordController,
                labelText: "Password",
                prefixIcon: Icons.lock,
                obscureText: true,
                validator: RegisterServices.passwordValidator,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: "Register",
                onPressed: () {
                  RegisterServices.registerUser(
                    context: context,
                    formKey: _formKey,
                    username: _usernameController.text.trim(),
                    email: _emailController.text.trim(),
                    password: _passwordController.text.trim(),
                  );
                },
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed:
                    () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text(
                  "Already have an account? Log in",
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
