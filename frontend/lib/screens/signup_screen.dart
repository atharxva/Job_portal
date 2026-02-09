import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'candidate_dashboard.dart';

class SignUpScreen extends StatefulWidget {
  final String? requiredRole;
  const SignUpScreen({super.key, this.requiredRole});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.requiredRole ?? 'candidate';
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.signUp(
        _firstNameController.text,
        _lastNameController.text,
        _userNameController.text,
        _emailController.text,
        _passwordController.text,
        _selectedRole,
      );
      
      if (mounted) {
        // Redirect based on role
        if (_selectedRole == 'recruiter') {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Recruiter account created! Please login.')),
             );
              // Navigate back to login
              Navigator.pop(context); 
        } else {
             // Navigate to Candidate Dashboard
             Navigator.of(context).pushReplacement(
               MaterialPageRoute(builder: (_) => const CandidateDashboard()),
             );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign Up failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
             TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
             TextField(
              controller: _userNameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password (min 8 chars)'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(labelText: 'I am a'),
              items: const [
                DropdownMenuItem(value: 'candidate', child: Text('Candidate')),
                DropdownMenuItem(value: 'recruiter', child: Text('Recruiter')),
              ],
              onChanged: widget.requiredRole != null 
                  ? null // Disable if role is enforced
                  : (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
