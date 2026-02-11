import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'signup_screen.dart';
import 'recruiter_dashboard.dart';
import 'candidate_dashboard.dart';

class LoginScreen extends StatefulWidget {
  final String? requiredRole;
  const LoginScreen({super.key, this.requiredRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.login(
        _emailController.text,
        _passwordController.text,
      );
      
      if (mounted) {
        final user = data['user'];
        final role = user['role'] ?? 'candidate';

        // Check if user role matches the required portal role
        if (widget.requiredRole != null && role != widget.requiredRole) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Access Denied: Please use the ${role == 'recruiter' ? 'Recruitment' : 'Job'} Portal.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        if (role == 'recruiter') {
            await _apiService.saveRole('recruiter');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const RecruiterDashboard()),
            );
        } else {
            await _apiService.saveRole('candidate');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const CandidateDashboard()),
            );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SignUpScreen(requiredRole: widget.requiredRole)),
                );
              },
              child: const Text('Don\'t have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
