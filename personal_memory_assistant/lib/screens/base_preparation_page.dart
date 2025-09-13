import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'learning_resources_page.dart';

abstract class BasePreparationPage extends StatefulWidget {
  final String? initialTopic;
  final String? initialLevel;

  const BasePreparationPage({Key? key, this.initialTopic, this.initialLevel}) : super(key: key);
}

abstract class BasePreparationPageState<T extends BasePreparationPage> extends State<T> {
  Map<String, dynamic> topics = {};
  String currentTopic = '';
  String currentLevel = 'easy';
  Map<String, dynamic> currentQuestion = {};
  bool showTopicSelection = true;
  List<Map<String, dynamic>> achievements = [];
  Map<String, int> leaderboard = {};

  String getSection();

  void loadAchievements() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('achievements').get();
      setState(() {
        achievements = snapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      print('Error loading achievements: $e');
    }
  }

  void generateQuestion() {
    if (currentTopic.isEmpty || !topics.containsKey(currentTopic)) return;
    final questions = topics[currentTopic]!['questions'][currentLevel] as List<dynamic>;
    if (questions.isEmpty) return;
    setState(() {
      currentQuestion = Map<String, dynamic>.from(questions[Random().nextInt(questions.length)]);
    });
  }

  Future<void> submitAnswer(dynamic userAnswer, bool Function(dynamic) isCorrectCheck, String correctAnswerDisplay) async {
    bool isCorrect = isCorrectCheck(userAnswer);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('stats').add({
          'section': getSection(),
          'topic': currentTopic,
          'level': currentLevel,
          'correct': isCorrect ? 1 : 0,
          'total': 1,
          'timestamp': Timestamp.now(),
        });

        final box = await Hive.openBox('user');
        int streak = box.get('streak', defaultValue: 0);
        if (isCorrect) {
          await box.put('streak', streak + 1);
          if (streak + 1 >= 5 && !achievements.any((a) => a['name'] == '5-Day Streak')) {
            await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('achievements').add({
              'name': '5-Day Streak',
              'icon': 'assets/badges/streak.svg',
              'timestamp': Timestamp.now(),
            });
            setState(() {
              achievements.add({'name': '5-Day Streak', 'icon': 'assets/badges/streak.svg'});
            });
          }
        } else {
          await box.put('streak', 0);
        }

        await FirebaseFirestore.instance.collection('leaderboard').doc(getSection()).set({
          user.displayName ?? 'User_${user.uid.substring(0, 4)}': FieldValue.increment(isCorrect ? 10 : 0),
        }, SetOptions(merge: true));
      } catch (e) {
        print('Error updating stats: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update stats: $e')));
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCorrect ? 'Correct!' : 'Incorrect', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: isCorrect ? Colors.green : Colors.red)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your answer: $userAnswer', style: GoogleFonts.lora(fontSize: 16, color: Colors.grey[700])),
              Text('Correct answer: $correctAnswerDisplay', style: GoogleFonts.lora(fontSize: 16, color: Colors.grey[700])),
              SizedBox(height: 8),
              Text('Explanation:', style: GoogleFonts.lora(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900])),
              Text(currentQuestion['explanation'], style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700])),
              SizedBox(height: 8),
              Text('Common Mistakes:', style: GoogleFonts.lora(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900])),
              ...currentQuestion['common_mistakes'].map((mistake) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text('• $mistake', style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700])),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              generateQuestion();
            },
            child: Text('Next Question', style: GoogleFonts.lora(fontSize: 16, color: Colors.blue[900])),
          ),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LearningResourcesPage(category: StringExtension(getSection()).capitalize()))),
            child: Text('Learn More', style: GoogleFonts.lora(fontSize: 16, color: Colors.blue[900])),
          ),
        ],
      ),
    );
  }

  Widget buildLeaderboard() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('leaderboard').doc(getSection()).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error loading leaderboard: ${snapshot.error}');
          return Text('Error loading leaderboard', style: GoogleFonts.lora(fontSize: 14));
        }
        if (!snapshot.hasData) return CircularProgressIndicator();
        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final sortedEntries = data.entries.toList()..sort((a, b) => (b.value as int).compareTo(a.value as int));
        return Container(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: sortedEntries.length,
            itemBuilder: (context, index) {
              final entry = sortedEntries[index];
              return ListTile(
                leading: Text('#${index + 1}', style: GoogleFonts.lora(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                title: Text(entry.key, style: GoogleFonts.lora(fontSize: 16, color: Colors.blue[900])),
                trailing: Text('${entry.value}', style: GoogleFonts.lora(fontSize: 16, color: Colors.blue[900])),
              );
            },
          ),
        );
      },
    );
  }
}
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
extension BaseStringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}