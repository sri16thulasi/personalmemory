import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class TaskInputPage extends StatefulWidget {
  @override
  _TaskInputPageState createState() => _TaskInputPageState();
}

class _TaskInputPageState extends State<TaskInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _taskController = TextEditingController();
  final _courseController = TextEditingController();
  final _typeController = TextEditingController();
  final _timeController = TextEditingController();
  final _yearController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  String _predictedPriority = '';
  bool _isEditing = false;
  String? _editingDocId;

  final List<Map<String, String>> _quizzes = [
    {'question': 'What is 7 × 8?', 'answer': '56', 'category': 'Math'},
    {'question': 'What is the capital of France?', 'answer': 'Paris', 'category': 'General Knowledge'},
    {'question': 'What gas do plants use for photosynthesis?', 'answer': 'Carbon Dioxide', 'category': 'Science'},
    {'question': 'Solve: 2x + 4 = 10', 'answer': 'x = 3', 'category': 'Math'},
    {'question': 'Who wrote "Romeo and Juliet"?', 'answer': 'William Shakespeare', 'category': 'Literature'},
    {'question': 'What is the chemical symbol for water?', 'answer': 'H₂O', 'category': 'Science'},
    {'question': 'What is 12 ÷ 3?', 'answer': '4', 'category': 'Math'},
    {'question': 'Which planet is known as the Red Planet?', 'answer': 'Mars', 'category': 'Science'},
  ];
  Map<String, String>? _currentQuiz;
  bool _showQuizAnswer = false;

  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  @override
  void initState() {
    super.initState();
    _generateRandomQuiz();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    _notificationsPlugin.initialize(settings);

    if (!kIsWeb) {
      _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    _courseController.dispose();
    _typeController.dispose();
    _timeController.dispose();
    _yearController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _generateRandomQuiz() {
    setState(() {
      _currentQuiz = _quizzes[Random().nextInt(_quizzes.length)];
      _showQuizAnswer = false;
    });
  }

  void _clearForm() {
    setState(() {
      _taskController.clear();
      _courseController.clear();
      _typeController.clear();
      _timeController.clear();
      _yearController.clear();
      _locationController.clear();
      _dueDate = DateTime.now();
      _predictedPriority = '';
      _isEditing = false;
      _editingDocId = null;
      _formKey.currentState?.reset();
    });
    print('Form cleared manually');
  }

  Future<void> _scheduleNotification(String taskId, String taskName, DateTime dueDate) async {
    final reminderTime = tz.TZDateTime.from(
      dueDate.subtract(Duration(days: 1)).copyWith(hour: 9, minute: 0, second: 0),
      tz.local,
    );
    if (reminderTime.isBefore(tz.TZDateTime.now(tz.local))) {
      print('Reminder time is in the past for task: $taskName');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for upcoming task due dates',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notificationsPlugin.zonedSchedule(
      taskId.hashCode,
      'Task Reminder: $taskName',
      'Due on ${dueDate.toLocal().toString().split(' ')[0]}',
      reminderTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exact,
    );
    print('Scheduled notification for task: $taskName at $reminderTime');
  }

  void _editTask(Map<String, dynamic> task, String docId) {
    setState(() {
      _taskController.text = task['task'];
      _courseController.text = task['course'];
      _typeController.text = task['type'];
      _dueDate = DateTime.parse(task['due_date']);
      _timeController.text = task['time'].toString();
      _yearController.text = task['year'].toString();
      _locationController.text = task['location'];
      _predictedPriority = task['priority'];
      _isEditing = true;
      _editingDocId = docId;
    });
  }

  String _estimatePriority({
    required int daysToDue,
    required double time,
    required String type,
  }) {
    if (daysToDue <= 3 || time > 5.0) {
      return 'high';
    } else if (daysToDue <= 7 || time > 2.0) {
      return 'medium';
    } else {
      return 'low';
    }
  }

  Future<void> _deleteTask(String docId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(docId)
          .delete();
      await _notificationsPlugin.cancel(docId.hashCode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task deleted successfully!')),
      );
    } catch (e) {
      print('Error deleting task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting task: $e')),
      );
    }
  }

  Future<void> _submitTask() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final apiUrl = kIsWeb
          ? 'http://192.168.50.84:5000/predict'
          : 'http://192.168.50.84:5000/predict';
      print('Sending request to $apiUrl...');
      final time = double.tryParse(_timeController.text) ?? 0.0;
      final year = int.tryParse(_yearController.text) ?? 1;
      print('Raw inputs: task=${_taskController.text}, course=${_courseController.text}, type=${_typeController.text}, days_to_due=${_dueDate.difference(DateTime.now()).inDays}, time=$time, year=$year, location=${_locationController.text}');
      final requestBody = jsonEncode({
        'task': _taskController.text,
        'course': _courseController.text,
        'type': _typeController.text,
        'days_to_due': _dueDate.difference(DateTime.now()).inDays,
        'time': time,
        'year': year,
        'location': _locationController.text,
      });
      print('Request body: $requestBody');

      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: requestBody,
          )
          .timeout(Duration(seconds: 20), onTimeout: () {
        throw Exception('Request timed out: Server may be down or unreachable');
      });

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData.containsKey('priority')) {
            setState(() {
              _predictedPriority = responseData['priority'];
            });
          } else {
            throw Exception('Invalid response: Missing priority field');
          }
        } on FormatException catch (e) {
          throw Exception('Failed to decode server response: $e');
        }
      } else {
        print('Server failed with status ${response.statusCode}, using local estimation');
        setState(() {
          _predictedPriority = _estimatePriority(
            daysToDue: _dueDate.difference(DateTime.now()).inDays,
            time: time,
            type: _typeController.text,
          );
        });
      }

      String? docId;
      final taskData = {
        'task': _taskController.text,
        'course': _courseController.text,
        'type': _typeController.text,
        'due_date': _dueDate.toIso8601String(),
        'time': time,
        'year': year,
        'location': _locationController.text,
        'priority': _predictedPriority,
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (_isEditing && _editingDocId != null) {
        docId = _editingDocId;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .doc(_editingDocId)
            .update(taskData);
        print('Updated task with ID: $_editingDocId');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task updated successfully! Priority: $_predictedPriority')),
        );
      } else {
        final docRef = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .add(taskData);
        docId = docRef.id;
        print('Added new task with ID: ${docRef.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task added successfully! Priority: $_predictedPriority')),
        );
      }

      if (docId != null) {
        await _scheduleNotification(docId, _taskController.text, _dueDate);
      }

      print('Clearing form fields...');
      setState(() {
        _taskController.clear();
        _courseController.clear();
        _typeController.clear();
        _timeController.clear();
        _yearController.clear();
        _locationController.clear();
        _dueDate = DateTime.now();
        _predictedPriority = '';
        _isEditing = false;
        _editingDocId = null;
        _formKey.currentState?.reset();
      });
    } catch (e) {
      print('Error: $e');
      String errorMessage = e.toString().contains('timed out')
          ? 'Server is unreachable. Using local priority estimation.'
          : 'Error ${_isEditing ? 'updating' : 'adding'} task: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      final time = double.tryParse(_timeController.text) ?? 0.0;
      setState(() {
        _predictedPriority = _estimatePriority(
          daysToDue: _dueDate.difference(DateTime.now()).inDays,
          time: time,
          type: _typeController.text,
        );
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      String? docId;
      final year = int.tryParse(_yearController.text) ?? 1;
      final taskData = {
        'task': _taskController.text,
        'course': _courseController.text,
        'type': _typeController.text,
        'due_date': _dueDate.toIso8601String(),
        'time': time,
        'year': year,
        'location': _locationController.text,
        'priority': _predictedPriority,
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (_isEditing && _editingDocId != null) {
        docId = _editingDocId;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .doc(_editingDocId)
            .update(taskData);
        print('Updated task with ID: $_editingDocId (fallback)');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task updated with estimated priority: $_predictedPriority')),
        );
      } else {
        final docRef = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .add(taskData);
        docId = docRef.id;
        print('Added new task with ID: ${docRef.id} (fallback)');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task added with estimated priority: $_predictedPriority')),
        );
      }

      if (docId != null) {
        await _scheduleNotification(docId, _taskController.text, _dueDate);
      }

      print('Clearing form fields (fallback)...');
      setState(() {
        _taskController.clear();
        _courseController.clear();
        _typeController.clear();
        _timeController.clear();
        _yearController.clear();
        _locationController.clear();
        _dueDate = DateTime.now();
        _predictedPriority = '';
        _isEditing = false;
        _editingDocId = null;
        _formKey.currentState?.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text('Please sign in to access tasks.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to the Task Manager',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Your Tasks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('tasks')
                    .orderBy('priority', descending: true)
                    .orderBy('due_date')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print('StreamBuilder error: ${snapshot.error}');
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Failed to load tasks: ${snapshot.error}',
                          style: TextStyle(color: Colors.red),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'If the error mentions a missing index, open the Firebase Console, go to Firestore > Indexes, and create a composite index for the "users/{userId}/tasks" collection with fields: priority (Descending), due_date (Ascending).',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    );
                  }
                  if (!snapshot.hasData) {
                    print('StreamBuilder: No data yet, loading...');
                    return Center(child: CircularProgressIndicator());
                  }
                  final tasks = snapshot.data!.docs;
                  print('StreamBuilder: Loaded ${tasks.length} tasks');
                  if (tasks.isEmpty) {
                    return Text(
                      'No tasks yet. Add one below!',
                      style: TextStyle(color: Colors.grey),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index].data() as Map<String, dynamic>;
                      final docId = tasks[index].id;
                      final dueDate = DateTime.parse(task['due_date']);
                      final priority = task['priority'];
                      print('Displaying task $index: ${task['task']}, ID: $docId');
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(
                            task['task'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Course: ${task['course']} | Due: ${dueDate.toLocal().toString().split(' ')[0]} | Priority: $priority',
                          ),
                          tileColor: priority == 'high'
                              ? Colors.red[50]
                              : priority == 'medium'
                                  ? Colors.yellow[50]
                                  : Colors.green[50],
                          onTap: () => _editTask(task, docId),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTask(docId),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 20),
              Text(
                'Daily Quiz for Students',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 10),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category: ${_currentQuiz?['category'] ?? 'Loading...'}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _currentQuiz?['question'] ?? 'Loading...',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      _showQuizAnswer
                          ? Text(
                              'Answer: ${_currentQuiz?['answer'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 16, color: Colors.green),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showQuizAnswer = true;
                                });
                              },
                              child: Text('Show Answer'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                              ),
                            ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _generateRandomQuiz,
                        child: Text('Next Quiz'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                _isEditing ? 'Edit Task' : 'Add New Task',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        labelText: 'Task',
                        hintText: 'e.g., Assignment',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter task' : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _courseController,
                      decoration: InputDecoration(
                        labelText: 'Course',
                        hintText: 'e.g., Cloud Computing',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter course' : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _typeController,
                      decoration: InputDecoration(
                        labelText: 'Type',
                        hintText: 'e.g., Written Work',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter type' : null,
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _dueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) setState(() => _dueDate = picked);
                      },
                      child: Text('Select Due Date'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        labelText: 'Time (hours)',
                        hintText: 'e.g., 1.5',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter time';
                        if (double.tryParse(value) == null) return 'Enter a valid number (e.g., 1.5)';
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _yearController,
                      decoration: InputDecoration(
                        labelText: 'Year',
                        hintText: 'e.g., 1',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter year';
                        if (int.tryParse(value) == null) return 'Enter a valid number (e.g., 1)';
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        hintText: 'e.g., College',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter location' : null,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: _clearForm,
                          child: Text('Clear'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _submitTask();
                            }
                          },
                          child: Text(_isEditing ? 'Update Task' : 'Add Task'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Predicted Priority: $_predictedPriority',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthScreen extends StatelessWidget {
  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TaskInputPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing in: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Task Manager',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _signInAnonymously(context),
              child: Text('Sign In Anonymously'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}