import 'package:flutter/material.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade800, Colors.blue.shade400],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.work_outline, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Job Portal',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Select your portal to continue',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 50),
            
            // Job Portal Card (Candidate)
            _PortalCard(
              title: 'Job Portal',
              subtitle: 'Find your dream job',
              icon: Icons.search,
              color: Colors.white,
              textColor: Colors.blue.shade800,
              onTap: () {
                // Navigate to Login/Signup with context of Candidate
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen(requiredRole: 'candidate')),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Recruitment Portal Card (Recruiter)
            _PortalCard(
              title: 'Recruitment Portal',
              subtitle: 'Hire top talent',
              icon: Icons.business,
              color: Colors.white,
              textColor: Colors.deepPurple.shade800,
              onTap: () {
                // Navigate to Login/Signup with context of Recruiter
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen(requiredRole: 'recruiter')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PortalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _PortalCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: textColor, size: 30),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
          ],
        ),
      ),
    );
  }
}
