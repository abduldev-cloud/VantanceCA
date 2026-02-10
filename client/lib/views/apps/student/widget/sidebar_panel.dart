import 'package:binary_success/images.dart';
import 'package:binary_success/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SidebarPanel extends StatefulWidget {
  final Function(String)? onMenuItemTap;
  final User user;

  const SidebarPanel({
    super.key,
    this.onMenuItemTap,
    required this.user,
  });

  @override
  State<SidebarPanel> createState() => _SidebarPanelState();
}

class _SidebarPanelState extends State<SidebarPanel> {
  String? _hoveredItem;
  String _selectedItem = 'Performance';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Section
          _buildLogoSection(),

          const SizedBox(height: 24),

          // Menu Items Section
          Expanded(
            child: _buildMenuSection(),
          ),

          // Bottom User Card
          _buildUserCard(),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Binary Success logo
          Image.asset(
            Images.logoCircle,
            width: 32,
            height: 32,
          ),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Binary Success',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF000000),
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    final menuItems = [
      {'name': 'Papers', 'icon': Icons.description_outlined},
      {'name': 'Performance', 'icon': Icons.bar_chart_outlined}, // Changed from Practices
      {'name': 'Result', 'icon': Icons.emoji_events_outlined},
      {'name': 'Calendar', 'icon': Icons.calendar_today_outlined},
      {'name': 'Settings', 'icon': Icons.settings_outlined},
    ];

    return SingleChildScrollView(
      child: Column(
        children: menuItems.map((item) {
          final itemName = item['name'] as String;
          final itemIcon = item['icon'] as IconData;

          return _buildMenuItem(
            name: itemName,
            icon: itemIcon,
            isSelected: _selectedItem == itemName,
            isHovered: _hoveredItem == itemName,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem({
    required String name,
    required IconData icon,
    required bool isSelected,
    required bool isHovered,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredItem = name),
      onExit: (_) => setState(() => _hoveredItem = null),
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedItem = name);
          widget.onMenuItemTap?.call(name);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 16),
              Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Row(
        children: [
          // Avatar on the left
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFF2F2F2),
            child: Text(
              widget.user.initials,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF000000),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User info on the right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF000000),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "S. R. No.: ${widget.user.registrationNumber}",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF000000),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "Plan: ${widget.user.plan}",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF000000),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Dark Mode Variant
class SidebarPanelDark extends StatefulWidget {
  final Function(String)? onMenuItemTap;
  final User user;

  const SidebarPanelDark({
    super.key,
    this.onMenuItemTap,
    required this.user,
  });

  @override
  State<SidebarPanelDark> createState() => _SidebarPanelDarkState();
}

class _SidebarPanelDarkState extends State<SidebarPanelDark> {
  String? _hoveredItem;
  String _selectedItem = 'Papers';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: double.infinity,
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Section
          _buildLogoSection(),

          const SizedBox(height: 24),

          // Menu Items Section
          Expanded(
            child: _buildMenuSection(),
          ),

          // Bottom User Card
          _buildUserCard(),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Placeholder for logo icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.school,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Binary Success',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    final menuItems = [
      {'name': 'Papers', 'icon': Icons.description_outlined},
      {'name': 'Performance', 'icon': Icons.bar_chart_outlined}, // Changed from Practices
      {'name': 'Result', 'icon': Icons.emoji_events_outlined},
      {'name': 'Calendar', 'icon': Icons.calendar_today_outlined},
      {'name': 'Settings', 'icon': Icons.settings_outlined},
    ];

    return SingleChildScrollView(
      child: Column(
        children: menuItems.map((item) {
          final itemName = item['name'] as String;
          final itemIcon = item['icon'] as IconData;

          return _buildMenuItem(
            name: itemName,
            icon: itemIcon,
            isSelected: _selectedItem == itemName,
            isHovered: _hoveredItem == itemName,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem({
    required String name,
    required IconData icon,
    required bool isSelected,
    required bool isHovered,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredItem = name),
      onExit: (_) => setState(() => _hoveredItem = null),
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedItem = name);
          widget.onMenuItemTap?.call(name);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isHovered || isSelected
                ? Colors.grey.shade800
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? Colors.blue.shade400 : Colors.grey.shade400,
              ),
              const SizedBox(width: 12),
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color:
                      isSelected ? Colors.blue.shade400 : Colors.grey.shade300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF404040), width: 1),
      ),
      child: Row(
        children: [
          // Avatar on the left
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF3A3A3A),
            child: Text(
              widget.user.initials,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User info on the right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "S. R. No.: ${widget.user.registrationNumber}",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "Plan: ${widget.user.plan}",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
