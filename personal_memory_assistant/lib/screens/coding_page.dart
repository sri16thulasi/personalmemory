import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'base_preparation_page.dart';
import 'reference_page.dart';


class CodingPage extends BasePreparationPage {
  const CodingPage({Key? key, String? initialTopic, String? initialLevel})
      : super(key: key, initialTopic: initialTopic, initialLevel: initialLevel);

  @override
  _CodingPageState createState() => _CodingPageState();
}

class _CodingPageState extends BasePreparationPageState<CodingPage> {
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    topics = {
      'python': {
        'name': 'Python',
        'formulas': [
          'List comprehension: [f(x) for x in iterable]',
          'Dictionary: {key: value}',
          'Function: def func(params): return value',
        ],
        'real_world_applications': [
          'Web development with Django/Flask.',
          'Data analysis with Pandas.',
          'Machine learning with TensorFlow.',
        ],
        'questions': _generatePythonQuestions(),
      },
      'java': {
        'name': 'Java',
        'formulas': [
          'Class: class Name { fields; methods; }',
          'ArrayList: List<Type> list = new ArrayList<>()',
          'Inheritance: class Child extends Parent',
        ],
        'real_world_applications': [
          'Enterprise applications with Spring.',
          'Android app development.',
          'Big data processing with Hadoop.',
        ],
        'questions': _generateJavaQuestions(),
      },
      'c': {
        'name': 'C',
        'formulas': [
          'Pointer: int *ptr = &var',
          'Array: int arr[size]',
          'Function: return_type func(params)',
        ],
        'real_world_applications': [
          'Operating system development.',
          'Embedded systems programming.',
          'High-performance computing.',
        ],
        'questions': _generateCQuestions(),
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

  Map<String, List<Map<String, dynamic>>> _generatePythonQuestions() {
    final random = Random();
    return {
      'easy': List.generate(2, (index) {
        int num = 10 + random.nextInt(11); // 10 to 20
        String answer = (num * num).toString();
        List<String> options = [answer, (num * num + 1).toString(), (num * num - 1).toString(), (num * num + 2).toString()]..shuffle();
        return {
          'q': 'Write a Python function to return the square of $num. What is the output?',
          'options': options,
          'a': answer,
          'explanation': 'def square(n): return n * n\nsquare($num) = $num * $num = $answer',
          'common_mistakes': [
            'Returning n + n instead of n * n.',
            'Forgetting to return the result.',
          ],
        };
      }),
      'intermediate': List.generate(2, (index) {
        String code = '[x for x in range(1, 6) if x % 2 == 0]';
        String answer = '[2, 4]';
        List<String> options = [answer, '[1, 3, 5]', '[2, 4, 6]', '[1, 2, 3, 4, 5]']..shuffle();
        return {
          'q': 'What is the output of the Python code: $code?',
          'options': options,
          'a': answer,
          'explanation': 'The list comprehension filters even numbers from 1 to 5. range(1, 6) gives [1, 2, 3, 4, 5]. x % 2 == 0 selects 2, 4.',
          'common_mistakes': [
            'Including 6 in the range.',
            'Selecting odd numbers.',
          ],
        };
      }),
      'advanced': List.generate(2, (index) {
        String q = 'In a mock interview, you’re asked to reverse a linked list in Python. What’s the correct approach?';
        String answer = 'Iteratively swap pointers';
        List<String> options = [answer, 'Recursively reverse the entire list', 'Use a stack to store nodes', 'Reverse the data values only']..shuffle();
        return {
          'q': q,
          'options': options,
          'a': answer,
          'explanation': 'class ListNode:\n    def __init__(self, val=0, next=None):\n        self.val = val\n        self.next = next\ndef reverseList(head):\n    prev = None\n    curr = head\n    while curr:\n        next_temp = curr.next\n        curr.next = prev\n        prev = curr\n        curr = next_temp\n    return prev\nThis iteratively reverses pointers, O(n) time, O(1) space.',
          'common_mistakes': [
            'Reversing data instead of pointers.',
            'Not handling edge cases (empty list).',
          ],
        };
      }),
    };
  }

  Map<String, List<Map<String, dynamic>>> _generateJavaQuestions() {
    final random = Random();
    return {
      'easy': List.generate(2, (index) {
        int num = 5 + random.nextInt(6); // 5 to 10
        String answer = (num % 2 == 0 ? 'true' : 'false');
        List<String> options = ['true', 'false', '0', '1']..shuffle();
        return {
          'q': 'Write a Java method to check if $num is even. What is the output?',
          'options': options,
          'a': answer,
          'explanation': 'public boolean isEven(int n) { return n % 2 == 0; }\nisEven($num) = $answer',
          'common_mistakes': [
            'Using n / 2 instead of n % 2.',
            'Returning an integer instead of boolean.',
          ],
        };
      }),
      'intermediate': List.generate(2, (index) {
        String code = 'List<Integer> list = Arrays.asList(1, 2, 3); list.add(4);';
        String answer = 'Throws UnsupportedOperationException';
        List<String> options = [answer, 'List becomes [1, 2, 3, 4]', 'List remains [1, 2, 3]', 'NullPointerException']..shuffle();
        return {
          'q': 'What happens when you run this Java code: $code?',
          'options': options,
          'a': answer,
          'explanation': 'Arrays.asList() returns a fixed-size list backed by the array. Adding elements is not supported, causing UnsupportedOperationException.',
          'common_mistakes': [
            'Assuming the list is mutable.',
            'Confusing with ArrayList.',
          ],
        };
      }),
      'advanced': List.generate(2, (index) {
        String q = 'In a mock interview, you’re asked to implement a binary search tree in Java. What’s the correct way to insert a node?';
        String answer = 'Recursively traverse and insert';
        List<String> options = [answer, 'Iteratively traverse and insert', 'Use a queue for insertion', 'Append at the root']..shuffle();
        return {
          'q': q,
          'options': options,
          'a': answer,
          'explanation': 'class Node {\n    int val;\n    Node left, right;\n    Node(int val) { this.val = val; }\n}\nclass BST {\n    Node insert(Node root, int val) {\n        if (root == null) return new Node(val);\n        if (val < root.val)\n            root.left = insert(root.left, val);\n        else\n            root.right = insert(root.right, val);\n        return root;\n    }\n}\nThis recursively inserts a node, maintaining BST properties, O(log n) average time.',
          'common_mistakes': [
            'Not updating child pointers.',
            'Inserting in wrong subtree.',
          ],
        };
      }),
    };
  }

  Map<String, List<Map<String, dynamic>>> _generateCQuestions() {
    final random = Random();
    return {
      'easy': List.generate(2, (index) {
        int num = 3 + random.nextInt(5); // 3 to 7
        String answer = (1 << num).toString();
        List<String> options = [answer, (1 << (num + 1)).toString(), (1 << (num - 1)).toString(), (num << 1).toString()]..shuffle();
        return {
          'q': 'Write a C function to left-shift 1 by $num bits. What is the output?',
          'options': options,
          'a': answer,
          'explanation': 'int shift(int n) { return 1 << n; }\nshift($num) = 1 << $num = $answer',
          'common_mistakes': [
            'Using right shift (>>).',
            'Shifting by wrong number of bits.',
          ],
        };
      }),
      'intermediate': List.generate(2, (index) {
        String code = 'int x = 5; int *p = &x; *p = 10;';
        String answer = '10';
        List<String> options = [answer, '5', 'Address of x', 'Null']..shuffle();
        return {
          'q': 'What is the value of x after this C code: $code?',
          'options': options,
          'a': answer,
          'explanation': 'p points to x’s address. *p = 10 modifies x’s value to 10 via the pointer.',
          'common_mistakes': [
            'Assuming p changes the address.',
            'Not dereferencing the pointer.',
          ],
        };
      }),
      'advanced': List.generate(2, (index) {
        String q = 'In a mock interview, you’re asked to detect a cycle in a linked list in C. What’s the correct approach?';
        String answer = 'Floyd’s Cycle Detection';
        List<String> options = [answer, 'Use a hash table', 'Reverse the list', 'Check each node twice']..shuffle();
        return {
          'q': q,
          'options': options,
          'a': answer,
          'explanation': 'struct Node {\n    int val;\n    struct Node* next;\n};\nbool hasCycle(struct Node* head) {\n    if (!head) return false;\n    struct Node *slow = head, *fast = head;\n    while (fast && fast->next) {\n        slow = slow->next;\n        fast = fast->next->next;\n        if (slow == fast) return true;\n    }\n    return false;\n}\nFloyd’s algorithm uses two pointers, O(n) time, O(1) space.',
          'common_mistakes': [
            'Not checking for null pointers.',
            'Using extra space unnecessarily.',
          ],
        };
      }),
    };
  }

  @override
  String getSection() => 'coding';

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
          'About Coding Interviews',
          style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900]),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What is a coding interview?',
                style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
              SizedBox(height: 8),
              Text(
                'A coding interview is a technical assessment used by companies to evaluate a candidate’s programming skills, problem-solving abilities, and algorithmic thinking. Typically, candidates solve coding problems on a whiteboard, online editor, or during pair programming sessions within 30-45 minutes.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'These interviews assess proficiency in languages like Python, Java, or C, and test knowledge of data structures, algorithms, and system design, critical for roles in software engineering and tech.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              Text(
                'What are the different types of coding interview questions?',
                style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
              SizedBox(height: 8),
              Text(
                'Coding interview questions vary by focus: algorithmic (e.g., sorting, searching), data structures (e.g., linked lists, trees), system design (e.g., scalable APIs), and behavioral (e.g., teamwork, problem-solving approach).',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'At Practice Coding Tests, we provide industry-standard questions for tech roles, covering Python, Java, C, and more, with mock interviews to simulate real-world scenarios.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              Text(
                'How do I prepare for coding interviews?',
                style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
              SizedBox(height: 8),
              Text(
                'Effective preparation involves practicing coding problems daily, starting with easy ones and progressing to complex algorithms. Use platforms like LeetCode or our free practice tests to build skills.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'Practice smartly by reviewing solutions, understanding time/space complexity, and conducting mock interviews. Watch YouTube channels like freeCodeCamp or Techqflow Software Solutions for tips and mock sessions.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'Focus on one or two programming languages (e.g., Python, Java) and master their standard libraries and data structures.',
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              Text(
                'Practice Coding Tests has helped over 7 million candidates globally with free resources, mock interviews, and video tutorials to ace coding interviews.',
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
            title: Text('Coding Preparation', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
            tooltip: 'About Coding Interviews',
          ),
        ),
      ],
    );
  }
}