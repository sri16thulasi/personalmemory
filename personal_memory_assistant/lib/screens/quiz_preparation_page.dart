import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:confetti/confetti.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:flutter/semantics.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class QuizState with ChangeNotifier {
  List<Map<String, dynamic>> questions = [];
  List<int?> userAnswers = [];
  int currentQuestionIndex = 0;
  bool isQuizSubmitted = false;
  int score = 0;
  int totalPoints = 0;
  String? sessionId;
  bool showInputForm = true;
  String? feedbackMessage;
  bool showRetryButton = false;
  String? lastErrorMessage;

  void setQuestions(List<Map<String, dynamic>> newQuestions, String newSessionId) {
    questions = newQuestions;
    userAnswers = List.filled(questions.length, null);
    currentQuestionIndex = 0;
    isQuizSubmitted = false;
    score = 0;
    totalPoints = 0;
    sessionId = newSessionId;
    showInputForm = false;
    feedbackMessage = questions.length < 5 ? 'Note: Only ${questions.length} questions available.' : null;
    notifyListeners();
  }

  void updateAnswer(int index, int? answer) {
    userAnswers[index] = answer;
    notifyListeners();
  }

  void submitQuiz() {
    isQuizSubmitted = true;
    score = 0;
    totalPoints = 0;
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] == questions[i]['correctAnswer']) {
        score++;
        totalPoints += 10;
      }
    }
    notifyListeners();
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      currentQuestionIndex--;
      notifyListeners();
    }
  }

  void resetQuiz() {
    showInputForm = true;
    questions = [];
    userAnswers = [];
    currentQuestionIndex = 0;
    isQuizSubmitted = false;
    score = 0;
    totalPoints = 0;
    sessionId = null;
    feedbackMessage = null;
    showRetryButton = false;
    lastErrorMessage = null;
    notifyListeners();
  }

  void setError(String message) {
    showRetryButton = true;
    lastErrorMessage = message;
    notifyListeners();
  }
}

class QuizPreparationPage extends StatefulWidget {
  const QuizPreparationPage({super.key});

  @override
  _QuizPreparationPageState createState() => _QuizPreparationPageState();
}

class _QuizPreparationPageState extends State<QuizPreparationPage> {
  final _formKey = GlobalKey<FormState>();
  final _courseNameController = TextEditingController();
  final _regulationController = TextEditingController();
  final _yearController = TextEditingController();
  String _department = 'CSE';
  String _semester = 'I';
  String _courseCode = 'CS3101';
  String _unitType = 'Unit I';
  String _language = 'English';
  bool _isLoading = false;
  bool _isDarkMode = false;
  bool _isHighContrast = false;
  double _fontSize = 16.0;
  bool _isPracticeMode = false;
  bool _showImmediateFeedback = false;
  late ConfettiController _confettiController;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static const String apiBaseUrl = 'http://127.0.0.1:5000';

  final List<String> _departments = ['CSE', 'AIDS'];
  final List<String> _semesters = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII'];
  final Map<String, Map<String, List<Map<String, String>>>> _courses = {
    'CSE': {
      'I': [
        {'code': 'CS3101', 'name': 'Python Programming'},
        {'code': 'CS3102', 'name': 'Chemistry'},
      ],
      'II': [
        {'code': 'CS3201', 'name': 'C Programming'},
        {'code': 'CS3202', 'name': 'Digital Principles and Computer Organization'},
      ],
      'III': [
        {'code': 'CS3301', 'name': 'Data Structures'},
        {'code': 'CS3302', 'name': 'Object Oriented Programming'},
      ],
      'IV': [
        {'code': 'CS3401', 'name': 'Design and Analysis of Algorithms'},
        {'code': 'CS3402', 'name': 'Operating Systems'},
      ],
      'V': [
        {'code': 'CS3501', 'name': 'Computer Networks'},
        {'code': 'CS3502', 'name': 'Compiler Design'},
      ],
      'VI': [
        {'code': 'CS3601', 'name': 'Object Oriented Software Engineering'},
        {'code': 'CS3602', 'name': 'Internet of Things'},
      ],
      'VII': [
        {'code': 'CS3701', 'name': 'Cloud Computing'},
        {'code': 'CS3702', 'name': 'Artificial Intelligence'},
      ],
      'VIII': [
        {'code': 'CS3801', 'name': 'Cyber Security'},
        {'code': 'CS3802', 'name': 'Project Work'},
      ],
    },
    'AIDS': {
      'I': [
        {'code': 'AI3101', 'name': 'Fundamentals of Programming'},
        {'code': 'AI3102', 'name': 'Mathematics for Data Science I'},
      ],
      'II': [
        {'code': 'AI3201', 'name': 'Data Structures'},
        {'code': 'AI3202', 'name': 'Database Management Systems'},
      ],
      'III': [
        {'code': 'AI3301', 'name': 'Machine Learning'},
        {'code': 'AI3302', 'name': 'Operating Systems'},
      ],
      'IV': [
        {'code': 'AI3401', 'name': 'Data Mining and Machine Learning'},
        {'code': 'AI3402', 'name': 'Big Data Technologies'},
      ],
      'V': [
        {'code': 'AI3501', 'name': 'Deep Learning'},
        {'code': 'AI3502', 'name': 'Data Visualization'},
      ],
      'VI': [
        {'code': 'AI3601', 'name': 'Natural Language Processing'},
        {'code': 'AI3602', 'name': 'Reinforcement Learning'},
      ],
      'VII': [
        {'code': 'AI3701', 'name': 'AI Ethics and Regulations'},
        {'code': 'AI3702', 'name': 'Computer Vision'},
      ],
      'VIII': [
        {'code': 'AI3801', 'name': 'AI Project Development'},
        {'code': 'AI3802', 'name': 'Time Series Analysis'},
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    initializeNotifications();
    tz.initializeTimeZones();
  }

  Future<void> initializeNotifications() async {
    final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);
    await notificationsPlugin.initialize(settings);
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> _scheduleDailyReminder() async {
    await _notificationsPlugin.zonedSchedule(
      0,
      'Time to Study!',
      'Take a quiz on EduQuiz to prepare for your exams!',
      _nextDailyNotification(),
      const NotificationDetails(
        android: AndroidNotificationDetails('quiz_reminder', 'Quiz Reminders'),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextDailyNotification() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<bool> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> _generateQuestions(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    if (!await _checkConnectivity()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offline. Try loading a cached quiz.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final quizState = Provider.of<QuizState>(context, listen: false);

    const maxRetries = 2;
    final apiUrl = '$apiBaseUrl/api/generate-questions';
    try {
      if (quizState.sessionId == null) quizState.sessionId = const Uuid().v4();
      final payload = {
        'sessionId': quizState.sessionId,
        'semester': _semester,
        'department': _department,
        'courseCode': _courseCode,
        'unitType': _unitType,
        'numQuestions': 5,
      };

      int attempts = 0;
      http.Response? response;

      while (attempts < maxRetries) {
        try {
          response = await http
              .post(
                Uri.parse(apiUrl),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(payload),
              )
              .timeout(const Duration(seconds: 15));
          break;
        } catch (e) {
          attempts++;
          if (attempts >= maxRetries || e is! TimeoutException) {
            rethrow;
          }
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      if (response!.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fetchedQuestions = List<Map<String, dynamic>>.from(data['questions']);
        quizState.setQuestions(fetchedQuestions, data['sessionId']);
        await _saveQuizLocally();
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('quizzes')
              .doc('temp')
              .collection(user.uid)
              .doc('current_quiz')
              .set({
            'sessionId': quizState.sessionId,
            'questions': fetchedQuestions,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('API Error: ${errorBody['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      String errorMessage = e is TimeoutException
          ? 'Request timed out. Ensure API is running at $apiUrl.'
          : e.toString().contains('SocketException')
              ? 'Network error. Check connection or API URL ($apiUrl).'
              : e.toString();
      quizState.setError(errorMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating quiz: $errorMessage')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveQuizLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final quizState = Provider.of<QuizState>(context, listen: false);
    await prefs.setString('cached_quiz', jsonEncode({
      'sessionId': quizState.sessionId,
      'questions': quizState.questions,
      'userAnswers': quizState.userAnswers,
    }));
  }

  Future<void> _loadCachedQuiz(BuildContext context) async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final quizState = Provider.of<QuizState>(context, listen: false);
    final cachedQuiz = prefs.getString('cached_quiz');
    if (cachedQuiz != null) {
      final data = jsonDecode(cachedQuiz);
      quizState.setQuestions(
        List<Map<String, dynamic>>.from(data['questions']),
        data['sessionId'],
      );
      quizState.userAnswers = List<int?>.from(data['userAnswers']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No cached quiz available')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _resumeQuiz(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    final quizState = Provider.of<QuizState>(context, listen: false);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc('temp')
          .collection(user.uid)
          .doc('current_quiz')
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        quizState.setQuestions(
          List<Map<String, dynamic>>.from(data['questions']),
          data['sessionId'],
        );
        quizState.userAnswers = List<int?>.from(data['userAnswers'] ?? List.filled(quizState.questions.length, null));
        quizState.isQuizSubmitted = data['submittedAt'] != null;
        quizState.score = data['score'] ?? 0;
        quizState.totalPoints = data['totalPoints'] ?? 0;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No quiz to resume')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resuming quiz: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePerformance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final quizState = Provider.of<QuizState>(context, listen: false);
    final unitPerformance = {
      'unit': _unitType,
      'courseCode': _courseCode,
      'score': quizState.score,
      'totalQuestions': quizState.questions.length,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('performance')
        .add(unitPerformance);
  }

  Future<void> _suggestTopics() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('performance')
        .where('score', isLessThan: 0.6)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final weakUnit = snapshot.docs.first.data();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Try practicing ${weakUnit['unit']} in ${weakUnit['courseCode']} to improve!'),
        ),
      );
    }
  }

  Future<void> _awardBadge(String badgeName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('badges')
        .doc(badgeName)
        .set({
      'name': badgeName,
      'awardedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _checkAchievements() async {
    final quizState = Provider.of<QuizState>(context, listen: false);
    if (quizState.score == quizState.questions.length) {
      await _awardBadge('Perfect Score');
    }
    if (quizState.totalPoints >= 50) {
      await _awardBadge('Quiz Master');
    }
  }

  Future<void> _updateStreak() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = doc.data() ?? {};
    final lastQuizDate = data['lastQuizDate']?.toDate();
    int streak = data['streak'] ?? 0;
    final today = DateTime.now();

    if (lastQuizDate == null ||
        lastQuizDate.day != today.day ||
        lastQuizDate.month != today.month ||
        lastQuizDate.year != today.year) {
      streak = lastQuizDate != null && today.difference(lastQuizDate).inDays == 1 ? streak + 1 : 1;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'lastQuizDate': FieldValue.serverTimestamp(),
        'streak': streak,
      }, SetOptions(merge: true));
    }
  }

  void _showExplanationDialog(BuildContext context) {
    final quizState = Provider.of<QuizState>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Quiz Results & Explanations',
          style: GoogleFonts.roboto(fontSize: _fontSize, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: quizState.questions.length,
            itemBuilder: (context, index) {
              final question = quizState.questions[index];
              final isCorrect = quizState.userAnswers[index] == question['correctAnswer'];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q${index + 1}: ${question['question']}',
                        style: GoogleFonts.roboto(fontSize: _fontSize, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Answer: ${quizState.userAnswers[index] != null ? question['options'][quizState.userAnswers[index]!] : "Not answered"}',
                        style: GoogleFonts.roboto(
                          fontSize: _fontSize - 2,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        'Correct Answer: ${question['options'][question['correctAnswer']]}',
                        style: GoogleFonts.roboto(fontSize: _fontSize - 2),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Explanation: ${question['explanation']}',
                        style: GoogleFonts.roboto(fontSize: _fontSize - 2, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.roboto(fontSize: _fontSize)),
          ),
        ],
      ),
    );
  }

  void _showAchievements() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Your Achievements', style: GoogleFonts.roboto(fontSize: _fontSize)),
        content: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('badges')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final badges = snapshot.data!.docs;
            return SizedBox(
              width: double.maxFinite,
              height: 200,
              child: ListView.builder(
                itemCount: badges.length,
                itemBuilder: (context, index) {
                  final badge = badges[index].data() as Map<String, dynamic>;
                  return ListTile(
                    leading: const Icon(Icons.star, color: Colors.yellow),
                    title: Text(badge['name'], style: GoogleFonts.roboto(fontSize: _fontSize)),
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.roboto(fontSize: _fontSize)),
          ),
        ],
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adjust Font Size', style: GoogleFonts.roboto(fontSize: _fontSize)),
        content: Slider(
          value: _fontSize,
          min: 12.0,
          max: 24.0,
          divisions: 6,
          label: _fontSize.toString(),
          onChanged: (value) => setState(() => _fontSize = value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.roboto(fontSize: _fontSize)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _regulationController.dispose();
    _yearController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  ThemeData _getTheme() {
    return _isDarkMode
        ? ThemeData.dark()
        : _isHighContrast
            ? ThemeData(
                primaryColor: Colors.black,
                scaffoldBackgroundColor: Colors.white,
                textTheme: GoogleFonts.robotoTextTheme().apply(bodyColor: Colors.black),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                ),
              )
            : ThemeData.light();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _getTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'EduQuiz: Academic Mastery',
            style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.blue[800],
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
            ),
            IconButton(
              icon: const Icon(Icons.text_fields),
              onPressed: () => _showFontSizeDialog(),
            ),
            IconButton(
              icon: const Icon(Icons.star),
              onPressed: _showAchievements,
            ),
            IconButton(
              icon: Icon(_isHighContrast ? Icons.brightness_low : Icons.brightness_high),
              onPressed: () => setState(() => _isHighContrast = !_isHighContrast),
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isDarkMode
                      ? [Colors.grey[900]!, Colors.grey[800]!]
                      : [Colors.blue[50]!, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Consumer<QuizState>(
                      builder: (context, quizState, child) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: quizState.showInputForm
                              ? _buildInputForm(context, quizState)
                              : _buildQuizInterface(context, quizState),
                        );
                      },
                    ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [Colors.red, Colors.blue, Colors.green, Colors.yellow],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputForm(BuildContext context, QuizState quizState) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: 'Quiz Configuration Title',
                  child: Text(
                    'Configure Your Quiz',
                    style: GoogleFonts.roboto(fontSize: _fontSize + 4, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'Department Dropdown',
                  child: DropdownButtonFormField<String>(
                    value: _department,
                    decoration: InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: _departments
                        .map((dept) => DropdownMenuItem(value: dept, child: Text(dept)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _department = value!;
                        _semester = _semesters.first;
                        _courseCode = _courses[_department]![_semester]!.first['code']!;
                        _unitType = 'Unit I';
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'Semester Dropdown',
                  child: DropdownButtonFormField<String>(
                    value: _semester,
                    decoration: InputDecoration(
                      labelText: 'Semester',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: _semesters
                        .map((sem) => DropdownMenuItem(value: sem, child: Text(sem)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _semester = value!;
                        _courseCode = _courses[_department]![_semester]!.first['code']!;
                        _unitType = 'Unit I';
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'Course Dropdown',
                  child: DropdownButtonFormField<String>(
                    value: _courseCode,
                    decoration: InputDecoration(
                      labelText: 'Course',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: _courses[_department]![_semester]!
                        .map((course) => DropdownMenuItem(
                              value: course['code'],
                              child: Text('${course['code']} - ${course['name']}'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _courseCode = value!;
                        _unitType = 'Unit I';
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'Unit Dropdown',
                  child: DropdownButtonFormField<String>(
                    value: _unitType,
                    decoration: InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: ['Unit I', 'Unit II', 'Unit III', 'Unit IV', 'Unit V']
                        .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                        .toList(),
                    onChanged: (value) => setState(() => _unitType = value!),
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'Regulation Input',
                  child: TextFormField(
                    controller: _regulationController,
                    decoration: InputDecoration(
                      labelText: 'Regulation (e.g., 2021)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter regulation' : null,
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'Year Input',
                  child: TextFormField(
                    controller: _yearController,
                    decoration: InputDecoration(
                      labelText: 'Year (e.g., 2025)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter year' : null,
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'Language Dropdown',
                  child: DropdownButtonFormField<String>(
                    value: _language,
                    decoration: InputDecoration(
                      labelText: 'Language',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: ['English']
                        .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                        .toList(),
                    onChanged: (value) => setState(() => _language = value!),
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'Practice Mode Toggle',
                  child: SwitchListTile(
                    title: Text('Practice Mode', style: GoogleFonts.roboto(fontSize: _fontSize)),
                    value: _isPracticeMode,
                    onChanged: (value) => setState(() => _isPracticeMode = value),
                  ),
                ),
                Semantics(
                  label: 'Immediate Feedback Toggle',
                  child: SwitchListTile(
                    title: Text('Show Immediate Feedback', style: GoogleFonts.roboto(fontSize: _fontSize)),
                    value: _showImmediateFeedback,
                    onChanged: (value) => setState(() => _showImmediateFeedback = value),
                  ),
                ),
                Semantics(
                  label: 'Daily Reminder Toggle',
                  child: SwitchListTile(
                    title: Text('Enable Daily Reminders', style: GoogleFonts.roboto(fontSize: _fontSize)),
                    value: false, // Replace with state variable if needed
                    onChanged: (value) {
                      if (value) _scheduleDailyReminder();
                    },
                  ),
                ),
                if (quizState.showRetryButton && quizState.lastErrorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    quizState.lastErrorMessage!,
                    style: GoogleFonts.roboto(color: Colors.red, fontSize: _fontSize),
                  ),
                  const SizedBox(height: 16),
                  _buildAnimatedButton(
                    text: 'Retry',
                    color: Colors.orange,
                    onPressed: () => _generateQuestions(context),
                  ),
                ],
                const SizedBox(height: 24),
                Semantics(
                  label: 'Start Quiz Button',
                  child: _buildAnimatedButton(
                    text: 'Start Quiz',
                    color: Colors.blue[800]!,
                    onPressed: () => _generateQuestions(context),
                  ),
                ),
                Semantics(
                  label: 'Resume Quiz Button',
                  child: _buildAnimatedButton(
                    text: 'Resume Quiz',
                    color: Colors.green,
                    onPressed: () => _resumeQuiz(context),
                  ),
                ),
                Semantics(
                  label: 'Load Offline Quiz Button',
                  child: _buildAnimatedButton(
                    text: 'Load Offline Quiz',
                    color: Colors.grey,
                    onPressed: () => _loadCachedQuiz(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizInterface(BuildContext context, QuizState quizState) {
    if (quizState.questions.isEmpty) {
      return Center(
        child: Text(
          'No questions available. Please try again.',
          style: GoogleFonts.roboto(fontSize: _fontSize),
        ),
      );
    }

    final question = quizState.questions[quizState.currentQuestionIndex];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: 'Progress Indicator',
            child: CircularPercentIndicator(
              radius: 50.0,
              lineWidth: 8.0,
              percent: (quizState.currentQuestionIndex + 1) / quizState.questions.length,
              center: Text(
                '${quizState.currentQuestionIndex + 1}/${quizState.questions.length}',
                style: GoogleFonts.roboto(fontSize: _fontSize, fontWeight: FontWeight.bold),
              ),
              progressColor: Colors.blue[800],
              backgroundColor: Colors.grey[200]!,
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Question Navigation Bar',
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: quizState.questions.length,
                itemBuilder: (context, index) {
                  Color bgColor = quizState.userAnswers[index] != null
                      ? (quizState.isQuizSubmitted &&
                              quizState.userAnswers[index] == quizState.questions[index]['correctAnswer']
                          ? Colors.green
                          : Colors.red)
                      : Colors.grey;
                  return GestureDetector(
                    onTap: () => setState(() => quizState.currentQuestionIndex = index),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      width: 40,
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.roboto(color: Colors.white, fontSize: _fontSize),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (quizState.feedbackMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                quizState.feedbackMessage!,
                style: GoogleFonts.roboto(color: Colors.orange, fontSize: _fontSize),
              ),
            ),
          Semantics(
            label: 'Question Card',
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${quizState.currentQuestionIndex + 1}',
                      style: GoogleFonts.roboto(fontSize: _fontSize, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question['question'],
                      style: GoogleFonts.roboto(fontSize: _fontSize),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(
                      question['options'].length,
                      (index) => Semantics(
                        label: 'Option ${index + 1}',
                        child: RadioListTile<int>(
                          title: Text(
                            question['options'][index],
                            style: GoogleFonts.roboto(fontSize: _fontSize - 2),
                          ),
                          value: index,
                          groupValue: quizState.userAnswers[quizState.currentQuestionIndex],
                          onChanged: quizState.isQuizSubmitted
                              ? null
                              : (value) {
                                  quizState.updateAnswer(quizState.currentQuestionIndex, value);
                                },
                          activeColor: Colors.blue[800],
                        ),
                      ),
                    ),
                    if (quizState.isQuizSubmitted)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quizState.userAnswers[quizState.currentQuestionIndex] ==
                                      question['correctAnswer']
                                  ? 'Correct! (+10 points)'
                                  : 'Incorrect. Correct Answer: ${question['options'][question['correctAnswer']]}',
                              style: GoogleFonts.roboto(
                                color: quizState.userAnswers[quizState.currentQuestionIndex] ==
                                        question['correctAnswer']
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: _fontSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if ((_isPracticeMode || _showImmediateFeedback) &&
                        quizState.userAnswers[quizState.currentQuestionIndex] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          'Explanation: ${question['explanation']}',
                          style: GoogleFonts.roboto(
                            fontSize: _fontSize - 2,
                            fontStyle: FontStyle.italic,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Semantics(
                label: 'Previous Question Button',
                child: _buildAnimatedButton(
                  text: 'Previous',
                  color: Colors.blue[800]!,
                  onPressed: quizState.currentQuestionIndex > 0 ? quizState.previousQuestion : null,
                ),
              ),
              Semantics(
                label: 'Next Question Button',
                child: _buildAnimatedButton(
                  text: 'Next',
                  color: Colors.blue[800]!,
                  onPressed: quizState.currentQuestionIndex < quizState.questions.length - 1
                      ? quizState.nextQuestion
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!_isPracticeMode && !quizState.isQuizSubmitted)
            Center(
              child: Semantics(
                label: 'Submit Quiz Button',
                child: _buildAnimatedButton(
                  text: 'Submit Quiz',
                  color: Colors.blue[800]!,
                  onPressed: quizState.userAnswers.contains(null)
                      ? null
                      : () async {
                          quizState.submitQuiz();
                          if (quizState.score / quizState.questions.length >= 0.8) {
                            _confettiController.play();
                          }
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            await FirebaseFirestore.instance
                                .collection('quizzes')
                                .doc('temp')
                                .collection(user.uid)
                                .doc('current_quiz')
                                .update({
                              'userAnswers': quizState.userAnswers,
                              'score': quizState.score,
                              'totalPoints': quizState.totalPoints,
                              'submittedAt': FieldValue.serverTimestamp(),
                            });
                          }
                          await _savePerformance();
                          await _checkAchievements();
                          await _updateStreak();
                          _showExplanationDialog(context);
                        },
                ),
              ),
            ),
          if (quizState.isQuizSubmitted)
            Center(
              child: Column(
                children: [
                  Text(
                    'Your Score: ${quizState.score} / ${quizState.questions.length}',
                    style: GoogleFonts.roboto(fontSize: _fontSize + 4, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Total Points: ${quizState.totalPoints}',
                    style: GoogleFonts.roboto(fontSize: _fontSize + 2, color: Colors.blue[800]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    quizState.score / quizState.questions.length >= 0.8
                        ? 'Awesome job! You\'re a quiz master!'
                        : quizState.score / quizState.questions.length >= 0.5
                            ? 'Good effort! Keep practicing!'
                            : 'Don\'t worry, try again to boost your score!',
                    style: GoogleFonts.roboto(fontSize: _fontSize, fontStyle: FontStyle.italic),
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      final data = snapshot.data!.data() as Map<String, dynamic>?;
                      final streak = data?['streak'] ?? 0;
                      return Text(
                        'Current Streak: $streak days 🔥',
                        style: GoogleFonts.roboto(fontSize: _fontSize, color: Colors.orange),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    label: 'Restart Quiz Button',
                    child: _buildAnimatedButton(
                      text: 'Restart Quiz',
                      color: Colors.blue[800]!,
                      onPressed: () {
                        quizState.resetQuiz();
                        _suggestTopics();
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton({
    required String text,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      transform: Matrix4.identity()..scale(onPressed != null ? 1.0 : 0.95),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: onPressed != null ? 4 : 0,
        ),
        child: Text(
          text,
          style: GoogleFonts.roboto(fontSize: _fontSize, color: Colors.white),
        ),
      ),
    );
  }
}