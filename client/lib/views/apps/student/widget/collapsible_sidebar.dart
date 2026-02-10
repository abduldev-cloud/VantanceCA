import 'package:binary_success/images.dart';
import 'package:binary_success/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CollapsibleSidebar extends StatefulWidget {
  final Function(String)? onMenuItemTap;
  final User user;
  final bool isOpen;
  final VoidCallback onToggle;

  const CollapsibleSidebar({
    super.key,
    this.onMenuItemTap,
    required this.user,
    required this.isOpen,
    required this.onToggle,
  });

  @override
  State<CollapsibleSidebar> createState() => _CollapsibleSidebarState();
}

class _CollapsibleSidebarState extends State<CollapsibleSidebar> {
  String? _hoveredItem;
  String _selectedItem = 'Calendar';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!widget.isOpen) {
          widget.onToggle();
        }
      },
      child: AnimatedContainer(
        width: widget.isOpen ? 260 : 70,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(2, 0), // Soft vertical shadow on right edge
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Logo Section
            _buildLogoSection(),

            const SizedBox(height: 24),

            // Menu Items Section
            Expanded(
              child: _buildMenuSection(),
            ),

            // Bottom User Section
            _buildUserSection(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return LayoutBuilder(builder: (context, constraints) {
      bool showExpanded = constraints.maxWidth > 150;
      
      if (showExpanded) {
        // Expanded: Logo + Text
        return GestureDetector(
          onTap: widget.onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Image.asset(
                  Images.logoCircle,
                  width: 32,
                  height: 32,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Binary Success',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF000000),
                        letterSpacing: 0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Collapsed: Logo only (centered)
        return GestureDetector(
          onTap: widget.onToggle,
          child: Center(
            child: Image.asset(
              Images.logoCircle,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        );
      }
    });
  }

  Widget _buildMenuSection() {
    final menuItems = [
      {'name': 'Papers', 'icon': Icons.article_outlined},
      {'name': 'Practices', 'iconAsset': Images.performance_icon},
      {'name': 'Result', 'icon': Icons.emoji_events_outlined},
      {'name': 'Calendar', 'icon': Icons.calendar_month_outlined},
      {'name': 'Settings', 'icon': Icons.settings_outlined},
    ];

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: menuItems.map((item) {
          final itemName = item['name'] as String;
          final itemIcon = item['icon'] as IconData?;
          final itemAsset = item['iconAsset'] as String?;

          return _buildMenuItem(
            name: itemName,
            icon: itemIcon,
            iconAsset: itemAsset,
            isSelected: _selectedItem == itemName,
            isHovered: _hoveredItem == itemName,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem({
    required String name,
    IconData? icon,
    String? iconAsset,
    required bool isSelected,
    required bool isHovered,
  }) {
    return LayoutBuilder(builder: (context, constraints) {
      // Use constraints to determine if we should show expanded view
      // Collapsed width is ~70. Expanded is 260.
      bool showExpanded = constraints.maxWidth > 150;

      if (showExpanded) {
        // Expanded: Icon + Text
        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredItem = name),
          onExit: (_) => setState(() => _hoveredItem = null),
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedItem = name);
              widget.onMenuItemTap?.call(name);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Icon with circular background when selected
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFF0F0F0)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                      child: icon != null
                          ? Icon(
                              icon,
                              size: 22,
                              color: isSelected
                                  ? const Color(0xFF000000)
                                  : const Color(0xFF8A8A8A),
                            )
                          : Image.asset(
                              iconAsset!,
                              width: 22,
                              height: 22,
                              color: isSelected
                                  ? const Color(0xFF000000)
                                  : const Color(0xFF8A8A8A),
                            ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: const Color(0xFF000000),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        // Collapsed: Icon only with circular background when selected
        return GestureDetector(
          onTap: () {
            setState(() => _selectedItem = name);
            widget.onMenuItemTap?.call(name);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFFF0F0F0) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: icon != null
                    ? Icon(
                        icon,
                        size: 24,
                        color: isSelected
                            ? const Color(0xFF000000)
                            : const Color(0xFF8A8A8A),
                      )
                    : Image.asset(
                        iconAsset!,
                        width: 24,
                        height: 24,
                        color: isSelected
                            ? const Color(0xFF000000)
                            : const Color(0xFF8A8A8A),
                      ),
              ),
            ),
          ),
        );
      }
    });
  }

  Widget _buildUserSection() {
    return LayoutBuilder(builder: (context, constraints) {
      bool showExpanded = constraints.maxWidth > 150;

      if (showExpanded) {
        // Expanded: Full user card
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
      } else {
        // Collapsed: Avatar only (centered)
        return Center(
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade300,
            child: Text(
              widget.user.initials,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 13,
              ),
            ),
          ),
        );
      }
    });
  }
}
