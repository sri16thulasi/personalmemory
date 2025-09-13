import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitPost(String content) async {
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter some content', style: GoogleFonts.lora(fontSize: 14))),
      );
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please sign in to post', style: GoogleFonts.lora(fontSize: 14))),
      );
      return;
    }
    setState(() {
      _isPosting = true;
    });
    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'userName': user.displayName ?? 'Anonymous',
        'content': content,
        'likes': 0,
        'timestamp': Timestamp.now(),
      });
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post submitted successfully', style: GoogleFonts.lora(fontSize: 14))),
      );
    } catch (e) {
      print('Error submitting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit post: $e', style: GoogleFonts.lora(fontSize: 14))),
      );
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Community', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .orderBy('timestamp', descending: true)
                    .limit(50)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print('Error loading posts: ${snapshot.error}');
                    return Center(child: Text('Error loading posts', style: GoogleFonts.lora(fontSize: 14)));
                  }
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  final posts = snapshot.data!.docs;
                  if (posts.isEmpty) {
                    return Center(child: Text('No posts yet', style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700])));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post['userName'] ?? 'Anonymous',
                                style: GoogleFonts.lora(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                              ),
                              SizedBox(height: 8),
                              Text(
                                post['content'],
                                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.thumb_up, color: Colors.blue[900]),
                                    onPressed: () async {
                                      try {
                                        await FirebaseFirestore.instance.collection('posts').doc(post.id).update({
                                          'likes': FieldValue.increment(1),
                                        });
                                      } catch (e) {
                                        print('Error liking post: $e');
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Failed to like post', style: GoogleFonts.lora(fontSize: 14))),
                                        );
                                      }
                                    },
                                  ),
                                  Text(
                                    '${post['likes'] ?? 0} Likes',
                                    style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Share your thoughts...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isPosting ? null : () => _submitPost(_controller.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isPosting
                        ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Post', style: GoogleFonts.lora(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
