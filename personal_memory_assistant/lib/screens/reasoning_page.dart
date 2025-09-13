import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'base_preparation_page.dart';
import 'reference_page.dart';

class ReasoningPage extends BasePreparationPage {
  const ReasoningPage({Key? key, String? initialTopic, String? initialLevel})
      : super(key: key, initialTopic: initialTopic, initialLevel: initialLevel);

  @override
  _ReasoningPageState createState() => _ReasoningPageState();
}

class _ReasoningPageState extends BasePreparationPageState<ReasoningPage> {
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    topics = {
      'logical_reasoning': {
        'name': 'Logical Reasoning',
        'formulas': [
          'Syllogism: All A are B, All B are C => All A are C',
          'Deductive Reasoning: If premise is true, conclusion follows',
        ],
        'real_world_applications': [
          'Decision-making in business strategies.',
          'Problem-solving in legal cases.',
          'Analytical tasks in data science.',
        ],
        'questions': _generateLogicalReasoningQuestions(),
      },
      'verbal_reasoning': {
        'name': 'Verbal Reasoning',
        'formulas': [
          'Analogies: A is to B as C is to D',
          'Reading Comprehension: Identify main idea and inferences',
        ],
        'real_world_applications': [
          'Interpreting reports in corporate settings.',
          'Analyzing texts in journalism.',
          'Evaluating arguments in debates.',
        ],
        'questions': _generateVerbalReasoningQuestions(),
      },
      'non_verbal_reasoning': {
        'name': 'Non-Verbal Reasoning',
        'formulas': [
          'Pattern Recognition: Identify sequences in shapes',
          'Spatial Reasoning: Visualize 3D rotations',
        ],
        'real_world_applications': [
          'Architectural design and planning.',
          'Engineering blueprint analysis.',
          'Game development for spatial puzzles.',
        ],
        'questions': _generateNonVerbalReasoningQuestions(),
      },
    };
    currentTopic = widget.initialTopic ?? '';
    currentLevel = widget.initialLevel ?? 'easy';
    if (widget.initialTopic != null) {
      showTopicSelection = false;
      generateQuestion();
    }
    loadAchievements();
  }

  Map<String, List<Map<String, dynamic>>> _generateLogicalReasoningQuestions() {
    final random = Random();
    return {
      'easy': List.generate(2, (index) {
        String premise1 = 'All cats are mammals';
        String premise2 = 'All mammals have fur';
        String answer = 'All cats have fur';
        List<String> options = [answer, 'Some cats have fur', 'No cats have fur', 'Cats are not mammals']..shuffle();
        return {
          'q': '$premise1. $premise2. What follows?',
          'options': options,
          'a': answer,
          'explanation': 'Syllogism: All A (cats) are B (mammals), All B are C (have fur), so All A are C.',
          'common_mistakes': [
            'Assuming "some" instead of "all".',
            'Misinterpreting premise order.',
          ],
        };
      }),
      'intermediate': List.generate(2, (index) {
        String premise1 = 'Some birds can fly';
        String premise2 = 'All sparrows are birds';
        String answer = 'Some sparrows can fly';
        List<String> options = [answer, 'All sparrows can fly', 'No sparrows can fly', 'Sparrows are not birds']..shuffle();
        return {
          'q': '$premise1. $premise2. What follows?',
          'options': options,
          'a': answer,
          'explanation': 'Some birds can fly implies at least one bird can fly. Since sparrows are birds, some sparrows can fly.',
          'common_mistakes': [
            'Assuming "all" instead of "some".',
            'Ignoring the subset relationship.',
          ],
        };
      }),
      'advanced': List.generate(2, (index) {
        String premise1 = 'No fish are mammals';
        String premise2 = 'Some creatures are fish';
        String answer = 'Some creatures are not mammals';
        List<String> options = [answer, 'All creatures are mammals', 'No creatures are fish', 'Some creatures are mammals']..shuffle();
        return {
          'q': '$premise1. $premise2. What follows?',
          'options': options,
          'a': answer,
          'explanation': 'No fish are mammals means fish and mammals are disjoint. Some creatures are fish, so those creatures are not mammals.',
          'common_mistakes': [
            'Assuming overlap between fish and mammals.',
            'Misinterpreting "some" as "all".',
          ],
        };
      }),
    };
  }

  Map<String, List<Map<String, dynamic>>> _generateVerbalReasoningQuestions() {
    final random = Random();
    return {
      'easy': List.generate(2, (index) {
        String analogy = 'Big is to small as tall is to';
        String answer = 'short';
        List<String> options = [answer, 'long', 'high', 'wide']..shuffle();
        return {
          'q': '$analogy?',
          'options': options,
          'a': answer,
          'explanation': 'Big and small are opposites, so tall’s opposite is short.',
          'common_mistakes': [
            'Choosing synonyms instead of antonyms.',
            'Misunderstanding analogy structure.',
          ],
        };
      }),
      'intermediate': List.generate(2, (index) {
        String analogy = 'Doctor is to hospital as chef is to';
        String answer = 'kitchen';
        List<String> options = [answer, 'restaurant', 'farm', 'market']..shuffle();
        return {
          'q': '$analogy?',
          'options': options,
          'a': answer,
          'explanation': 'A doctor works in a hospital; a chef works in a kitchen.',
          'common_mistakes': [
            'Choosing a related but incorrect location.',
            'Overcomplicating the relationship.',
          ],
        };
      }),
      'advanced': List.generate(2, (index) {
        String analogy = 'Pen is to write as hammer is to';
        String answer = 'strike';
        List<String> options = [answer, 'build', 'cut', 'measure']..shuffle();
        return {
          'q': '$analogy?',
          'options': options,
          'a': answer,
          'explanation': 'A pen is used to write; a hammer is used to strike.',
          'common_mistakes': [
            'Choosing a broader action like "build".',
            'Misinterpreting tool function.',
          ],
        };
      }),
    };
  }

  Map<String, List<Map<String, dynamic>>> _generateNonVerbalReasoningQuestions() {
    final random = Random();
    return {
      'easy': List.generate(2, (index) {
        String sequence = 'Square, Circle, Triangle, Square, Circle, ?';
        String answer = 'Triangle';
        List<String> options = [answer, 'Square', 'Circle', 'Pentagon']..shuffle();
        return {
          'q': 'What comes next in the sequence: $sequence',
          'options': options,
          'a': answer,
          'explanation': 'The sequence repeats every three shapes: Square, Circle, Triangle. After Circle, Triangle follows.',
          'common_mistakes': [
            'Assuming a different pattern length.',
            'Choosing a new shape.',
          ],
        };
      }),
      'intermediate': List.generate(2, (index) {
        String sequence = '1 dot, 2 dots, 4 dots, 7 dots, ? dots';
        String answer = '11 dots';
        List<String> options = [answer, '8 dots', '10 dots', '12 dots']..shuffle();
        return {
          'q': 'What comes next in the sequence: $sequence',
          'options': options,
          'a': answer,
          'explanation': 'The sequence follows a pattern where each term increases by an increment that grows by 1: +1, +2, +3, +4. So, 7 + 4 = 11.',
          'common_mistakes': [
            'Assuming arithmetic progression.',
            'Miscalculating the increment.',
          ],
        };
      }),
      'advanced': List.generate(2, (index) {
        String sequence = 'Rotate 90°, Rotate 180°, Rotate 270°, ?';
        String answer = 'Rotate 360°';
        List<String> options = [answer, 'Rotate 0°', 'Rotate 450°', 'Rotate 180°']..shuffle();
        return {
          'q': 'What comes next in the sequence: $sequence',
          'options': options,
          'a': answer,
          'explanation': 'The sequence increases rotations by 90° each time: 90°, 180°, 270°, 360°.',
          'common_mistakes': [
            'Assuming a reset to 0°.',
            'Misinterpreting rotation increments.',
          ],
        };
      }),
    };
  }

  @override
  String getSection() => 'reasoning';

  @override
  Future<void> submitAnswer(dynamic userAnswer, bool Function(dynamic) isCorrectCheck, String correctAnswerDisplay) async {
    if (selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an option')),
      );
      return;
    }
    await super.submitAnswer(
      selectedOption,
      (userAnswer) => userAnswer == currentQuestion['a'],
      currentQuestion['a'].toString(),
    );
    setState(() {
      selectedOption = null;
    });
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'About Logical Reasoning Tests',
          style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900]),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What is a logical reasoning test?',
                style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
              SizedBox(height: 8),
              Text(
                'A logical reasoning test is an assessment that measures your ability to interpret information, apply logic to solve problems and draw relevant conclusions. It is typically non-verbal and in a multiple-choice format, and requires the use of rules and deduction to reach answers, rather than prior knowledge.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'That said, logical reasoning is actually an umbrella term for multiple types of assessment, and you may find you’re asked to take any one of the following five test types as part of a job application.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              Text(
                'Deductive reasoning',
                style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
              SizedBox(height: 8),
              Text(
                'Commonly presented as a series of word problems, deductive reasoning tests require you to apply top-down-logic; that is, you must draw the right conclusion from a set of given premises.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'Typically, you’ll be presented with a short paragraph, or stimulus, detailing an argument, scenario or a number of stated facts, and a set of possible answers. Only one of these answers can be true, based on the evidence provided.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'You may also be given a conclusive statement and asked to decide if it is true or false, or if there’s insufficient information to conclude either way.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              Text(
                'Inductive reasoning',
                style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
              SizedBox(height: 8),
              Text(
                'Unlike deductive reasoning, inductive reasoning tests ask you to make general inferences – probable conclusions based on a set of information, rather than unquestionable outcomes.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'This is most often done through the use of shapes, patterns, sequences and diagrams. You’ll need to quickly identify relationships and rules, then apply these to find the most logical answer from the multiple-choice options. This could be identifying the odd one out, filling in the missing part of a pattern, or finding the next part of a sequence.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              Text(
                'Diagrammatic reasoning',
                style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
              SizedBox(height: 8),
              Text(
                'Similar to inductive reasoning, diagrammatic reasoning tests offer visual representations of a problem and require you to make logical connections to draw a conclusion.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'Questions often take the form of a diagram with inputs and outputs, and you’ll be required to select which processes from a list of operators would achieve the documented effect. You may also be presented with sets of abstract sequences, given a standalone visual, and asked to select which set it belongs to.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              Text(
                'Abstract reasoning',
                style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
              SizedBox(height: 8),
              Text(
                'Abstract reasoning tests are essentially inductive and/or diagrammatic reasoning tests under another name. They too require you to find relationships and rules between visual sequences, then apply these to select the correct image from multiple options, be it a missing part or a continuation of the sequence in question.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              Text(
                'Critical reasoning',
                style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
              SizedBox(height: 8),
              Text(
                'Critical reasoning tests are more akin to deductive reasoning tests, in that you’ll be dealing with word-based scenarios, arguments, evidence and conclusions.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'These tests tend to evaluate a range of skills. Argument analysis is common, in which a question is posed, and a yes/no answer given with a supporting statement. You’ll need to decide whether the statement is a strong or weak argument.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'Other question types involve scenarios and statements from which you’ll be asked to make assumptions, deductions and inferences based on the evidence provided. Critical reasoning tests are most commonly used in sectors where evidence-based judgement is an everyday requirement, such as law.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              Text(
                'Why do employers use logical reasoning tests?',
                style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
              SizedBox(height: 8),
              Text(
                'As with any form of psychometric assessment, employers use logical reasoning tests as a way to filter applicants, most commonly in the pre-interview stages of selection.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'Logic forms a fundamental part of day-to-day decision making. Our reasoning capabilities determine how effectively we interpret the world around us, and how we use what we know to be fact to inform our choices. As such, logical reasoning is a vital part of many job functions. In administering a logical reasoning test, employers are evaluating how well you’re likely to perform tasks like strategy development, risk assessment and forecasting, as well as general problem solving.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'Additionally, the ability to quickly discern patterns, understand complex relationships, and make logical deductions underpins successful innovation and creative problem-solving in dynamic work environments. Thus, logical reasoning tests also serve as a method for assessing a candidate’s potential to contribute to innovative solutions and strategic thinking in their prospective role.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.lora(fontSize: 16, color: Colors.blue[900])),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicSelection() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topicKey = topics.keys.elementAt(index);
        final topic = topics[topicKey]!;
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(Icons.book, color: Colors.blue[900]),
            title: Text(topic['name'], style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
            subtitle: Text('Practice ${topic['name']} problems', style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700])),
            onTap: () {
              setState(() {
                currentTopic = topicKey;
                showTopicSelection = false;
                generateQuestion();
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('Reasoning Preparation', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            backgroundColor: Colors.blue[900],
            actions: [
              IconButton(
                icon: Icon(Icons.leaderboard, color: Colors.white),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Leaderboard', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                    content: buildLeaderboard(),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close', style: GoogleFonts.lora(fontSize: 16, color: Colors.blue[900])),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[50]!, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: showTopicSelection
                ? _buildTopicSelection()
                : Padding(
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
                                    topics[currentTopic]!['name'],
                                    style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                                  ),
                                  SizedBox(height: 8),
                                  DropdownButton<String>(
                                    value: currentLevel,
                                    items: ['easy', 'intermediate', 'advanced']
                                        .map((level) => DropdownMenuItem(value: level, child: Text(StringExtension(level).capitalize(), style: GoogleFonts.lora(fontSize: 16))))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        currentLevel = value!;
                                        generateQuestion();
                                      });
                                    },
                                  ),
                                  SizedBox(height: 16),
                                  if (currentQuestion.isNotEmpty) ...[
                                    Text(
                                      'Question:',
                                      style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      currentQuestion['q'],
                                      style: GoogleFonts.lora(fontSize: 16, color: Colors.grey[700]),
                                    ),
                                    SizedBox(height: 16),
                                    ...currentQuestion['options'].asMap().entries.map((entry) {
                                      int idx = entry.key;
                                      String option = entry.value;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: FadeInUp(
                                          delay: Duration(milliseconds: idx * 100),
                                          child: RadioListTile<String>(
                                            title: Text(option, style: GoogleFonts.lora(fontSize: 16, color: Colors.blue[900])),
                                            value: option,
                                            groupValue: selectedOption,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedOption = value;
                                              });
                                            },
                                            activeColor: Colors.blue[900],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () => submitAnswer(
                                        selectedOption,
                                        (userAnswer) => userAnswer == currentQuestion['a'],
                                        currentQuestion['a'].toString(),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[900],
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                      ),
                                      child: Text('Submit', style: GoogleFonts.lora(fontSize: 16, color: Colors.white)),
                                    ),
                                  ],
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
                                    'Formulas',
                                    style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                                  ),
                                  SizedBox(height: 8),
                                  ...topics[currentTopic]!['formulas'].map((formula) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Text(
                                          '• $formula',
                                          style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
                                        ),
                                      )),
                                  SizedBox(height: 16),
                                  Text(
                                    'Real-World Applications',
                                    style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                                  ),
                                  SizedBox(height: 8),
                                  ...topics[currentTopic]!['real_world_applications'].map((app) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Text(
                                          '• $app',
                                          style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
                                        ),
                                      )),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ReferencePage(topic: currentTopic),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[900],
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    ),
                                    child: Text('Reference', style: GoogleFonts.lora(fontSize: 16, color: Colors.white)),
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
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            icon: Icon(Icons.info_outline, color: Colors.blue[900], size: 30),
            onPressed: () => _showAboutDialog(context),
            tooltip: 'About Logical Reasoning Tests',
          ),
        ),
      ],
    );
  }
}