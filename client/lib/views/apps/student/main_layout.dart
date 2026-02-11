import 'package:vantanceCA/models/user.dart';
import 'package:vantanceCA/views/apps/student/widget/collapsible_sidebar.dart';
import 'package:flutter/material.dart';
import 'practice_screen.dart'; // Keep if used elsewhere or remove if not needed? Leaving for safety but ideally cleanup.
import 'papers_screen.dart';
// import 'settings_screen.dart'; // Removed old settings (Actually restoring it now)
import 'settings_screen.dart'; // CONNECTED: Replaces student_setting_page.dart
import 'practices_page.dart'; // Restored practices page
import 'student_calender_page.dart';
import 'student_performance_report.dart'; // New import
// import 'student_setting_page.dart'; // DISCONNECTED: Old setting page
import 'student_subscription_page.dart'; // To access SubscriptionPage definition
import 'student_security_privacy_page.dart'; // Added import
import 'student_result_page.dart'; // Added import

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String _selectedMenuItem = 'Calendar';
  bool _isInPracticeSession = false;
  bool _isSidebarOpen = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 800;

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Collapsible Sidebar with shadow
          Stack(
            clipBehavior: Clip.none,
            children: [
              CollapsibleSidebar(
                onMenuItemTap: _handleMenuItemTap,
                user: User.demo, // Using demo user for now
                isOpen: _isSidebarOpen,
                onToggle: () {
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                },
              ),
            ],
          ),

          // Main Content Area - Hide on mobile when sidebar is open
          if (!isMobile || !_isSidebarOpen)
            Expanded(
              child: Container(
                color: Colors.grey.shade50,
                child: _buildMainContent(),
              ),
            ),
        ],
      ),
    );
  }

  void _handleMenuItemTap(String menuItem) {
    // If user is in an active practice session and trying to leave, show confirmation dialog
    if (_isInPracticeSession && menuItem != 'Practices') {
      _showLeaveConfirmationDialog(menuItem);
    } else {
      setState(() {
        _selectedMenuItem = menuItem;
        _isInPracticeSession = false; // Reset practice session state
      });
    }
  }

  void _startPracticeSession() {
    setState(() {
      _isInPracticeSession = true;
    });
  }

  void _exitPracticeSession() {
    setState(() {
      _isInPracticeSession = false;
    });
  }

  void _showLeaveConfirmationDialog(String newMenuItem) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(40),
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon at the top
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Icon(
                    Icons.exit_to_app_rounded,
                    size: 32,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Leave Practice?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  'Are you sure you want to leave the current practice page? Your progress and timer will be saved, and you can resume later.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Color(0xFF666666),
                    letterSpacing: 0.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // Buttons
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(
                            color: Color(0xFFE0E0E0),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: const Color(0xFF666666),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Leave button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _selectedMenuItem = newMenuItem;
                            _isInPracticeSession =
                                false; // Reset practice session state
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Leave',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    switch (_selectedMenuItem) {
      case 'Performance': // Changed from Practices
        return const PerformanceReportPage();

      case 'Papers':
        return PapersScreen(
          onNavigateToPractice: () {
            setState(() {
              _selectedMenuItem = 'Practices'; // Update to Practices
            });
          },
        );

      case 'PracticeSession': // Internal state for active practice
        return QuizScreenExact(
          onExit: () {
            setState(() {
              _selectedMenuItem = 'Practices';
              _isInPracticeSession = false;
            });
          },
        );

      case 'Practices':
        return PracticesPage(
          onStartPractice: () {
            setState(() {
              _selectedMenuItem = 'PracticeSession';
              _isInPracticeSession = true;
            });
          },
          onViewReport: () {
            setState(() {
              _selectedMenuItem = 'Performance';
            });
          },
        );

      case 'Result':
        return const StudentResultPage();

      case 'Calendar':
        return const StudentCalenderPage();

      case 'Settings':
        return SettingsScreen(
          onOpenSubscription: () {
            setState(() {
              _selectedMenuItem = 'Subscription';
            });
          },
          onOpenSecurity: () {
            setState(() {
              _selectedMenuItem = 'Security';
            });
          },
        );

      case 'Subscription':
        return SubscriptionPage(
          onBack: () {
            setState(() {
              _selectedMenuItem = 'Settings';
            });
          },
        );

      case 'Security':
        return SecurityPrivacyPage(
          onBack: () {
            setState(() {
              _selectedMenuItem = 'Settings';
            });
          },
        );

      default:
        return const PerformanceReportPage(); // Default to Performance
    }
  }
}
