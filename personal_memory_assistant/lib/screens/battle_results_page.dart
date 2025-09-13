import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:personal_memory_assistant/screens/placement_preparation_page.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';
import 'battle_question_page.dart'; // Update to BattleQuestionPage

class BattleResultsPage extends StatelessWidget {
  final String battleId;
  final int userScore;

  const BattleResultsPage({required this.battleId, required this.userScore});

  // Add _showBattleIdDialog logic
  void _showBattleIdDialog(BuildContext context) {
    String battleId = Uuid().v4().substring(0, 8);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Your Battle ID', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900])),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Share this ID to challenge friends:', style: GoogleFonts.lora(fontSize: 16, color: Colors.grey[700])),
            SizedBox(height: 8),
            SelectableText(battleId, style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Share.share('Join my CodeClash battle! ID: $battleId', subject: 'CodeClash Battle Invite'),
              icon: Icon(Icons.share, color: Colors.white),
              label: Text('Share Invite', style: GoogleFonts.lora(fontSize: 16, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BattleQuestionPage(battleId: battleId)),
              );
            },
            child: Text('Join Battle', style: GoogleFonts.lora(fontSize: 16, color: Colors.blue[900])),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Loading results for battleId: $battleId, userScore: $userScore');
    return Scaffold(
      appBar: AppBar(
        title: Text('Battle Results', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blue[900]!, Colors.blue[300]!], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('battles').doc(battleId).collection('scores').orderBy('score', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print('StreamBuilder error: ${snapshot.error}');
              return Center(child: Text('Error loading results: ${snapshot.error}', style: GoogleFonts.lora(fontSize: 18, color: Colors.white)));
            }
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

            final scores = snapshot.data!.docs;
            if (scores.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No scores available yet', style: GoogleFonts.lora(fontSize: 18, color: Colors.white)),
                    SizedBox(height: 16),
                    Text('Your Score: $userScore', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              );
            }

            bool isWinner = scores.isNotEmpty && scores.first['score'] == userScore && userScore > (scores.length > 1 ? scores[1]['score'] : 0);
            String badgeIcon = isWinner ? 'assets/badges/first_win.svg' : 'assets/badges/speed_master.svg';
            String badgeName = isWinner ? 'Battle Champion' : 'Valiant Contender';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  FadeInUp(child: Text('Battle Results', style: GoogleFonts.lora(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white))),
                  SizedBox(height: 16),
                  ZoomIn(
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text('Your Score: $userScore', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                            SizedBox(height: 16),
                            SvgPicture.asset(badgeIcon, width: 60, height: 60),
                            SizedBox(height: 8),
                            Text(badgeName, style: GoogleFonts.lora(fontSize: 18, color: Colors.blue[900])),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: scores.length,
                      itemBuilder: (context, index) {
                        final score = scores[index];
                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: Text('#${index + 1}', style: GoogleFonts.lora(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                            title: Text(score['name'], style: GoogleFonts.lora(fontSize: 16, color: Colors.blue[900])),
                            trailing: Text('${score['score']}', style: GoogleFonts.lora(fontSize: 16, color: Colors.blue[900])),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElasticIn(
                        child: ElevatedButton(
                          onPressed: () => _showBattleIdDialog(context), // Use the local method
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          child: Text('New Battle', style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                        ),
                      ),
                      ElasticIn(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => PlacementPreparationHomePage()),
                            (route) => false,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          child: Text('Back to Home', style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}