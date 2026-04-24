import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  final Color _primaryColor = const Color(0xFFB5E575);
  final Color _textColor = const Color(0xFF1E1E1E);
  final Color _subtitleColor = const Color(0xFF8E8E8E);
  final Color _bgColor = Colors.white;

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message.')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      
      await FirebaseFirestore.instance.collection('support_tickets').add({
        'uid': uid,
        'message': _messageController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'Open', 
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent! We will respond shortly.')),
        );
        Navigator.pop(context); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: _textColor),
        title: Text(
          'Contact Us', 
          style: TextStyle(color: _textColor, fontSize: 18, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
        
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.support_agent_outlined, size: 64, color: Colors.green[800]),
              ),
              const SizedBox(height: 32),
              
              Text(
                'How can we help you?',
                style: TextStyle(color: _textColor, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Found a bug, have a suggestion, or need help with a listing? Drop us a message below.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _subtitleColor, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 40),

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                  child: Text(
                    'Your Message', 
                    style: TextStyle(
                      fontSize: 13, 
                      fontWeight: FontWeight.w700, 
                      color: Colors.grey.shade800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: _messageController,
                maxLines: 6,
                style: TextStyle(color: _textColor),
                decoration: InputDecoration(
                  hintText: 'Type your message here...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.w400),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                  ),
                  
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green.shade700, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSending
                      ? const SizedBox(
                          height: 24, 
                          width: 24, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                        )
                      : Text(
                          'Send Message', 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[900])
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}