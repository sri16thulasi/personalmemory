import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hive/hive.dart';

class DailyQuizPage extends StatefulWidget {
  @override
  _DailyQuizPageState createState() => _DailyQuizPageState();
}

class _DailyQuizPageState extends State<DailyQuizPage> {
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> questions = [];
  List<String?> userAnswers = List.filled(3, null);
  int score = 0;
  Timer? _timer;
  int secondsElapsed = 0;
  final double maxAllowedTime = 20.0;

  @override
  void initState() {
    super.initState();
    _loadDailyQuiz();
    _updateStreak();
  }

  void _loadDailyQuiz() async {
    final box = await Hive.openBox('daily_quiz');
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (box.get('last_quiz_date') != today) {
      questions = [
        {'type': 'aptitude', 'q': 'What is 20% of 50?', 'options': ['10', '12', '15', '20'], 'correct': '10', 'explanation': '20% of 50 = (20/100) * 50 = 10'},
        {'type': 'reasoning', 'q': 'If A is B\'s brother and B is C\'s sister, who is C to A?', 'options': ['Brother', 'Sister', 'Friend', 'Cousin'], 'correct': 'Sister', 'explanation': 'A is B\'s brother, and B is C\'s sister, so C is A\'s sister.'},
        {'type': 'coding', 'q': 'What is the output of: len("hello")?', 'options': ['4', '5', '6', '7'], 'correct': '5', 'explanation': 'In Python, len("hello") returns the length of the string, which is 5.'},
      ]..shuffle();
      await box.put('daily_quiz', questions);
      await box.put('last_quiz_date', today);
    } else {
      questions = List<Map<String, dynamic>>.from(box.get('daily_quiz'));
    }
    setState(() {});
  }

  void _updateStreak() async {
    final box = await Hive.openBox('user');
    final lastDate = box.get('last_quiz_date', defaultValue: '');
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (lastDate != today) {
      final streak = box.get('streak', defaultValue: 0);
      if (lastDate.isNotEmpty) {
        final lastQuiz = DateTime.parse(lastDate);
        if (lastQuiz.difference(DateTime.now()).inDays.abs() <= 1) {
          await box.put('streak', streak + 1);
        } else {
          await box.put('streak', 1);
        }
      } else {
        await box.put('streak', 1);
      }
      await box.put('last_quiz_date', today);
    }
  }

  void _startTimer() {
    secondsElapsed = 0;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          secondsElapsed++;
          if (secondsElapsed >= maxAllowedTime) {
            _submitAnswer(null);
          }
        });
      }
    });
  }

  void _submitAnswer(String? answer) async {
    _timer?.cancel();
    setState(() {
      userAnswers[currentQuestionIndex] = answer;
      if (answer == questions[currentQuestionIndex]['correct']) {
        score += 10;
      }
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('daily_quiz').doc(DateTime.now().toIso8601String().split('T')[0]).set({
          'score': score,
          'timestamp': Timestamp.now(),
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save quiz score: $e')));
      }
    }

    if (currentQuestionIndex < 2) {
      setState(() {
        currentQuestionIndex++;
        _startTimer();
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Daily Quiz Results', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900])),
          content: Text('Your Score: $score/30', style: GoogleFonts.lora(fontSize: 16, color: Colors.grey[700])),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: GoogleFonts.lora(fontSize: 16, color: Colors.blue[900])),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) return Center(child: CircularProgressIndicator());
    final question = questions[currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Quiz', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blue[50]!, Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Question ${currentQuestionIndex + 1}/3 (${question['type']})', style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
              SizedBox(height: 8),
              CircularPercentIndicator(
                radius: 40.0,
                lineWidth: 5.0,
                percent: secondsElapsed / maxAllowedTime,
                center: Text('${(maxAllowedTime - secondsElapsed).toInt()}s', style: GoogleFonts.lora(fontSize: 16, color: Colors.blue[900])),
                progressColor: Colors.blue[900]!,
                backgroundColor: Colors.grey[300]!,
              ),
              SizedBox(height: 16),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(question['q'], style: GoogleFonts.lora(fontSize: 18, color: Colors.blue[900])),
                ),
              ),
              SizedBox(height: 16),
              ...question['options'].asMap().entries.map((entry) {
                int idx = entry.key;
                String option = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: FadeInUp(
                    delay: Duration(milliseconds: idx * 100),
                    child: ElevatedButton(
                      onPressed: () => _submitAnswer(option),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue[900],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(option, style: GoogleFonts.lora(fontSize: 16, color: Colors.blue[900])),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}