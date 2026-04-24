import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:FoundIT/item_details.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final Color _textColor = const Color(0xFF1E1E1E);
  final Color _subtitleColor = const Color(0xFF8E8E8E);

  Widget _decodeAndDisplayImage(List<dynamic> images) {
    if (images.isEmpty) {
      return Container(
        color: Colors.grey.shade50,
        child: Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade300, size: 32)),
      );
    }
    String base64String = images[0] as String;
    if (base64String.contains(',')) {
      base64String = base64String.split(',').last;
    }
    try {
      Uint8List decodedBytes = base64Decode(base64String);
      return Image.memory(decodedBytes, width: double.infinity, fit: BoxFit.cover);
    } catch (e) {
      return Container(
        color: Colors.grey.shade50,
        child: Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade300, size: 32)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'My Listings',
              style: TextStyle(color: _textColor, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('listings')
                  .where('sellerId', isEqualTo: currentUserUid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.green[800]));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading your listings.\nCheck your console for an Index link!',
                      style: TextStyle(color: Colors.red.shade700),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sell_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          "You haven't posted any items yet.",
                          style: TextStyle(color: _subtitleColor, fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 100.0), 
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.68, 
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final itemData = docs[index].data() as Map<String, dynamic>;
                    final String documentId = docs[index].id;
                    
                    final String title = itemData['title'] ?? 'Unnamed Item';
                    final int price = itemData['price'] ?? 0;
                    final List<dynamic> images = itemData['images'] ?? [];
                    final String rawStatus = (itemData['status'] ?? 'pending').toLowerCase();

                    Color badgeTextColor;
                    Color badgeBgColor;
                    String displayStatus = rawStatus.toUpperCase();

                    if (rawStatus == 'active' || rawStatus == 'approved') {
                      badgeTextColor = Colors.green.shade700;
                      badgeBgColor = Colors.green.shade50;
                      displayStatus = 'ACTIVE';
                    } else if (rawStatus == 'pending') {
                      badgeTextColor = Colors.orange.shade700;
                      badgeBgColor = Colors.orange.shade50;
                    } else if (rawStatus == 'rejected' || rawStatus == 'flagged') {
                      badgeTextColor = Colors.red.shade700;
                      badgeBgColor = Colors.red.shade50;
                    } else if (rawStatus == 'sold') {
                      badgeTextColor = Colors.grey.shade700;
                      badgeBgColor = Colors.grey.shade200;
                    } else {
                      badgeTextColor = Colors.grey.shade700;
                      badgeBgColor = Colors.grey.shade100;
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailsScreen(itemData: itemData, docId: documentId),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: _decodeAndDisplayImage(images),
                                  ),
                                ),
                              ),
                            ),
                            
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF1E1E1E),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '\$$price',
                                          style: const TextStyle(
                                            color: Color(0xFF1E1E1E),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      decoration: BoxDecoration(
                                        color: badgeBgColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(radius: 3, backgroundColor: badgeTextColor),
                                          const SizedBox(width: 6),
                                          Text(
                                            displayStatus,
                                            style: TextStyle(
                                              color: badgeTextColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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