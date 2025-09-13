/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:personal_memory_assistant/services/notification_service.dart'; // Added import
import 'task_input_page.dart';
import 'dart:math';

class HomePage extends StatelessWidget {
  // List of motivational quotes
  final List<String> motivationalQuotes = [
    "Seize the day! Conquer your tasks! 🚀",
    "Progress is made one step at a time. Keep moving! 💪",
    "Transform your goals into reality today! 🌟",
    "Focus and achieve greatness! 📚",
    "Your success awaits—let’s get to work! 🏆",
  ];

  // Get a random quote
  String getRandomQuote() {
    return motivationalQuotes[Random().nextInt(motivationalQuotes.length)];
  }

  // Determine card border color and warning based on deadline
  Map<String, dynamic> getDeadlineStatus(Timestamp deadline) {
    final now = DateTime.now();
    final dueDate = deadline.toDate();
    final difference = dueDate.difference(now).inDays;

    if (dueDate.isBefore(now)) {
      return {
        'borderColor': Color(0xFFEF5350), // Muted red
        'message': 'Overdue! Complete it now! ⏰',
        'icon': Icons.warning,
      };
    } else if (difference <= 2) {
      return {
        'borderColor': Color(0xFFFFB300), // Muted amber
        'message': 'Due soon! Hurry up! ⚡',
        'icon': Icons.alarm,
      };
    } else {
      return {
        'borderColor': Color(0xFF4CAF50), // Muted green
        'message': 'On track! Keep it up! ✅',
        'icon': Icons.check_circle,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final tasksRef = FirebaseFirestore.instance
        .collection('tasks')
        .doc(user.uid)
        .collection('userTasks');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Task Manager",
          style: GoogleFonts.lora(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
        elevation: 2,
        backgroundColor: Color(0xFF2E4057), // Dark slate blue
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFECEFF1), Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Back!",
                  style: GoogleFonts.lora(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF37474F),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  getRandomQuote(),
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF546E7A),
                  ),
                ),
              ],
            ),
          ),
          // Tasks Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              "My Tasks 📋",
              style: GoogleFonts.lora(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF37474F),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: tasksRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print("Firestore Error: ${snapshot.error}");
                  return Center(
                    child: Text(
                      "Error fetching tasks. Please try again.",
                      style: GoogleFonts.lora(
                        fontSize: 18,
                        color: Color(0xFF78909C),
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final tasks = snapshot.data!.docs;
                if (tasks.isEmpty) {
                  return Center(
                    child: Text(
                      "No tasks yet! Add one to get started! 😊",
                      style: GoogleFonts.lora(
                        fontSize: 18,
                        color: Color(0xFF78909C),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final deadlineStatus = getDeadlineStatus(task['deadline']);
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: deadlineStatus['borderColor'],
                          width: 2,
                        ),
                      ),
                      color: Color(0xFFFAFAFA), // Neutral white
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16.0),
                        leading: Icon(
                          deadlineStatus['icon'],
                          color: Color(0xFF37474F),
                          size: 30,
                        ),
                        title: Text(
                          task['title'],
                          style: GoogleFonts.lora(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              "Due: ${DateFormat('dd-MM-yyyy').format((task['deadline'] as Timestamp).toDate())}",
                              style: GoogleFonts.lora(fontSize: 14),
                            ),
                            SizedBox(height: 4),
                            Text(
                              deadlineStatus['message'],
                              style: GoogleFonts.lora(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF78909C),
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          // Added delete button
                          icon: Icon(Icons.delete, color: Color(0xFFEF5350)),
                          onPressed: () async {
                            final taskId = task.id;
                            // Cancel notifications
                            await NotificationService().cancelNotification(taskId.hashCode + 1); // Two days before
                            await NotificationService().cancelNotification(taskId.hashCode + 3); // At college
                            // Delete task from Firestore
                            await tasksRef.doc(taskId).delete();
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskInputPage()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color(0xFF2E4057),
        elevation: 4,
      ),
    );
  }
}*/