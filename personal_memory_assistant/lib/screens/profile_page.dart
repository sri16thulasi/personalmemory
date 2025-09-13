import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text('Please sign in to view your profile', style: GoogleFonts.lora(fontSize: 16))),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blue[50]!, Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                  child: user.photoURL == null ? Icon(Icons.person, size: 50) : null,
                ),
                SizedBox(height: 16),
                Text(user.displayName ?? 'User', style: GoogleFonts.lora(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                Text(user.email ?? '', style: GoogleFonts.lora(fontSize: 16, color: Colors.grey[700])),
                SizedBox(height: 16),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Achievements', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                        SizedBox(height: 8),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).collection('achievements').snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              print('Error loading achievements: ${snapshot.error}');
                              return Text('Error loading achievements', style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]));
                            }
                            if (!snapshot.hasData) return CircularProgressIndicator();
                            final achievements = snapshot.data!.docs;
                            if (achievements.isEmpty) {
                              return Text('No achievements yet', style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]));
                            }
                            return Wrap(
                              spacing: 8,
                              children: achievements.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final validIcons = [
                                  'assets/badges/first_win.svg',
                                  'assets/badges/speed_master.svg',
                                  'assets/badges/topic_expert.svg',
                                ];
                                final iconPath = data.containsKey('icon') &&
                                    data['icon'] is String &&
                                    validIcons.contains(data['icon'])
                                    ? data['icon'] as String
                                    : 'assets/badges/first_win.svg';
                                if (!validIcons.contains(data['icon'])) {
                                  print('Invalid or missing icon in document: ${doc.id}, data: $data');
                                }
                                try {
                                  return SvgPicture.asset(
                                    iconPath,
                                    width: 40,
                                    height: 40,
                                    placeholderBuilder: (context) => Icon(Icons.star, size: 40, color: Colors.grey),
                                  );
                                } catch (e) {
                                  print('Error loading SVG icon $iconPath: $e');
                                  return Icon(Icons.star, size: 40, color: Colors.grey);
                                }
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Progress', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                        SizedBox(height: 16),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection(' yatırım/users').doc(user.uid).collection('stats').snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              print('Error loading stats: ${snapshot.error}');
                              return Text('Error loading stats', style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]));
                            }
                            if (!snapshot.hasData) return CircularProgressIndicator();
                            final stats = snapshot.data!.docs;
                            List<FlSpot> spots = stats.asMap().entries.map((e) {
                              var data = e.value.data() as Map<String, dynamic>;
                              double accuracy = data['total'] > 0 ? data['correct'] / data['total'] : 0;
                              return FlSpot(e.key.toDouble(), accuracy * 100);
                            }).toList();
                            return Container(
                              height: 200,
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(show: true),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text('Test ${value.toInt() + 1}', style: GoogleFonts.lora(fontSize: 12)))),
                                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text('${value.toInt()}%', style: GoogleFonts.lora(fontSize: 12)))),
                                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: true),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: spots,
                                      isCurved: true,
                                      color: Colors.blue[900],
                                      barWidth: 4,
                                      belowBarData: BarAreaData(show: true, color: Colors.blue[200]!.withOpacity(0.3)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 16),
                        FutureBuilder(
                          future: Hive.openBox('user'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            if (snapshot.hasError) {
                              print('Error loading Hive box: ${snapshot.error}');
                              return Text('Error loading streak', style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]));
                            }
                            final box = Hive.box('user');
                            return Text(
                              'Learning Streak: ${box.get('streak', defaultValue: 0)} days',
                              style: GoogleFonts.lora(fontSize: 16, color: Colors.blue[900]),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}