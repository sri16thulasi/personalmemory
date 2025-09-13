import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferencePage extends StatelessWidget {
  final String topic;

  const ReferencePage({Key? key, required this.topic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topicNames = {
      'time_and_work': 'Time and Work',
      'percentage': 'Percentage',
      'profit_and_loss': 'Profit and Loss',
      'simple_interest': 'Simple Interest',
      'time_and_distance': 'Time and Distance',
      'logical_reasoning': 'Logical Reasoning',
      'verbal_reasoning': 'Verbal Reasoning',
      'non_verbal_reasoning': 'Non-Verbal Reasoning',
      'python': 'Python',
      'java': 'Java',
      'c': 'C',
    };

    final videoLinks = {
      'time_and_work': [
        {
          'title': 'Time and Work Concepts Playlist - Feel Free to Learn',
          'url': 'https://youtube.com/playlist?list=PLbwyTwgtmtCGWhR4gyAOnFGMD5ZFigU0n&si=EzQw03t6obQAQNh2',
          'channel': 'Feel Free to Learn',
        },
        {
          'title': 'Time and Work Concepts Playlist - Radhina Quants',
          'url': 'https://youtube.com/playlist?list=PLVEh8puYXfDcKsvJdfWiqxkDrvZ5Mgjwq&si=-_jKDGJu7W8cDslu',
          'channel': 'Radhina Quants',
        },
      ],
      'percentage': [
        {
          'title': 'Percentage Concepts - Feel Free to Learn',
          'url': 'https://www.youtube.com/watch?v=4eW3F9v4y5k',
          'channel': 'Feel Free to Learn',
        },
        {
          'title': 'Percentage Concepts - Crack with Jack',
          'url': 'https://www.youtube.com/watch?v=6kXjU0nO0cQ',
          'channel': 'Crack with Jack',
        },
      ],
      'profit_and_loss': [
        {
          'title': 'Profit and Loss Concepts - Feel Free to Learn',
          'url': 'https://www.youtube.com/watch?v=8vL2hF5K7mM',
          'channel': 'Feel Free to Learn',
        },
        {
          'title': 'Profit and Loss Concepts - Crack with Jack',
          'url': 'https://www.youtube.com/watch?v=9Q8z1lZ3v8I',
          'channel': 'Crack with Jack',
        },
      ],
      'simple_interest': [
        {
          'title': 'Simple Interest Concepts - Feel Free to Learn',
          'url': 'https://www.youtube.com/watch?v=O3j7lZ9k2qY',
          'channel': 'Feel Free to Learn',
        },
        {
          'title': 'Simple Interest Concepts - Crack with Jack',
          'url': 'https://www.youtube.com/watch?v=2kT9z7lZ5pU',
          'channel': 'Crack with Jack',
        },
      ],
      'time_and_distance': [
        {
          'title': 'Time and Distance Concepts - Feel Free to Learn',
          'url': 'https://www.youtube.com/watch?v=7bX9v8kF5zU',
          'channel': 'Feel Free to Learn',
        },
        {
          'title': 'Time and Distance Concepts- Crack with Jack',
          'url': 'https://www.youtube.com/watch?v=5X2hR8kV9jQ',
          'channel': 'Crack with Jack',
        },
      ],
      'logical_reasoning': [
        {
          'title': 'Logical Reasoning Playlist - Feel Free to Learn',
          'url': 'https://youtube.com/playlist?list=PL1lPSVzW89HZMlfSi5G-yiAUHFlDrtDox&si=om5d_XyMdPK5n_L1',
          'channel': 'Feel Free to Learn',
        },
        {
          'title': 'Logical Reasoning Puzzles - freeCodeCamp',
          'url': 'https://www.youtube.com/watch?v=HgZLo9TTRP8',
          'channel': 'freeCodeCamp',
        },
      ],
      'verbal_reasoning': [
        {
          'title': 'Verbal Reasoning  - Feel Free to Learn',
          'url': 'https://www.youtube.com/watch?v=8m2g7Z5uWvQ',
          'channel': 'Feel Free to Learn',
        },
        {
          'title': 'Verbal Reasoning - Crack with Jack',
          'url': 'https://www.youtube.com/watch?v=4kL5z9z7i1M',
          'channel': 'Crack with Jack',
        },
      ],
      'non_verbal_reasoning': [
        {
          'title': 'Non-Verbal Reasoning Tricks - Feel Free to Learn',
          'url': 'https://www.youtube.com/watch?v=6mW7vZ3xYk8',
          'channel': 'Feel Free to Learn',
        },
        {
          'title': 'Non-Verbal Reasoning Patterns - Crack with Jack',
          'url': 'https://www.youtube.com/watch?v=2pW8vZ9kX3Y',
          'channel': 'Crack with Jack',
        },
      ],
      'python': [
        {
          'title': 'Python Mock Interview - SPGlobal Solution',
          'url': 'https://youtu.be/OwykyK9iLUk?si=__avOltXpAS9cakd',
          'channel': 'SPGlobal Solution',
        },
        {
          'title': 'Python Coding Playlist - Jenny’s Lectures CS/IT',
          'url': 'https://youtube.com/playlist?list=PLdo5W4Nhv31bZSiqiOL5ta39vSnBxpOPT&si=KHv_jKckXhZL6B4Z',
          'channel': 'Jenny’s Lectures CS/IT',
        },
        {
          'title': 'Python playlist - Error Makes Clever',
          'url': 'https://youtube.com/playlist?list=PLvepBxfiuao1hO1vPOskQ1X4dbjGXF9bm&si=sGjrCDl2DcmhxbEq',
          'channel': 'Error Makes Clever',
        },
        {
          'title': 'Python Tutorials - freeCodeCamp',
          'url': 'https://youtube.com/playlist?list=PLWKjhJtqVAbnqBxcdjVGgT3uVR10bzTEB&si=qYqggrfxCkiBLDTl',
          'channel': 'freeCodeCamp',
        },
        {
          'title': 'Python DSA Playlist - Code Meal',
          'url': 'https://youtube.com/playlist?list=PLVkDztYhxUGH9AubH9hLy_JYam8EZ9VKs&si=2Ood8aSFWRv82FaV',
          'channel': 'Code Meal',
        },
      ],
      'java': [
        {
          'title': 'Java Interview Questions - freeCodeCamp',
          'url': 'https://www.youtube.com/watch?v=4nlaX2v8Y7g',
          'channel': 'freeCodeCamp',
        },
        {
          'title': 'Java Mock Interview - Techqflow Software Solutions',
          'url': 'https://www.youtube.com/watch?v=5q5i9k4c5zI',
          'channel': 'Techqflow Software Solutions',
        },
        {
          'title': 'Java Programming - Jenny’s Lectures CS/IT',
          'url': 'https://www.youtube.com/watch?v=8cm1x4bC610',
          'channel': 'Jenny’s Lectures CS/IT',
        },
        {
          'title': 'Java Interview Prep - Code io',
          'url': 'https://www.youtube.com/watch?v=Z3WifMLt0pQ',
          'channel': 'Code iO',
        },
      ],
      'c': [
        {
          'title': 'C Programming for Beginners - freeCodeCamp',
          'url': 'https://www.youtube.com/watch?v=KJgsSFOSQv0',
          'channel': 'freeCodeCamp',
        },
        {
          'title': 'C Interview Questions - Jenny’s Lectures CS/IT',
          'url': 'https://www.youtube.com/watch?v=6mW7vZ3xYk8',
          'channel': 'Jenny’s Lectures CS/IT',
        },
        {
          'title': 'C Programming in Tamil - Logic First Tamil',
          'url': 'https://www.youtube.com/watch?v=5X2hR8kV9jQ',
          'channel': 'Logic First Tamil',
        },
        {
          'title': 'C Mock Interview - Techqflow Software Solutions',
          'url': 'https://www.youtube.com/watch?v=4kL5z9z7i1M',
          'channel': 'Techqflow Software Solutions',
        },
      ],
    };

    final questionPapers = {
      'time_and_work': [
        {
          'title': 'TCS Time and Work Questions',
          'url': 'https://www.geeksforgeeks.org/time-and-work/',
          'company': 'TCS',
        },
        {
          'title': 'Infosys Time and Work Questions',
          'url': 'https://www.faceprep.in/aptitude/time-and-work-problems/',
          'company': 'Infosys',
        },
      ],
      'percentage': [
        {
          'title': 'TCS Percentage Questions',
          'url': 'https://www.geeksforgeeks.org/percentage-aptitude-questions/',
          'company': 'TCS',
        },
        {
          'title': 'Infosys Percentage Questions',
          'url': 'https://www.faceprep.in/aptitude/percentages-problems/',
          'company': 'Infosys',
        },
      ],
      'profit_and_loss': [
        {
          'title': 'TCS Profit and Loss Questions',
          'url': 'https://www.geeksforgeeks.org/profit-and-loss/',
          'company': 'TCS',
        },
        {
          'title': 'Infosys Profit and Loss Questions',
          'url': 'https://www.faceprep.in/aptitude/profit-and-loss-problems/',
          'company': 'Infosys',
        },
      ],
      'simple_interest': [
        {
          'title': 'TCS Simple Interest Questions',
          'url': 'https://www.geeksforgeeks.org/simple-interest/',
          'company': 'TCS',
        },
        {
          'title': 'Infosys Simple Interest Questions',
          'url': 'https://www.faceprep.in/aptitude/simple-interest-problems/',
          'company': 'Infosys',
        },
      ],
      'time_and_distance': [
        {
          'title': 'TCS Time and Distance Questions',
          'url': 'https://www.geeksforgeeks.org/time-speed-distance/',
          'company': 'TCS',
        },
        {
          'title': 'Infosys Time and Distance Questions',
          'url': 'https://www.faceprep.in/aptitude/time-speed-and-distance-problems/',
          'company': 'Infosys',
        },
      ],
      'logical_reasoning': [
        {
          'title': 'Logical Reasoning Questions',
          'url': 'https://www.geeksforgeeks.org/logical-reasoning/',
          'company': 'geeks for geeks',
        },
        {
          'title': 'Logical Reasoning Questions',
          'url': 'https://www.faceprep.in/logical-reasoning/',
          'company': 'facepreparation',
        },
      ],
      'verbal_reasoning': [
        {
          'title': 'TCS Verbal Reasoning Questions',
          'url': 'https://www.geeksforgeeks.org/verbal-reasoning-questions-and-answers/',
          'company': 'TCS',
        },
        {
          'title': 'Infosys Verbal Reasoning Questions',
          'url': 'https://www.faceprep.in/verbal-ability/',
          'company': 'Infosys',
        },
      ],
      'non_verbal_reasoning': [
        {
          'title': 'TCS Non-Verbal Reasoning Questions',
          'url': 'https://www.geeksforgeeks.org/non-verbal-reasoning/',
          'company': 'TCS',
        },
        {
          'title': 'Infosys Non-Verbal Reasoning Questions',
          'url': 'https://www.faceprep.in/non-verbal-reasoning/',
          'company': 'Infosys',
        },
      ],
      'python': [
        {
          'title': 'Python Coding Questions',
          'url': 'https://www.geeksforgeeks.org/python-programming-examples/',
          'company': 'geeks fro geeks',
        },
        {
          'title': 'Python Coding Questions',
          'url': 'https://www.hackerrank.com/domains/python',
          'company': 'Hacker rank',
        },
      ],
      'java': [
        {
          'title': 'TCS Java Coding Questions',
          'url': 'https://www.geeksforgeeks.org/java-programming-examples/',
          'company': 'TCS',
        },
        {
          'title': 'Infosys Java Coding Questions',
          'url': 'https://www.hackerrank.com/domains/java',
          'company': 'Infosys',
        },
      ],
      'c': [
        {
          'title': 'TCS C Coding Questions',
          'url': 'https://www.geeksforgeeks.org/c-programming-examples/',
          'company': 'TCS',
        },
        {
          'title': 'Infosys C Coding Questions',
          'url': 'https://www.hackerrank.com/domains/c',
          'company': 'Infosys',
        },
      ],
    };

    // Provide a fallback if topic is not found
    final String topicName = topicNames[topic] ?? 'Unknown Topic';
    final List<Map<String, String>> videos = videoLinks[topic] ?? [];
    final List<Map<String, String>> papers = questionPapers[topic] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$topicName References',
          style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YouTube Video Links',
                          style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                        ),
                        SizedBox(height: 8),
                        if (videos.isEmpty)
                          Text(
                            'No videos available for this topic.',
                            style: GoogleFonts.lora(fontSize: 16, color: Colors.grey[700]),
                          )
                        else
                          ...videos.map((video) => ListTile(
                                leading: Icon(Icons.video_library, color: Colors.blue[900]),
                                title: Text(
                                  video['title']!,
                                  style: GoogleFonts.lora(fontSize: 16, color: Colors.grey[700]),
                                ),
                                subtitle: Text(
                                  video['channel']!,
                                  style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[500]),
                                ),
                                onTap: () async {
                                  final url = Uri.parse(video['url']!);
                                  try {
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url, mode: LaunchMode.externalApplication);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Could not open the video')),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                },
                              )),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Company Question Papers',
                          style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                        ),
                        SizedBox(height: 8),
                        if (papers.isEmpty)
                          Text(
                            'No question papers available for this topic.',
                            style: GoogleFonts.lora(fontSize: 16, color: Colors.grey[700]),
                          )
                        else
                          ...papers.map((paper) => ListTile(
                                leading: Icon(Icons.description, color: Colors.blue[900]),
                                title: Text(
                                  paper['title']!,
                                  style: GoogleFonts.lora(fontSize: 16, color: Colors.grey[700]),
                                ),
                                subtitle: Text(
                                  paper['company']!,
                                  style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[500]),
                                ),
                                onTap: () async {
                                  final url = Uri.parse(paper['url']!);
                                  try {
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url, mode: LaunchMode.externalApplication);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Could not open the question paper')),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                },
                              )),
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