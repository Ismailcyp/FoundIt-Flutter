import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yalla_safqa/login.dart';
import 'package:yalla_safqa/addproduct.dart';
import 'package:yalla_safqa/item_details.dart';
import 'package:yalla_safqa/my_listings.dart';
import 'package:yalla_safqa/profile.dart';
import 'package:yalla_safqa/contact_us.dart';
import 'dart:ui';

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

  // --- UPDATED STATE ---
  List<String> _savedItems = [];
  String _firstName = 'User';
  String _lastName = '';
  String? _base64ProfileImage;

  StreamSubscription<DocumentSnapshot>? _userSubscription;

  final Color _bgColor = const Color.fromARGB(255, 38, 2, 58);
  final Color _cardColor = const Color(0xFF1B1B28);
  final Color _primaryPurple = const Color(0xFF6E56FF);
  final Color _textSecondary = const Color(0xFF8E8E9F);

  @override
  void initState() {
    super.initState();
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    // Listen to the ENTIRE user document to keep the Drawer updated in real-time
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

  // Safe image decoder for the Drawer Avatar
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
      backgroundColor: const Color(0xFF2A0845),
    extendBody: true,
      endDrawer: Drawer(
        backgroundColor: _cardColor,
        width: MediaQuery.of(context).size.width * 0.60,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
    
              CircleAvatar(
                radius: 40,
                backgroundColor: _primaryPurple.withOpacity(0.2),
                backgroundImage: _getDecodedProfileImage(),
                child: _base64ProfileImage == null
                    ? Icon(Icons.person, size: 40, color: _primaryPurple)
                    : null,
              ),
              const SizedBox(height: 12),
    
              // 2. Full Name
              Text(
                '$_firstName $_lastName'.trim(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.white24),
    
              // 3. Menu Items
              ListTile(
                leading: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                ),
                title: const Text(
                  'Profile',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.mail_outline,
                  color: Colors.white,
                ),
                title: const Text(
                  'Contact Us',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactUsScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: _handleLogout,
              ),
    
              const Spacer(),
    
              const Divider(color: Colors.white24),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Made with @YallaSafqaTeam',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    
      body: Stack(children: [IndexedStack(
        index: _currentTab,
        children: [
          SafeArea(child: _buildHomeTab()),
          const MyListingsScreen(),
          SafeArea(child: _buildFavoritesTab()),
        ],
      ),],),
    
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              _primaryPurple,
              const Color.fromARGB(255, 161, 2, 179),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: _primaryPurple.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => const AddListingScreen(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
    
      bottomNavigationBar: BottomAppBar(
        color: _cardColor,
        shape: const CircularNotchedRectangle(),
        notchMargin: 9,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_filled, 'Home', 0),
              _buildNavItem(Icons.sell_outlined, 'My Listings', 1),
              const SizedBox(width: 48),
              _buildNavItem(CupertinoIcons.heart, 'Favorite', 2),
              _buildNavItem(Icons.settings_outlined, 'Settings', 3),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // TAB CONTENT BUILDERS
  // =========================================================================

Widget _buildHomeTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(9.0),
          child: Column(
            children: [
              const Text(
                'Yallasafqa',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: "dmsans",
                ),
              ),
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                // 1. ADDED THIS: Rebuild the screen when the user types
                onChanged: (value) {
                  setState(() {}); 
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: _textSecondary),
                  prefixIcon: Icon(Icons.search, color: _textSecondary),
                  filled: true,
                  fillColor: _cardColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        // 2. DYNAMIC Horizontal Category Scroll
        SizedBox(
          height: 40,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('categories')
                .orderBy('createdAt')
                .snapshots(),
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
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                itemCount: dynamicCategories.length,
                itemBuilder: (context, index) {
                  final category = dynamicCategories[index];
                  final isSelected = category == _selectedCategory;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: isSelected ? _primaryPurple : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? _primaryPurple : _cardColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (isSelected) ...[
                            const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color.fromARGB(255, 255, 255, 255)
                                  : _textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getListingsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: _primaryPurple),
                );
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Error loading listings',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              // Grab the documents from Firestore
              var docs = snapshot.data?.docs ?? [];

              // 2. ADDED THIS: Filter the list based on the search box text
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
                    searchQuery.isNotEmpty 
                        ? 'No items found for "$searchQuery"'
                        : 'No items found in $_selectedCategory.',
                    style: TextStyle(color: _textSecondary, fontSize: 16),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
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
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'Saved Items',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getListingsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: _primaryPurple),
                );
              }

              final allDocs = snapshot.data?.docs ?? [];
              final savedDocs = allDocs
                  .where((doc) => _savedItems.contains(doc.id))
                  .toList();

              if (_savedItems.isEmpty || savedDocs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.heart,
                        size: 64,
                        color: _textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "You haven't saved any items yet.",
                        style: TextStyle(color: _textSecondary, fontSize: 16),
                      ),
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
                  childAspectRatio: 0.75,
                ),
                itemCount: savedDocs.length,
                itemBuilder: (context, index) {
                  final itemData =
                      savedDocs[index].data() as Map<String, dynamic>;
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

  // =========================================================================
  // HELPER WIDGETS
  // =========================================================================
  // Converts Firestore Timestamp to "2 hours ago" format
  String _timeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    
    final DateTime date = timestamp.toDate();
    final Duration diff = DateTime.now().difference(date);

    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} years ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} mins ago';
    return 'Just now';
  }

  Widget _buildProductCard(Map<String, dynamic> item, String docId) {
    final String title = item['title'] ?? 'Unnamed Item';
    final int price = item['price'] ?? 0;
    final List<dynamic> images = item['images'] ?? [];

    // We need the sellerId to fetch their name!
    final String sellerId = item['sellerId'] ?? '';
    final bool isSaved = _savedItems.contains(docId);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ItemDetailsScreen(itemData: item, docId: docId),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. FULL BLEED IMAGE (Fills the entire background)
            _decodeAndDisplayImage(images),

            // 2. FAVORITE BUTTON (Top Right)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () async {
                  final String uid = FirebaseAuth.instance.currentUser!.uid;
                  final userRef = FirebaseFirestore.instance
                      .collection('Users')
                      .doc(uid);

                  if (isSaved) {
                    await userRef.update({
                      'savedItems': FieldValue.arrayRemove([docId]),
                    });
                  } else {
                    await userRef.update({
                      'savedItems': FieldValue.arrayUnion([docId]),
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(
                      0.5,
                    ), // Slightly darker for contrast
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSaved ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                    color: isSaved ? Colors.redAccent : Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),

            // 3. FROSTED GLASS BOTTOM PANEL (Text & Seller Info)
// 3. FROSTED GLASS BOTTOM PANEL (Text, Seller Info & Time)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _cardColor.withOpacity(0.7),
                      border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14, height: 1.2),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'EGP $price',
                          style: TextStyle(color: _primaryPurple, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        
                        // 4. SELLER NAME & TIME AGO
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('Users').doc(sellerId).get(),
                          builder: (context, snapshot) {
                            String sellerName = 'Loading...';
                            
                            if (snapshot.hasData && snapshot.data!.exists) {
                              final userData = snapshot.data!.data() as Map<String, dynamic>;
                              sellerName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
                            } else if (snapshot.hasError || (snapshot.hasData && !snapshot.data!.exists)) {
                              sellerName = 'Unknown Seller';
                            }

                            // Calculate the relative time
                            final Timestamp? createdAt = item['createdAt'] as Timestamp?;
                            final String timeString = _timeAgo(createdAt);

                            return Row(
                              children: [
                                const Icon(Icons.person_outline, color: Colors.white54, size: 12),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    sellerName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                                  ),
                                ),
                                // NEW: The Time Ago text aligned to the right
                                Text(
                                  timeString,
                                  style: const TextStyle(color: Colors.white38, fontSize: 10, fontStyle: FontStyle.italic),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
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
        color: _bgColor,
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.white54),
        ),
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
        color: _bgColor,
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.white54),
        ),
      );
    }
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? _primaryPurple : _textSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? _primaryPurple : _textSecondary,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
