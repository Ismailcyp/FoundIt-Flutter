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
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  
  String? _selectedCategory; 
  
  bool _isNew = true; 
  bool _isLoading = false;
  
  String? _titleError;
  String? _priceError;
  String? _categoryError; 

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  final Color _primaryColor = const Color(0xFFB5E575); 
  final Color _textColor = const Color(0xFF1E1E1E);
  final Color _subtitleColor = const Color(0xFF8E8E8E);
  final Color _inputFillColor = const Color(0xFFF5F5F5);
  final Color _bgColor = Colors.white;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source, 
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(pickedFile); 
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick and compress image.')),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                  title: Text('Photo Gallery', style: TextStyle(color: _textColor, fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt_outlined, color: _textColor),
                  title: Text('Camera', style: TextStyle(color: _textColor, fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
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
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close, color: _textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Listing',
          style: TextStyle(
            color: _textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Photos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textColor),
                  ),
                  Text(
                    '${_selectedImages.length}/3',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _subtitleColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
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
                              border: Border.all(color: Colors.grey.shade200),
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
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                                  ],
                                ),
                                child: const Icon(Icons.close, size: 14, color: Colors.redAccent),
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
                            color: _inputFillColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined, color: Colors.green[800], size: 32),
                              const SizedBox(height: 8),
                              Text('Add', style: TextStyle(color: Colors.green[800], fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildLabel('Title'),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                style: TextStyle(color: _textColor),
                decoration: _getSharedInputDecoration('e.g., iPhone 13 Pro Max', errorText: _titleError),
              ),
              const SizedBox(height: 20),

              _buildLabel('Category'),
              const SizedBox(height: 8),
              _buildCategoryDropdown(),
              const SizedBox(height: 20),

              _buildLabel('Price'),
              const SizedBox(height: 8),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: _textColor),
                decoration: _getSharedInputDecoration('e.g., 1500', errorText: _priceError),
              ),
              const SizedBox(height: 20),

              _buildLabel('Condition'),
              const SizedBox(height: 8),
              _buildConditionToggle(),
              const SizedBox(height: 20),

              _buildLabel('Description (Optional)'),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                maxLines: 4, 
                style: TextStyle(color: _textColor),
                decoration: _getSharedInputDecoration('Describe the item, condition, battery health, etc.'),
              ),
              const SizedBox(height: 40),

              _buildPostButton(),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: _subtitleColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Product will be reviewed by our team before being listed. A status email will be sent shortly.",
                      style: TextStyle(color: _subtitleColor, fontSize: 12, height: 1.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }




  Widget _buildCategoryDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categories').orderBy('createdAt').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 56,
            decoration: BoxDecoration(color: _inputFillColor, borderRadius: BorderRadius.circular(12)),
            child: Center(child: CircularProgressIndicator(color: _primaryColor)),
          );
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

        if (dynamicCategories.isNotEmpty && (_selectedCategory == null || !dynamicCategories.contains(_selectedCategory))) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedCategory = dynamicCategories.first);
          });
        }

        return DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          icon: Icon(Icons.keyboard_arrow_down, color: _subtitleColor),
          dropdownColor: Colors.white,
          style: TextStyle(color: _textColor, fontSize: 16),
          decoration: _getSharedInputDecoration('Select a category', errorText: _categoryError),
          items: dynamicCategories.map((String category) {
            return DropdownMenuItem<String>(value: category, child: Text(category));
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue;
              _categoryError = null; 
            });
          },
        );
      },
    );
  }

  Widget _buildConditionToggle() {
    return Container(
      height: 52,
      decoration: BoxDecoration(color: _inputFillColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isNew = true),
              child: Container(
                decoration: BoxDecoration(
                  color: _isNew ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _isNew ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
                ),
                margin: const EdgeInsets.all(4),
                child: Center(
                  child: Text('Brand New', style: TextStyle(color: _isNew ? Colors.green[800] : _subtitleColor, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isNew = false),
              child: Container(
                decoration: BoxDecoration(
                  color: !_isNew ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !_isNew ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
                ),
                margin: const EdgeInsets.all(4),
                child: Center(
                  child: Text('Used', style: TextStyle(color: !_isNew ? Colors.green[800] : _subtitleColor, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () async {
          setState(() {
            _titleError = null;
            _priceError = null;
            _categoryError = null;
          });

          bool isValid = true;

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
            
            List<String> base64Images = [];
            for (int i = 0; i < _selectedImages.length; i++) {
              final bytes = await File(_selectedImages[i].path).readAsBytes();
              final String base64String = base64Encode(bytes);
              base64Images.add("data:image/jpeg;base64,$base64String");
            }

            final newListingData = {
              "title": _titleController.text.trim(),
              "category": _selectedCategory ?? 'Other',
              "price": int.tryParse(_priceController.text.trim()) ?? 0,
              "isNew": _isNew,
              "description": _descController.text.trim(),
              "images": base64Images, 
              "sellerId": uid, 
              "status": "pending", 
              "createdAt": FieldValue.serverTimestamp(),
            };
            
            await FirebaseFirestore.instance.collection('listings').add(newListingData);

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
          backgroundColor: _primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Text('Post Listing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[900])),
      ),
    );
  }


  Widget _buildLabel(String text) {
    return Padding(
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
    );
  }

  InputDecoration _getSharedInputDecoration(String hint, {String? errorText}) {
    return InputDecoration(
      hintText: hint,
      errorText: errorText,
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
      
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
      ),
    );
  }
}