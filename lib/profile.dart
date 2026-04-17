import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // NEW: Email Controller
  
  bool _isLoading = true;
  bool _isSaving = false;
  
  // NEW: Image variables
  String? _base64Image;
  final ImagePicker _picker = ImagePicker();

  final Color _bgColor = const Color.fromARGB(255, 38, 2, 58);
  final Color _cardColor = const Color(0xFF1B1B28);
  final Color _primaryPurple = const Color(0xFF6E56FF);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        
        String fName = data['firstName'] ?? '';
        String lName = data['lastName'] ?? '';
        
        _nameController.text = "$fName $lName".trim(); 
        _phoneController.text = data['phone'] ?? '';
        _emailController.text = data['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';
        
        // Load existing profile image if they have one
        if (data.containsKey('profileImage')) {
          _base64Image = data['profileImage'];
        }
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- NEW: PICK IMAGE FUNCTION ---
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Compresses the image to save database space
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        final String base64String = base64Encode(bytes);
        
        setState(() {
          _base64Image = base64String;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image.')),
        );
      }
    }
  }

  Future<void> _saveUserData() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      
      List<String> nameParts = _nameController.text.trim().split(' ');
      String fName = nameParts.isNotEmpty ? nameParts[0] : '';
      String lName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // Create the update map
      Map<String, dynamic> updateData = {
        'firstName': fName,
        'lastName': lName,
      };

      // Only add the image to the update if they actually picked one
      if (_base64Image != null) {
        updateData['profileImage'] = _base64Image;
      }

      await FirebaseFirestore.instance.collection('Users').doc(uid).update(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Safe image decoder (same as your store feed)
  MemoryImage? _getDecodedImage() {
    if (_base64Image == null || _base64Image!.isEmpty) return null;
    try {
      String cleanBase64 = _base64Image!;
      if (cleanBase64.contains(',')) {
        cleanBase64 = cleanBase64.split(',').last;
      }
      return MemoryImage(base64Decode(cleanBase64));
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryPurple))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // --- NEW: CLICKABLE AVATAR ---
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: _primaryPurple.withOpacity(0.2),
                          backgroundImage: _getDecodedImage(),
                          child: _base64Image == null
                              ? Icon(Icons.person, size: 50, color: _primaryPurple)
                              : null,
                        ),
                        // Little camera badge
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF6E56FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name is editable
                  _buildTextField('Full Name', _nameController, Icons.person_outline),
                  const SizedBox(height: 16),
                  
                  // NEW: Email is locked and read-only
                  _buildTextField('Email Address', _emailController, Icons.mail_outline, isReadOnly: true),
                  const SizedBox(height: 16),

                  // Phone is locked and read-only
                  _buildTextField('WhatsApp Number', _phoneController, Icons.phone_outlined, isNumber: true, isReadOnly: true),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false, bool isReadOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: isReadOnly, 
          keyboardType: isNumber ? TextInputType.phone : TextInputType.name,
          style: TextStyle(color: isReadOnly ? Colors.white54 : Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white54),
            suffixIcon: isReadOnly ? const Icon(Icons.verified, color: Colors.green, size: 20) : null,
            filled: true,
            fillColor: _cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}