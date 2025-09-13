import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart'; // Adjust path if needed
import 'package:personal_memory_assistant/screens/quiz_preparation_page.dart';
import 'package:personal_memory_assistant/screens/task_input_page.dart'; 
import 'package:personal_memory_assistant/screens/placement_preparation_page.dart';// Add this import

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // Navigate to specific pages
 void _navigateToPage(BuildContext context, String pageName) {
    if (pageName == 'Quiz Preparation') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (context) => QuizState(), // Provide QuizState for QuizPreparationPage
            child: const QuizPreparationPage(),
          ),
        ),
      );
    } else if (pageName == 'Schedules & Reminders') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TaskInputPage()),
      );
    } else if (pageName == 'Placement Preparation') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlacementPreparationHomePage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlaceholderPage(pageName: pageName),
        ),
      );
    }
  }
  // Logout function
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Study Buddy Dashboard',
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User',
                    style: GoogleFonts.lora(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email ?? 'No email',
                    style: GoogleFonts.lora(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(
                'Logout',
                style: GoogleFonts.lora(fontSize: 16),
              ),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Container(
        color: const Color(0xFFF1EFEC), // Cool grey from April 12, 2025
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user.email?.split('@')[0]}!',
              style: GoogleFonts.lora(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildCard(
                    context,
                    title: 'Schedules & Reminders',
                    icon: Icons.calendar_today,
                    onTap: () => _navigateToPage(context, 'Schedules & Reminders'),
                  ),
                  _buildCard(
                    context,
                    title: 'Quiz Preparation',
                    icon: Icons.quiz,
                    onTap: () => _navigateToPage(context, 'Quiz Preparation'),
                  ),
                  _buildCard(
                    context,
                    title: 'Placement Preparation',
                    icon: Icons.work,
                    onTap: () => _navigateToPage(context, 'Placement Preparation'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.lora(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder page for card navigation
class PlaceholderPage extends StatelessWidget {
  final String pageName;

  const PlaceholderPage({super.key, required this.pageName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageName,
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          '$pageName - Coming Soon!',
          style: GoogleFonts.lora(
            fontSize: 24,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}