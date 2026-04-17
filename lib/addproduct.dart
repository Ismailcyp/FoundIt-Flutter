import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  // --- STATE VARIABLES ---
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  
  // CHANGED: Using a nullable String for the dropdown is much cleaner than a TextEditingController
  String? _selectedCategory; 
  
  bool _isNew = true; // true = New, false = Used
  bool _isLoading = false;
  
  String? _titleError;
  String? _priceError;
  String? _categoryError; 

  // Image Picker State
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  // Colors
  final Color _bgColor = const Color.fromARGB(255, 38, 2, 58);
  final Color _inputBgColor = const Color(0xFF1B1B28);
  final Color _primaryPurple = const Color(0xFF6E56FF);
  final Color _textSecondary = const Color(0xFF8E8E9F);

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // --- IMAGE PICKER LOGIC ---
  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length >= 3) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, 
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(pickedFile);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  void _showImageSourceActionSheet() {
    if (_selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 images allowed')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: _inputBgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('Photo Gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text('Camera', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: _primaryPurple),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Listing',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: "syne",
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Upload Section
              Text(
                'Photos (${_selectedImages.length}/3)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const SizedBox(height: 12),
              
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...List.generate(_selectedImages.length, (index) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 16),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: FileImage(File(_selectedImages[index].path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: -8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 160, 8, 8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    if (_selectedImages.length < 3)
                      GestureDetector(
                        onTap: _showImageSourceActionSheet,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: _inputBgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _primaryPurple.withOpacity(0.5), style: BorderStyle.solid),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, color: _primaryPurple, size: 28),
                              const SizedBox(height: 8),
                              Text('Add', style: TextStyle(color: _textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 2. Title
              _buildLabel('Title'),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: _getSharedInputDecoration('e.g., iPhone 13 Pro Max', errorText: _titleError),
              ),
              const SizedBox(height: 20),

              // 3. Category (UPDATED TO BE DYNAMIC)
              _buildLabel('Category'),
              const SizedBox(height: 8),
              _buildCategoryDropdown(),
              const SizedBox(height: 20),

              // 4. Price
              _buildLabel('Price (EGP)'),
              const SizedBox(height: 8),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _getSharedInputDecoration('e.g., 15000', errorText: _priceError),
              ),
              const SizedBox(height: 20),

              // 5. Condition Toggle
              _buildLabel('Condition'),
              const SizedBox(height: 8),
              _buildConditionToggle(),
              const SizedBox(height: 20),

              // 6. Description
              _buildLabel('Description (Optional)'),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                maxLines: 4, 
                style: const TextStyle(color: Colors.white),
                decoration: _getSharedInputDecoration('Describe the item, condition, battery health, etc.'),
              ),
              const SizedBox(height: 40),

              // 7. Post Button
              _buildPostButton(),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Product will be Reviewed by Our Team before being listed.\nStatus email will be sent shortly!",
                  style: TextStyle(color: Colors.white, fontFamily: "syne", fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
    );
  }

  // UPDATED: Dynamic Category Dropdown using StreamBuilder
  Widget _buildCategoryDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categories').orderBy('createdAt').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 56, child: Center(child: CircularProgressIndicator()));
        }

        List<String> dynamicCategories = [];
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['name'] != null) {
              dynamicCategories.add(data['name']);
            }
          }
        }

        // Safety check to set a default value if one isn't selected yet
        if (dynamicCategories.isNotEmpty && (_selectedCategory == null || !dynamicCategories.contains(_selectedCategory))) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedCategory = dynamicCategories.first);
          });
        }

        return DropdownButtonFormField<String>(
          value: _selectedCategory,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          dropdownColor: _inputBgColor,
          style: const TextStyle(color: Colors.white),
          decoration: _getSharedInputDecoration('Select a category', errorText: _categoryError),
          items: dynamicCategories.map((String category) {
            return DropdownMenuItem<String>(value: category, child: Text(category));
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue;
              _categoryError = null; // Clear any error once selected
            });
          },
        );
      },
    );
  }

  Widget _buildConditionToggle() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: _inputBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isNew = true),
              child: Container(
                decoration: BoxDecoration(
                  color: _isNew ? _primaryPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    'Brand New',
                    style: TextStyle(
                      color: _isNew ? Colors.white : _textSecondary,
                      fontWeight: _isNew ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isNew = false),
              child: Container(
                decoration: BoxDecoration(
                  color: !_isNew ? _primaryPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    'Used',
                    style: TextStyle(
                      color: !_isNew ? Colors.white : _textSecondary,
                      fontWeight: !_isNew ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostButton() {
    return Center(
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: _primaryPurple,
          boxShadow: [
            BoxShadow(color: _primaryPurple.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : () async {
            setState(() {
              _titleError = null;
              _priceError = null;
              _categoryError = null;
            });

            bool isValid = true;

            // Validation
            if (_titleController.text.trim().isEmpty) {
              _titleError = 'Title is required';
              isValid = false;
            }
            if (_selectedCategory == null || _selectedCategory!.isEmpty) {
              _categoryError = 'Category is required';
              isValid = false;
            }
            if (_priceController.text.trim().isEmpty) {
              _priceError = 'Price is required';
              isValid = false;
            }
            if (_selectedImages.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please add at least one photo')),
              );
              isValid = false;
            }

            if (!isValid) return;

            setState(() => _isLoading = true);

            try {
              final String uid = FirebaseAuth.instance.currentUser!.uid;
              
              // 1. Convert Images to Base64 Text
              List<String> base64Images = [];
              for (int i = 0; i < _selectedImages.length; i++) {
                final bytes = await File(_selectedImages[i].path).readAsBytes();
                final String base64String = base64Encode(bytes);
                base64Images.add("data:image/jpeg;base64,$base64String");
              }

              final newListingData = {
                "title": _titleController.text.trim(),
                "category": _selectedCategory ?? 'Other', // Used our new state variable
                "price": int.tryParse(_priceController.text.trim()) ?? 0,
                "isNew": _isNew,
                "description": _descController.text.trim(),
                "images": base64Images, 
                "sellerId": uid, 
                // CRITICAL FIX: Save as pending so it hits the Admin Queue!
                "status": "pending", 
                "createdAt": FieldValue.serverTimestamp(),
              };
              
              await FirebaseFirestore.instance
                  .collection('listings')
                  .add(newListingData);

              if (mounted) {
                setState(() => _isLoading = false);
                Navigator.pop(context); 
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Listing sent for review. Stay Tuned!')),
                );
              }
            } catch (e) {
              if (mounted) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to post: $e')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : const Text('Post Listing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }

  InputDecoration _getSharedInputDecoration(String hint, {String? errorText}) {
    return InputDecoration(
      hintText: hint,
      errorText: errorText,
      hintStyle: TextStyle(color: _textSecondary.withOpacity(0.6), fontSize: 14),
      filled: true,
      fillColor: _inputBgColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: _primaryPurple.withOpacity(0.5)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }
}