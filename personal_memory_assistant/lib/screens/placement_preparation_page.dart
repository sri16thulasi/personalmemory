import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:animate_do/animate_do.dart';
import 'package:share_plus/share_plus.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:hive/hive.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'battle_page.dart';
import 'profile_page.dart';
import 'community_page.dart';
import 'aptitude_page.dart';
import 'reasoning_page.dart';
import 'coding_page.dart';
import 'daily_quiz_page.dart';

class PlacementPreparationHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _scheduleDailyNotification();
    return Scaffold(
      appBar: AppBar(
        title: Text('Placement Preparation', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.sports_kabaddi, color: Colors.white),
            onPressed: () => _showBattleDialog(context),
            tooltip: 'Challenge Friends',
          ),
          IconButton(
            icon: Icon(Icons.forum, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityPage())),
            tooltip: 'Community',
          ),
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage())),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildCategoryCard(context, title: 'Aptitude', icon: Icons.calculate, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AptitudePage()))),
              _buildCategoryCard(context, title: 'Reasoning', icon: Icons.psychology, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ReasoningPage()))),
              _buildCategoryCard(context, title: 'Coding', icon: Icons.code, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CodingPage()))),
              _buildCategoryCard(context, title: 'Daily Quiz', icon: Icons.star, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DailyQuizPage()))),
            ],
          ),
        ),
      ),
    );
  }

  void _showBattleDialog(BuildContext context) {
    String battleId = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Challenge Friends', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900])),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Create a battle and invite friends!', style: GoogleFonts.lora(fontSize: 16, color: Colors.grey[700])),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                battleId = Uuid().v4().substring(0, 8);
                Navigator.pop(context);
                _showBattleIdDialog(context, battleId);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Generate Battle ID', style: GoogleFonts.lora(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showBattleIdDialog(BuildContext context, String battleId) {
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => BattlePage(battleId: battleId)));
            },
            child: Text('Join Battle', style: GoogleFonts.lora(fontSize: 16, color: Colors.blue[900])),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blue[900]),
              SizedBox(height: 8),
              Text(title, style: GoogleFonts.lora(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue[900]), textAlign: TextAlign.center),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  if (title == 'Aptitude') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AptitudePage()));
                  } else if (title == 'Reasoning') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ReasoningPage()));
                  } else if (title == 'Coding') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CodingPage()));
                  } else if (title == 'Daily Quiz') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DailyQuizPage()));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[50], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: Text('Learn', style: GoogleFonts.lora(fontSize: 12, color: Colors.blue[900])),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scheduleDailyNotification() async {
    final notifications = FlutterLocalNotificationsPlugin();
    const androidDetails = AndroidNotificationDetails('daily_quiz', 'Daily Quiz', importance: Importance.high, priority: Priority.high);
    const details = NotificationDetails(android: androidDetails);
    await notifications.show(0, 'Daily Quiz Available!', 'Test your skills with today\'s quiz!', details, payload: 'daily_quiz');
  }
}