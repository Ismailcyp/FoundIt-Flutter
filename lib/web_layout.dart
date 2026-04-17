import 'dart:ui';
import 'package:flutter/material.dart';

class WebLayout extends StatelessWidget {
  final Widget child;

  const WebLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // 1. We wrap everything in a SelectionArea so users can highlight text (expected on web!)
    return SelectionArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F), // A deeper black for the very back of the web
        body: Column(
          children: [
            // --- THE WEB NAVBAR ---
            _buildWebNavBar(context),

            // --- THE MAIN CONTENT AREA ---
            Expanded(
              // 2. Center the content with a max width so it doesn't stretch weirdly on ultrawide monitors
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200), // Standard premium web width
                  child: child, // This is where Store Screen, Profile, etc. will go
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebNavBar(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: const Color(0xFF2A0845).withOpacity(0.85),
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
          ),
          child: Row(
            children: [
              // 1. Logo
              const Text(
                'Yallasafqa',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: "dmsans", letterSpacing: -0.5),
              ),
              
              const Spacer(),

              // 2. Navigation Links
              _NavBarLink(title: 'Marketplace', isActive: true, onTap: () {}),
              const SizedBox(width: 32),
              _NavBarLink(title: 'My Listings', isActive: false, onTap: () {}),
              const SizedBox(width: 32),
              _NavBarLink(title: 'Saved', isActive: false, onTap: () {}),

              const SizedBox(width: 48),

              // 3. Add Listing Button (Desktop Style)
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Post Item', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6E56FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 24),

              // 4. User Profile Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.1),
                child: const Icon(Icons.person_outline, color: Colors.white, size: 20),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Helper Widget for clean, hoverable nav links
class _NavBarLink extends StatefulWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarLink({required this.title, required this.isActive, required this.onTap});

  @override
  State<_NavBarLink> createState() => _NavBarLinkState();
}

class _NavBarLinkState extends State<_NavBarLink> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: widget.isActive 
                ? Colors.white 
                : (_isHovering ? Colors.white : Colors.white54),
            fontWeight: widget.isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
          child: Text(widget.title),
        ),
      ),
    );
  }
}