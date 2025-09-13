/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RemindersPage extends StatefulWidget {
  @override
  _RemindersPageState createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final TextEditingController reminderController = TextEditingController();

  void addReminder() {
    FirebaseFirestore.instance.collection('reminders').add({
      'text': reminderController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    reminderController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reminders")),
      body: Column(
        children: [
          TextField(controller: reminderController, decoration: InputDecoration(labelText: "Enter reminder")),
          ElevatedButton(onPressed: addReminder, child: Text("Add Reminder")),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('reminders').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return ListTile(title: Text(doc['text']));
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}*/
