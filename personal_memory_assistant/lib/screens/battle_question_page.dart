import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hive/hive.dart';
import 'package:confetti/confetti.dart';
import 'battle_results_page.dart';

class BattleQuestionPage extends StatefulWidget {
  final String battleId;

  const BattleQuestionPage({required this.battleId});

  @override
  _BattleQuestionPageState createState() => _BattleQuestionPageState();
}

class _BattleQuestionPageState extends State<BattleQuestionPage> {
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> questions = [];
  List<String?> userAnswers = List.filled(5, null);
  int score = 0;
  Timer? _timer;
  int secondsElapsed = 0;
  final double maxAllowedTime = 30.0;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 1));
    _loadQuestions();
    _startTimer();
  }

  void _loadQuestions() async {
    final box = await Hive.openBox('questions');
    if (box.get('battle_questions') != null) {
      questions = List<Map<String, dynamic>>.from(box.get('battle_questions'));
    } else {
      questions = [
        {'type': 'aptitude', 'q': 'If 3x + 5 = 20, what is x?', 'options': ['5', '6', '7', '8'], 'correct': '5', 'explanation': 'Solve: 3x + 5 = 20 => 3x = 15 => x = 5'},
        {'type': 'reasoning', 'q': 'If CAT is coded as 3120, how is DOG coded?', 'options': ['4156', '5146', '6145', '5156'], 'correct': '4156', 'explanation': 'Each letter is coded as its position in the alphabet (A=1, B=2, ..., Z=26). C=3, A=1, T=20, so CAT=3120. For DOG: D=4, O=15, G=7, so DOG=4156.'},
        {'type': 'coding', 'q': 'What is the output of: print(2 ** 3)?', 'options': ['6', '8', '9', '12'], 'correct': '8', 'explanation': 'In Python, ** denotes exponentiation. So, 2 ** 3 = 2³ = 8.'},
        {'type': 'aptitude', 'q': 'What is 15% of 200?', 'options': ['25', '30', '35', '40'], 'correct': '30', 'explanation': '15% of 200 = (15/100) * 200 = 30.'},
        {'type': 'reasoning', 'q': 'Complete the series: 2, 4, 8, 16, ?', 'options': ['24', '32', '48', '64'], 'correct': '32', 'explanation': 'Each number is multiplied by 2: 2 * 2 = 4, 4 * 2 = 8, 8 * 2 = 16, 16 * 2 = 32.'},
      ]..shuffle();
      await box.put('battle_questions', questions);
    }
    setState(() {});
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
        score += 20;
        _confettiController.play();
      }
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        print('Writing score for battleId: ${widget.battleId}, user: ${user.uid}, score: $score');
        await FirebaseFirestore.instance.collection('battles').doc(widget.battleId).collection('scores').doc(user.uid).set({
          'name': user.displayName ?? 'User_${user.uid.substring(0, 4)}',
          'score': score,
          'timestamp': Timestamp.now(),
        });
      } catch (e) {
        print('Error saving battle score: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update battle score: $e')));
      }
    }

    if (currentQuestionIndex < 4) {
      setState(() {
        currentQuestionIndex++;
        _startTimer();
      });
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BattleResultsPage(battleId: widget.battleId, userScore: score)));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) return Center(child: CircularProgressIndicator());
    final question = questions[currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text('CodeClash Arena', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blue[900]!, Colors.blue[300]!], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Question ${currentQuestionIndex + 1}/5 (${question['type']})', style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('Score: $score', style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 8),
                  CircularPercentIndicator(
                    radius: 40.0,
                    lineWidth: 5.0,
                    percent: secondsElapsed / maxAllowedTime,
                    center: Text('${(maxAllowedTime - secondsElapsed).toInt()}s', style: GoogleFonts.lora(fontSize: 16, color: Colors.white)),
                    progressColor: Colors.white,
                    backgroundColor: Colors.white30,
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
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: -pi / 2,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                maxBlastForce: 100,
                minBlastForce: 80,
              ),
            ),
          ],
        ),
      ),
    );
  }
}