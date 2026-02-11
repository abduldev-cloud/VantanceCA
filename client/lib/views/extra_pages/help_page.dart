import 'package:vantanceCA/views/extra_pages/widgets/chat_content.dart';
import 'package:flutter/material.dart';
import 'package:vantanceCA/views/extra_pages/widgets/faqs_content.dart';
// import 'package:vantanceCA/views/extra_pages/widgets/chat_page_content.dart';
import 'package:vantanceCA/views/extra_pages/widgets/support_content.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/views/layouts/layout.dart';

import 'package:vantanceCA/helpers/storage/local_storage.dart';
class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> with UIMixin {
  int _selectedIndex = 0;


  final List<String> _tabs = [
    "FAQ", "Chat", 
    if (LocalStorage.getIsDemoSchool() != "Y") "Support",
   ];

  final List<String> _headings = [
    "Help - Frequently Asked Questions",
    "Help - Chat",
    if (LocalStorage.getIsDemoSchool() != "Y") "Help - Support Ticket",
  ];

  final List<String> _subHeadings = [
    "A quick reference to help you navigate and get the most out of our platform.",
    "Start a conversation and get real-time assistance.",
    "Get quick, reliable support through our Help Desk.",
  ];

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16, left: 2, right: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading
              Text(
                _headings[_selectedIndex],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Subheading
              Text(
                _subHeadings[_selectedIndex],
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 14),

              // Main container fills the rest
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 25, bottom: 35),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(40, 44, 62, 80),
                        blurRadius: 24,
                        spreadRadius: 1,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Tab Buttons
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: List.generate(_tabs.length, (index) {
                            final isSelected = _selectedIndex == index;
                            return InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () {
                                setState(() {
                                  _selectedIndex = index;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFFEEECFF),
                                            Color(0xFFEEECFF),
                                            Color(0xFFDBEBFF),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.transparent,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.08),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  _tabs[index],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Content section
                      Expanded(
                        child: IndexedStack(
                          index: _selectedIndex,
                          children: const [
                            SizedBox.expand(child: FAQPageContent()),
                            SizedBox.expand(child: ChatPageContent()),
                            SizedBox.expand(child: SupportPageContent()),
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
      ),
    );
  }
}