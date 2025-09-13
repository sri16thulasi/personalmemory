import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LearningResourcesPage extends StatelessWidget {
  final String category;

  const LearningResourcesPage({required this.category});

  @override
  Widget build(BuildContext context) {
    final resources = {
      'Aptitude': [
        {
          'title': 'Number Systems',
          'content': 'Learn about LCM, HCF, and modular arithmetic...',
        },
        {
          'title': 'Percentages',
          'content': 'Understand percentage calculations and applications...',
        },
      ],
      'Reasoning': [
        {
          'title': 'Logical Puzzles',
          'content': 'Practice solving puzzles like Sudoku...',
        },
        {
          'title': 'Syllogisms',
          'content': 'Master syllogistic reasoning...',
        },
      ],
      'Coding': [
        {
          'title': 'Arrays',
          'content': 'Learn array manipulation and algorithms...',
        },
        {
          'title': 'Sorting',
          'content': 'Understand sorting techniques like QuickSort...',
        },
      ],
    };

    if (!resources.containsKey(category)) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Error',
            style: GoogleFonts.lora(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blue[900]!,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[50]!, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Text(
              'Invalid category selected',
              style: GoogleFonts.lora(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$category Resources',
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[900]!,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: resources[category]!.length,
          itemBuilder: (context, index) {
            final resource = resources[category]![index] as Map<String, String>;
            return Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  resource['title']!,
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900]!,
                  ),
                ),
                subtitle: Text(
                  resource['content']!,
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  // Navigate to detailed resource page (placeholder)
                },
              ),
            );
          },
        ),
      ),
    );
  }
}