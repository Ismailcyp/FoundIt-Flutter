import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditListingScreen extends StatefulWidget {
  final Map<String, dynamic> itemData;
  final String docId;

  const EditListingScreen({super.key, required this.itemData, required this.docId});

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  bool _isLoading = false;

  final Color _primaryColor = const Color(0xFFB5E575);
  
  final Color _textColor = const Color(0xFF1E1E1E);
  final Color _subtitleColor = const Color(0xFF8E8E8E);
  final Color _bgColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.itemData['title']);
    _priceController = TextEditingController(text: widget.itemData['price'].toString());
    _descController = TextEditingController(text: widget.itemData['description']);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _updateListing() async {
    if (_titleController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in the title and price.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('listings').doc(widget.docId).update({
        'title': _titleController.text.trim(),
        'price': int.tryParse(_priceController.text.trim()) ?? 0,
        'description': _descController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing updated successfully!')),
        );
        Navigator.pop(context, {
          'title': _titleController.text.trim(),
          'price': int.tryParse(_priceController.text.trim()) ?? 0,
          'description': _descController.text.trim(),
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: Text(
          'Edit Listing', 
          style: TextStyle(color: _textColor, fontSize: 18, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green[800]))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField('Title', _titleController),
                    const SizedBox(height: 20),
                    
                    _buildTextField('Price (EGP)', _priceController, isNumber: true),
                    const SizedBox(height: 20),
                    
                    _buildTextField('Description', _descController, maxLines: 5),
                    const SizedBox(height: 40),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _updateListing,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Save Changes', 
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

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13, 
              fontWeight: FontWeight.w700, 
              color: Colors.grey.shade800,
              letterSpacing: 0.3,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          style: TextStyle(color: _textColor),
          decoration: InputDecoration(
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
      ],
    );
  }
}