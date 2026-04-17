import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yalla_safqa/item_details.dart'; // Ensure this path matches your project!

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final Color _bgColor = const Color.fromARGB(255, 38, 2, 58);
  final Color _cardColor = const Color(0xFF1B1B28);
  final Color _primaryPurple = const Color(0xFF6E56FF);
  final Color _textSecondary = const Color(0xFF8E8E9F);

  Widget _decodeAndDisplayImage(List<dynamic> images) {
    if (images.isEmpty) {
      return Container(color: _bgColor, child: const Center(child: Icon(Icons.image_not_supported, color: Colors.white54)));
    }
    String base64String = images[0] as String;
    if (base64String.contains(',')) {
      base64String = base64String.split(',').last;
    }
    try {
      Uint8List decodedBytes = base64Decode(base64String);
      return Image.memory(decodedBytes, width: double.infinity, fit: BoxFit.cover);
    } catch (e) {
      return Container(color: _bgColor, child: const Center(child: Icon(Icons.broken_image, color: Colors.white54)));
    }
  }

  // --- HELPER: GET STATUS COLOR ---
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'approved':
        return Colors.greenAccent;
      case 'pending':
        return Colors.orangeAccent;
      case 'rejected':
      case 'flagged':
        return Colors.redAccent;
      default:
        return _textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'My Listings',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Query ONLY items where sellerId matches the current user!
              stream: FirebaseFirestore.instance
                  .collection('listings')
                  .where('sellerId', isEqualTo: currentUserUid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: _primaryPurple));
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading your listings. Check your console for an Index link!', style: TextStyle(color: Colors.redAccent), textAlign: TextAlign.center));
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sell_outlined, size: 64, color: _textSecondary.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text("You haven't posted any items yet.", style: TextStyle(color: _textSecondary, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.70, // Slightly taller to fit the status badge nicely
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final itemData = docs[index].data() as Map<String, dynamic>;
                    final String documentId = docs[index].id;
                    
                    final String title = itemData['title'] ?? 'Unnamed Item';
                    final int price = itemData['price'] ?? 0;
                    final List<dynamic> images = itemData['images'] ?? [];
                    final String status = itemData['status'] ?? 'pending';

                    return GestureDetector(
                      onTap: () {
                        // Optional: Only let them view details if it's active or pending
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailsScreen(itemData: itemData, docId: documentId),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // IMAGE + STATUS BADGE OVERLAY
                            Expanded(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: _decodeAndDisplayImage(images),
                                    ),
                                  ),
                                  
                                  // --- THE STATUS BADGE ---
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.75),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: _getStatusColor(status), width: 1.5),
                                      ),
                                      child: Text(
                                        status.toUpperCase(),
                                        style: TextStyle(
                                          color: _getStatusColor(status),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // TEXT DETAILS
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'EGP $price',
                                    style: TextStyle(
                                      color: _primaryPurple,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
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
        ],
      ),
    );
  }
}