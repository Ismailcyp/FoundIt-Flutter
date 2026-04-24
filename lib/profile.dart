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
  final TextEditingController _emailController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  
  String? _base64Image;
  final ImagePicker _picker = ImagePicker();

  final Color _primaryColor = const Color(0xFFB5E575);
  final Color _textColor = const Color(0xFF1E1E1E);
  final Color _subtitleColor = const Color(0xFF8E8E8E);
  final Color _bgColor = Colors.white;

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
        
        if (data.containsKey('profileImage')) {
          _base64Image = data['profileImage'];
        }
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 40, 
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

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Wrap(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: _textColor),
                title: Text('Choose from Gallery', style: TextStyle(color: _textColor, fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: _textColor),
                title: Text('Take a Photo', style: TextStyle(color: _textColor, fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
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

      Map<String, dynamic> updateData = {
        'firstName': fName,
        'lastName': lName,
      };

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
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: _textColor),
        title: Text('Edit Profile', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade100, height: 1.0),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green[800]))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          ),
                          child: CircleAvatar(
                            radius: 54,
                            backgroundColor: Colors.grey.shade100,
                            backgroundImage: _getDecodedImage(),
                            child: _base64Image == null
                                ? Icon(Icons.person_outline, size: 50, color: Colors.grey.shade400)
                                : null,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green[800],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildLabel('Full Name'),
                  _buildTextField(
                    controller: _nameController,
                    icon: Icons.person_outline,
                    hint: 'Your name',
                  ),
                  const SizedBox(height: 24),
                  
                  _buildLabel('Email Address'),
                  _buildTextField(
                    controller: _emailController,
                    icon: Icons.mail_outline,
                    hint: 'Email',
                    isReadOnly: true,
                  ),
                  const SizedBox(height: 24),

                  _buildLabel('WhatsApp Number'),
                  _buildTextField(
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    hint: 'Phone',
                    isReadOnly: true,
                  ),
                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[900])),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13, 
            fontWeight: FontWeight.w700, 
            color: Colors.grey.shade800,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isReadOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: isReadOnly,
      style: TextStyle(color: isReadOnly ? Colors.grey.shade500 : _textColor, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: isReadOnly ? Colors.grey.shade300 : Colors.grey.shade400, size: 22),
        suffixIcon: isReadOnly 
            ? Container(
                margin: const EdgeInsets.only(right: 12),
                child: Icon(Icons.verified_user, color: Colors.green.shade600, size: 18),
              ) 
            : null,
        filled: true,
        fillColor: isReadOnly ? Colors.grey.shade50 : Colors.white,
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
    );
  }
}