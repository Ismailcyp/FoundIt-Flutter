import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yalla_safqa/edit_listing.dart';


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
  
  // 1. We declare the variable
  late Map<String, dynamic> displayData;

  // 2. We MUST initialize it when the screen opens!
  @override
  void initState() {
    super.initState();
    displayData = Map.from(widget.itemData); 
  }

  Widget _decodeSingleImage(String base64String) {
    if (base64String.contains(',')) {
      base64String = base64String.split(',').last;
    }
    try {
      Uint8List decodedBytes = base64Decode(base64String);
      return Image.memory(
        decodedBytes,
        width: double.infinity,
        height: 350,
        fit: BoxFit.cover,
      );
    } catch (e) {
      return const Center(
        child: Icon(Icons.broken_image, color: Colors.white54, size: 50),
      );
    }
  }

  Future<void> _markAsSold() async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1B1B28),
            title: const Text(
              'Mark as Sold?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'This will remove the item from the main store page. Are you sure?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Mark Sold',
                  style: TextStyle(
                    color: Color(0xFF6E56FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm && mounted) {
      try {
        await FirebaseFirestore.instance
            .collection('listings')
            .doc(widget.docId)
            .update({'status': 'sold'});

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Item marked as sold!')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error updating item: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color.fromARGB(255, 38, 2, 58);
    const Color cardColor = Color(0xFF1B1B28);
    const Color primaryPurple = Color(0xFF6E56FF);
    const Color textSecondary = Color(0xFF8E8E9F);

    // 3. Update all of these to read from displayData instead of widget.itemData
    final String title = displayData['title'] ?? 'Unnamed Item';
    final int price = displayData['price'] ?? 0;
    final String description = displayData['description'] ?? 'No description provided.';
    final String category = displayData['category'] ?? 'Other';
    final bool isNew = displayData['isNew'] ?? false;
    final List<dynamic> images = displayData['images'] ?? [];
    final String sellerId = displayData['sellerId'] ?? '';

    final bool isMyListing = currentUserId == sellerId;

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 1. SCROLLABLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 350,
                    color: cardColor,
                    child: images.isEmpty
                        ? const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.white54,
                              size: 50,
                            ),
                          )
                        : Stack(
                            children: [
                              PageView.builder(
                                itemCount: images.length,
                                onPageChanged: (index) {
                                  setState(() => _currentPage = index);
                                },
                                itemBuilder: (context, index) {
                                  return _decodeSingleImage(
                                    images[index] as String,
                                  );
                                },
                              ),
                              if (images.length > 1)
                                Positioned(
                                  bottom: 16,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(images.length, (
                                      index,
                                    ) {
                                      return AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        width: _currentPage == index ? 24 : 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _currentPage == index
                                              ? primaryPurple
                                              : Colors.white54,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                            ],
                          ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryPurple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  color: primaryPurple,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isNew
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isNew ? 'Brand New' : 'Used',
                                style: TextStyle(
                                  color: isNew
                                      ? Colors.greenAccent
                                      : Colors.orangeAccent,
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'EGP $price',
                          style: const TextStyle(
                            color: primaryPurple,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 16),

                        const Text(
                          'Description',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. DYNAMIC BOTTOM BAR
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: isMyListing
                    ? Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              // 4. Update the Edit button to await the changes and setState
                              onPressed: () async {
                                final newData = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditListingScreen(
                                      itemData: displayData,
                                      docId: widget.docId,
                                    ),
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
                                side: const BorderSide(
                                  color: primaryPurple,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryPurple,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _markAsSold,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Mark Sold',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('Users')
                            .doc(sellerId)
                            .get(),
                        builder: (context, snapshot) {
                          String phoneText = "Loading...";
                          String? rawPhone;
                          bool isClickable = false;

                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasError) {
                              phoneText = "Database Error";
                            } else if (!snapshot.data!.exists) {
                              phoneText = "Profile Missing"; 
                            } else {
                              final userData =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              rawPhone = userData['phone'];

                              if (rawPhone != null && rawPhone.isNotEmpty) {
                                phoneText = 'WhatsApp: $rawPhone';
                                isClickable = true;
                              } else {
                                phoneText = 'No Phone Provided';
                              }
                            }
                          }

                          return ElevatedButton(
                            onPressed: !isClickable
                                ? null
                                : () async {
                                    String cleanPhone = rawPhone!.replaceAll(
                                      RegExp(r'\D'),
                                      '',
                                    );
                                    if (cleanPhone.startsWith('01') &&
                                        cleanPhone.length == 11) {
                                      cleanPhone = '2$cleanPhone';
                                    }

                                    // 1. Grab the product details
                                    final String productTitle = displayData['title'] ?? 'this item';
                                    final int productPrice = displayData['price'] ?? 0;

                                    // 2. Construct the message
                                    final String message = "Hello! I'm interested in your listing on Yallasafqa:\n\n*$productTitle*\nPrice: $productPrice EGP\n\nIs this still available?";
                                    
                                    // 3. URL-Encode the message
                                    final String encodedMessage = Uri.encodeComponent(message);

                                    // 4. Add the encoded message to the WhatsApp URL
                                    final Uri url = Uri.parse(
                                      'https://wa.me/$cleanPhone?text=$encodedMessage',
                                    );
                                    if (!await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    )) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Could not open WhatsApp.',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isClickable
                                  ? const Color(0xFF25D366)
                                  : Colors.grey[800],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: isClickable ? 4 : 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.whatsapp,
                                  color: isClickable
                                      ? Colors.white
                                      : Colors.white54,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  phoneText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isClickable
                                        ? Colors.white
                                        : Colors.white54,
                                  ),
                                ),
                                const Spacer(),
                                if (isClickable)
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 16,
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