import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'battle_question_page.dart';

class BattlePage extends StatelessWidget {
  final String battleId;

  const BattlePage({required this.battleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CodeClash Arena', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blue[900]!, Colors.blue[300]!], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                child: Text('Welcome to CodeClash Arena!', style: GoogleFonts.lora(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
              ),
              SizedBox(height: 16),
              ZoomIn(child: Text('Battle ID: $battleId', style: GoogleFonts.lora(fontSize: 18, color: Colors.white70))),
              SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('battles').doc(battleId).collection('scores').snapshots(),
                builder: (context, snapshot) {
                  int playerCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                  return Text('Players Joined: $playerCount/2', style: GoogleFonts.lora(fontSize: 16, color: Colors.white));
                },
              ),
              SizedBox(height: 32),
              ElasticIn(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BattleQuestionPage(battleId: battleId)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Start Battle', style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}