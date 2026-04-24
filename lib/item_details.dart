import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:FoundIT/edit_listing.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> itemData;
  final String docId;

  const ItemDetailsScreen({
    super.key,
    required this.itemData,
    required this.docId,
  });

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  int _currentPage = 0;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  
  late Map<String, dynamic> displayData;


  final Color _primaryColor = const Color(0xFFB5E575);
  final Color _textColor = const Color(0xFF1E1E1E);
  final Color _subtitleColor = const Color(0xFF8E8E8E);
  final Color _bgColor = const Color(0xFFF9F9F9);

  @override
  void initState() {
    super.initState();
    displayData = Map.from(widget.itemData); 
  }

  MemoryImage? _getMemoryImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      String cleanString = base64String.contains(',') ? base64String.split(',').last : base64String;
      return MemoryImage(base64Decode(cleanString));
    } catch (e) {
      return null;
    }
  }

  void _openFullScreenImage(List<dynamic> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          extendBodyBehindAppBar: true,
          body: PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final MemoryImage? img = _getMemoryImage(images[index] as String);
              if (img == null) return const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 50));
              
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: Image(image: img, fit: BoxFit.contain),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _markAsSold() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Mark as Sold?', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
        content: Text(
          'This will update the item status and remove it from the active feed. Are you sure?',
          style: TextStyle(color: _subtitleColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: _subtitleColor, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Mark Sold', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm && mounted) {
      try {
        await FirebaseFirestore.instance.collection('listings').doc(widget.docId).update({'status': 'sold'});
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item marked as sold!')));
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = displayData['title'] ?? 'Unnamed Item';
    final int price = displayData['price'] ?? 0;
    final String description = displayData['description'] ?? 'No description provided.';
    final String category = displayData['category'] ?? 'Other';
    final bool isNew = displayData['isNew'] ?? false;
    final List<dynamic> images = displayData['images'] ?? [];
    final String sellerId = displayData['sellerId'] ?? '';

    final bool isMyListing = currentUserId == sellerId;

    return Scaffold(
      backgroundColor: _bgColor,
      extendBodyBehindAppBar: true,
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18),
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  GestureDetector(
                    onTap: () {
                      if (images.isNotEmpty) _openFullScreenImage(images, _currentPage);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 380,
                      color: Colors.grey.shade200,
                      child: images.isEmpty
                          ? Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400, size: 64)
                          : Stack(
                              fit: StackFit.expand,
                              children: [
                                PageView.builder(
                                  itemCount: images.length,
                                  onPageChanged: (index) => setState(() => _currentPage = index),
                                  itemBuilder: (context, index) {
                                    final img = _getMemoryImage(images[index] as String);
                                    if (img == null) return const Center(child: Icon(Icons.broken_image));
                                    return Image(image: img, fit: BoxFit.cover);
                                  },
                                ),
                           
                                if (images.length > 1)
                                  Positioned(
                                    bottom: 16,
                                    left: 0,
                                    right: 0,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(images.length, (index) {
                                        return AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          margin: const EdgeInsets.symmetric(horizontal: 4),
                                          width: _currentPage == index ? 24 : 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(4),
                                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2)],
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ),

              
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isNew ? Colors.green.shade50 : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isNew ? 'Brand New' : 'Used',
                                style: TextStyle(
                                  color: isNew ? Colors.green.shade700 : Colors.orange.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        
                        Text(
                          title,
                          style: TextStyle(color: _textColor, fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$$price',
                          style: TextStyle(color: Colors.green[800], fontSize: 26, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),

           
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('Users').doc(sellerId).get(),
                      builder: (context, snapshot) {
                        String sellerName = 'Loading...';
                        MemoryImage? sellerImage;
                        
                        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data!.exists) {
                          final userData = snapshot.data!.data() as Map<String, dynamic>;
                          sellerName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
                          if (sellerName.isEmpty) sellerName = 'Unknown User';
                          sellerImage = _getMemoryImage(userData['profileImage']);
                        }

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.grey.shade100,
                                backgroundImage: sellerImage,
                                child: sellerImage == null ? Icon(Icons.person_outline, color: Colors.grey.shade400) : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Sold by', style: TextStyle(color: _subtitleColor, fontSize: 12)),
                                    const SizedBox(height: 2),
                                    Text(
                                      sellerName,
                                      style: TextStyle(color: _textColor, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.verified_user_outlined, color: Colors.green[700], size: 20),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                 
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description', style: TextStyle(color: _textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(
                          description,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 15, height: 1.6),
                        ),
                        const SizedBox(height: 40), 
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

   
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 56,
                child: isMyListing
                   
                    ? Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final newData = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditListingScreen(itemData: displayData, docId: widget.docId),
                                  ),
                                );
                                if (newData != null && newData is Map) {
                                  setState(() {
                                    displayData['title'] = newData['title'];
                                    displayData['price'] = newData['price'];
                                    displayData['description'] = newData['description'];
                                  });
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300, width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Edit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textColor)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _markAsSold,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _textColor, 
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Text('Mark Sold', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                        ],
                      )
                    : FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('Users').doc(sellerId).get(),
                        builder: (context, snapshot) {
                          String phoneText = "Loading...";
                          String? rawPhone;
                          bool isClickable = false;

                          if (snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.hasError) {
                              phoneText = "Database Error";
                            } else if (!snapshot.data!.exists) {
                              phoneText = "Profile Missing";
                            } else {
                              final userData = snapshot.data!.data() as Map<String, dynamic>;
                              rawPhone = userData['phone'];

                              if (rawPhone != null && rawPhone.isNotEmpty) {
                                phoneText = 'Contact via WhatsApp';
                                isClickable = true;
                              } else {
                                phoneText = 'No Phone Provided';
                              }
                            }
                          }

                          return ElevatedButton(
                            onPressed: !isClickable ? null : () async {
                              String cleanPhone = rawPhone!.replaceAll(RegExp(r'\D'), '');
                              if (cleanPhone.startsWith('01') && cleanPhone.length == 11) {
                                cleanPhone = '2$cleanPhone'; 
                              }

                              final String productTitle = displayData['title'] ?? 'this item';
                              final int productPrice = displayData['price'] ?? 0;
                              final String message = "Hello! I'm interested in your listing on FoundIt:\n\n*$productTitle*\nPrice: \$$productPrice\n\nIs this still available?";
                              final String encodedMessage = Uri.encodeComponent(message);

                              final Uri url = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMessage');
                              
                              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp.')));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isClickable ? const Color(0xFF25D366) : Colors.grey.shade300,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(FontAwesomeIcons.whatsapp, color: isClickable ? Colors.white : Colors.grey.shade500, size: 24),
                                const SizedBox(width: 12),
                                Text(
                                  phoneText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isClickable ? Colors.white : Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}