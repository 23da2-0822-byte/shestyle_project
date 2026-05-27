import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFA68E74), // Muted brown at top
              Color(0xFFF5EBDD), // Light cream at bottom
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Logo with Blue Underline
                  Column(
                    children: [
                      const Text(
                        'SheStyle',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Container(
                        width: 150,
                        height: 3,
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Title
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D2E17),
                      fontFamily: 'serif',
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Full Name Field
                  _buildTextField(
                    controller: _nameController,
                    hintText: 'Full Name',
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  // Email Field
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Email Address',
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),
                  // Create Password Field
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Create Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    isPasswordField: true,
                    onToggleVisibility: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    isVisible: !_obscurePassword,
                  ),
                  const SizedBox(height: 20),
                  // Confirm Password Field
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    isPasswordField: true,
                    onToggleVisibility: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                    isVisible: !_obscureConfirmPassword,
                  ),
                  const SizedBox(height: 10),
                  // Terms and Conditions
                  Row(
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        activeColor: const Color(0xFF7B3F1B),
                        onChanged: (value) {
                          setState(() => _agreedToTerms = value!);
                        },
                      ),
                      const Text(
                        "Agree to ",
                        style: TextStyle(color: Colors.black54),
                      ),
                      const Text(
                        "Terms & Conditions",
                        style: TextStyle(
                          color: Color(0xFF8B6B4E),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // SignUp Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_nameController.text.trim().isEmpty ||
                            _emailController.text.trim().isEmpty ||
                            _passwordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in all fields'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (_passwordController.text != _confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Passwords do not match'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (!_agreedToTerms) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please agree to Terms & Conditions'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        _authService.signUp(
                          email: _emailController.text,
                          password: _passwordController.text,
                          profileData: {
                            'name': _nameController.text,
                            'email': _emailController.text,
                            'imageUrl': '',
                          },
                          context: context,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B3F1B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'SignUp',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Already have an account?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Color(0xFF7B3F1B),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    bool isPasswordField = false,
    VoidCallback? onToggleVisibility,
    bool isVisible = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black38),
        prefixIcon: Icon(prefixIcon, color: Colors.black54),
        suffixIcon: isPasswordField
            ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black54,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }
}
