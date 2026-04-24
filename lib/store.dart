import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:FoundIT/login.dart';
import 'package:FoundIT/addproduct.dart';
import 'package:FoundIT/item_details.dart';
import 'package:FoundIT/my_listings.dart';
import 'package:FoundIT/profile.dart';
import 'package:FoundIT/contact_us.dart';

class Mymain extends StatefulWidget {
  const Mymain({super.key});

  @override
  State<Mymain> createState() => _MymainState();
}

class _MymainState extends State<Mymain> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentTab = 0;
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  List<String> _savedItems = [];
  String _firstName = 'User';
  String _lastName = '';
  String? _base64ProfileImage;

  StreamSubscription<DocumentSnapshot>? _userSubscription;

  final Color _primaryColor = const Color(0xFFB5E575); 
  final Color _textColor = const Color(0xFF1E1E1E);
  final Color _subtitleColor = const Color(0xFF8E8E8E);
  final Color _inputFillColor = const Color(0xFFF5F5F5);
  final Color _bgColor = const Color(0xFFF9F9F9); 

  @override
  void initState() {
    super.initState();
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    _userSubscription = FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data() as Map<String, dynamic>;
            setState(() {
              _savedItems = data.containsKey('savedItems')
                  ? List<String>.from(data['savedItems'])
                  : [];
              _firstName = data['firstName'] ?? 'User';
              _lastName = data['lastName'] ?? '';
              _base64ProfileImage = data['profileImage'];
            });
          }
        });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _userSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Stream<QuerySnapshot> _getListingsStream() {
    Query query = FirebaseFirestore.instance
        .collection('listings')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true);

    if (_selectedCategory != 'All') {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    return query.snapshots();
  }

  MemoryImage? _getDecodedProfileImage() {
    if (_base64ProfileImage == null || _base64ProfileImage!.isEmpty) {
      return null;
    }
    try {
      String cleanBase64 = _base64ProfileImage!;
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
      key: _scaffoldKey,
      backgroundColor: _bgColor,
      extendBody: true,
      
      endDrawer: Drawer(
        backgroundColor: Colors.white,
        width: MediaQuery.of(context).size.width * 0.65,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              CircleAvatar(
                radius: 40,
                backgroundColor: _inputFillColor,
                backgroundImage: _getDecodedProfileImage(),
                child: _base64ProfileImage == null
                    ? Icon(Icons.person_outline, size: 40, color: Colors.green[800])
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                '$_firstName $_lastName'.trim(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Divider(color: Colors.grey[200], thickness: 1),

              ListTile(
                leading: Icon(Icons.person_outline, color: _textColor),
                title: Text('Profile', style: TextStyle(color: _textColor, fontSize: 16, fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.mail_outline, color: _textColor),
                title: Text('Contact Us', style: TextStyle(color: _textColor, fontSize: 16, fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactUsScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                onTap: _handleLogout,
              ),

              const Spacer(),
              Divider(color: Colors.grey[200], thickness: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.storefront_outlined, color: Colors.green[800], size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'FoundIt Built by ISMAIL 😍',
                      style: TextStyle(color: _subtitleColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),


      body: Stack(
        children: [
          IndexedStack(
            index: _currentTab,
            children: [
              SafeArea(child: _buildHomeTab()),
              const MyListingsScreen(),
              SafeArea(child: _buildFavoritesTab()),
            ],
          ),
        ],
      ),

     bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), 
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_filled, 'Home', 0),
                _buildNavItem(Icons.sell_outlined, 'Listings', 1),
                _buildAddButton(),
                _buildNavItem(CupertinoIcons.heart, 'Saved', 2),
                _buildNavItem(Icons.settings_outlined, 'Settings', 3),
              ],
            ),
          ),
        ),
      ),
    );
    
  }

  Widget _buildHomeTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 125),
                child: Row(
                  children: [
                    Icon(Icons.storefront_outlined, color: Colors.green[800], size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'FoundIt',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                style: TextStyle(color: _textColor),
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search for anything...',
                  hintStyle: TextStyle(color: _subtitleColor, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: _subtitleColor),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 36,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('categories').orderBy('createdAt').snapshots(),
            builder: (context, snapshot) {
              List<String> dynamicCategories = ['All'];

              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['name'] != null) {
                    dynamicCategories.add(data['name']);
                  }
                }
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: dynamicCategories.length,
                itemBuilder: (context, index) {
                  final category = dynamicCategories[index];
                  final isSelected = category == _selectedCategory;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = category),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8.0),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green[800] : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.green.shade800 : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : _textColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getListingsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: _primaryColor));
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error loading listings', style: TextStyle(color: _textColor)));
              }

              var docs = snapshot.data?.docs ?? [];
              final String searchQuery = _searchController.text.trim().toLowerCase();
              
              if (searchQuery.isNotEmpty) {
                docs = docs.where((doc) {
                  final itemData = doc.data() as Map<String, dynamic>;
                  final title = (itemData['title'] ?? '').toString().toLowerCase();
                  return title.contains(searchQuery);
                }).toList();
              }

              if (docs.isEmpty) {
                return Center(
                  child: Text(
                    searchQuery.isNotEmpty ? 'No items found for "$searchQuery"' : 'No items found in $_selectedCategory.',
                    style: TextStyle(color: _subtitleColor, fontSize: 16),
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
                  return _buildProductCard(itemData, documentId);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Saved Items',
            style: TextStyle(
              color: _textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getListingsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: _primaryColor));
              }

              final allDocs = snapshot.data?.docs ?? [];
              final savedDocs = allDocs.where((doc) => _savedItems.contains(doc.id)).toList();

              if (_savedItems.isEmpty || savedDocs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.heart, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        "You haven't saved any items yet.",
                        style: TextStyle(color: _subtitleColor, fontSize: 16),
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
                itemCount: savedDocs.length,
                itemBuilder: (context, index) {
                  final itemData = savedDocs[index].data() as Map<String, dynamic>;
                  final String documentId = savedDocs[index].id;
                  return _buildProductCard(itemData, documentId);
                },
              );
            },
          ),
        ),
      ],
    );
  }



  String _timeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    final DateTime date = timestamp.toDate();
    final Duration diff = DateTime.now().difference(date);

    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

Widget _buildProductCard(Map<String, dynamic> item, String docId) {
    final String title = item['title'] ?? 'Unnamed Item';
    final int price = item['price'] ?? 0;
    final List<dynamic> images = item['images'] ?? [];
    final String category = item['category'] ?? 'General';
    
    String rawStatus = item['status'] ?? 'In Stock';
    if (rawStatus == 'active') rawStatus = 'In Stock';
    
    Color badgeTextColor;
    Color badgeBgColor;
    if (rawStatus.toLowerCase() == 'sold out') {
      badgeTextColor = Colors.red.shade700;
      badgeBgColor = Colors.red.shade50;
    } else if (rawStatus.toLowerCase() == 'low stock') {
      badgeTextColor = Colors.orange.shade700;
      badgeBgColor = Colors.orange.shade50;
    } else {
      badgeTextColor = Colors.green.shade700;
      badgeBgColor = Colors.green.shade50;
    }

    final bool isSaved = _savedItems.contains(docId);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ItemDetailsScreen(itemData: item, docId: docId)),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF1E1E1E),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
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
                        const SizedBox(height: 2),
                        Text(
                          category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    
                    Row(
                      children: [
                        Expanded(
                          child: Container(
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
                                  rawStatus,
                                  style: TextStyle(
                                    color: badgeTextColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (BuildContext sheetContext) { 
                                return SafeArea(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 4,
                                          margin: const EdgeInsets.only(bottom: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                        ListTile(
                                          leading: Icon(
                                            isSaved ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                                            color: isSaved ? Colors.redAccent : const Color(0xFF1E1E1E),
                                          ),
                                          title: Text(
                                            isSaved ? 'Remove from Saved' : 'Save Item',
                                            style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1E1E1E)),
                                          ),
                                          onTap: () async {
                                            Navigator.pop(sheetContext); 
                                            
                                            final String uid = FirebaseAuth.instance.currentUser!.uid;
                                            final userRef = FirebaseFirestore.instance.collection('Users').doc(uid);
                                            
                                            if (isSaved) {
                                              await userRef.update({'savedItems': FieldValue.arrayRemove([docId])});
                                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from saved items')));
                                            } else {
                                              await userRef.update({'savedItems': FieldValue.arrayUnion([docId])});
                                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item saved!')));
                                            }
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.visibility_outlined, color: Color(0xFF1E1E1E)),
                                          title: const Text('View Details', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1E1E1E))),
                                          onTap: () {
                                            Navigator.pop(sheetContext);
                                            Navigator.push(
                                              context, 
                                              MaterialPageRoute(builder: (context) => ItemDetailsScreen(itemData: item, docId: docId)),
                                            );
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.flag_outlined, color: Colors.redAccent),
                                          title: const Text('Report Listing', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
                                          onTap: () {
                                            Navigator.pop(sheetContext); 
                                            ScaffoldMessenger.of(context).showSnackBar( 
                                              const SnackBar(content: Text('Listing reported to moderators for review.')),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.more_horiz,
                              color: Colors.grey.shade500,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _decodeAndDisplayImage(List<dynamic> images) {
    if (images.isEmpty) {
      return Container(
        color: _inputFillColor,
        child: Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 32)),
      );
    }
    String base64String = images[0] as String;
    if (base64String.contains(',')) {
      base64String = base64String.split(',').last;
    }
    try {
      Uint8List decodedBytes = base64Decode(base64String);
      return Image.memory(
        decodedBytes,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } catch (e) {
      return Container(
        color: _inputFillColor,
        child: Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey[400], size: 32)),
      );
    }
  }


  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => const AddListingScreen(),
          ),
        );
      },
      child: Container(
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          color: _primaryColor, 
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(Icons.add, color: Colors.green[900], size: 28),
      ),
    );
  }

 
  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentTab == index && index != 3;

    return GestureDetector(
      onTap: () {
        if (index == 3) {
          _scaffoldKey.currentState?.openEndDrawer();
        } else {
          setState(() {
            _currentTab = index;
          });
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60, 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
   
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green.shade50 : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.green[800] : Colors.grey[400],
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.green[800] : Colors.grey[400],
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}