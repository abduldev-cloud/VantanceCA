import 'package:flutter/material.dart';

class PracticesPage extends StatefulWidget {
  final VoidCallback? onStartPractice;
  final VoidCallback? onViewReport;

  const PracticesPage({
    super.key,
    this.onStartPractice,
    this.onViewReport,
  });

  @override
  State<PracticesPage> createState() => _PracticesPageState();
}

class _PracticesPageState extends State<PracticesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Upcoming'; // Default to Upcoming
  String _searchQuery = "";
  String? _frequencyFilter;

  // Data Source
  final Map<String, List<Map<String, dynamic>>> _practiceData = {
    'Pending': [
      {
        'title': "Meaning Scope of Accounting",
        'description':
            "Lorem ipsum is simply dummy text of the printing and typesetting industry.",
        'subject': "Accountancy",
        'month': "May 2025",
        'date': "05/12/2025",
        'time': "08:36 AM",
        'duration': "00:10:30",
        'questions': "20",
        'frequency': "Daily",
        'showButton': true,
      },
    ],
    'Upcoming': [
      {
        'title': "Meaning Scope of Accounting",
        'description':
            "Lorem ipsum is simply dummy text of the printing and typesetting industry.",
        'subject': "Accountancy",
        'month': "May 2025",
        'date': "05/12/2025",
        'time': "08:36 AM",
        'duration': "00:10:30",
        'questions': "20",
        'frequency': "Daily",
        'showButton': false,
      },
      {
        'title': "Cost and Management Accounting",
        'description':
            "Lorem ipsum is simply dummy text of the printing and typesetting industry.",
        'subject': "Accountancy",
        'month': "May 2025",
        'date': "05/12/2025",
        'time': "08:36 AM",
        'duration': "00:10:30",
        'questions': "20",
        'frequency': "Weekly",
        'showButton': false,
      },
      {
        'title': "Financial Management",
        'description':
            "Lorem ipsum is simply dummy text of the printing and typesetting industry.",
        'subject': "Accountancy",
        'month': "May 2025",
        'date': "05/12/2025",
        'time': "08:36 AM",
        'duration': "00:10:30",
        'questions': "20",
        'frequency': "Mock Revision",
        'showButton': false,
      },
    ],
    'Completed': [
      {
        'title': "Meaning Scope of Accounting",
        'description':
            "Lorem ipsum is simply dummy text of the printing and typesetting industry.",
        'subject': "Accountancy",
        'month': "2025",
        'date': "05/12/2025",
        'score': "08/10",
        'questions': "20",
        'duration': "00:30:00",
        'frequency': "Daily",
        'buttonText': "View Report",
        'showButton': true,
      },
      {
        'title': "Cost and Management Accounting",
        'description':
            "Lorem ipsum is simply dummy text of the printing and typesetting industry.",
        'subject': "Accountancy",
        'month': "2025",
        'date': "04/12/2025",
        'score': "07/10",
        'questions': "10",
        'duration': "00:15:00",
        'frequency': "Weekly",
        'buttonText': "View Report",
        'showButton': true,
      },
      {
        'title': "Financial Management",
        'description':
            "Lorem ipsum is simply dummy text of the printing and typesetting industry.",
        'subject': "Accountancy",
        'month': "2025",
        'date': "03/12/2025",
        'score': "09/10",
        'questions': "25",
        'duration': "00:35:00",
        'frequency': "Mock Revision",
        'buttonText': "View Report",
        'showButton': true,
      },
    ],
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToPracticeScreen() {
    if (widget.onStartPractice != null) {
      widget.onStartPractice!();
    }
  }

  void _navigateToReportScreen() {
    if (widget.onViewReport != null) {
      widget.onViewReport!();
    }
  }

  void _selectFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  List<Widget> _getFilteredPracticeCards() {
    List<Map<String, dynamic>> practices = _practiceData[_selectedFilter] ?? [];

    // Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      practices = practices.where((p) {
        final title = (p['title'] as String).toLowerCase();
        final desc = (p['description'] as String).toLowerCase();
        return title.contains(_searchQuery.toLowerCase()) ||
            desc.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by Frequency
    if (_frequencyFilter != null) {
      practices = practices.where((p) {
        return p['frequency'] == _frequencyFilter;
      }).toList();
    }

    if (practices.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(
            child: Text(
              "No practices found",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        )
      ];
    }

    return practices.map((data) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _PracticeItemCard(
          title: data['title'],
          description: data['description'],
          subject: data['subject'],
          month: data['month'],
          date: data['date'],
          time: data['time'],
          duration: data['duration'],
          questions: data['questions'],
          frequency: data['frequency'],
          score: data['score'],
          buttonText: data['buttonText'],
          showButton: data['showButton'] ?? true,
          onStartPractice: data['buttonText'] == "View Report"
              ? _navigateToReportScreen
              : _navigateToPracticeScreen,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP HEADER
              const Text(
                "Practices",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Lorem ipsum is simply dummy text of the printing and typesetting industry.",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 24),

              // SUMMARY CARDS ROW
              // SUMMARY CARDS ROW
              LayoutBuilder(builder: (context, constraints) {
                final bool isMobile = constraints.maxWidth < 600;

                final card1 = _SummaryCard(
                  label: "Pending",
                  count: "1",
                  countColor: const Color(0xFFF24E1E),
                  isSelected: _selectedFilter == 'Pending',
                  onTap: () => _selectFilter('Pending'),
                );

                final card2 = _SummaryCard(
                  label: "Upcoming",
                  count: "4",
                  countColor: const Color(0xFFF2A900),
                  isSelected: _selectedFilter == 'Upcoming',
                  onTap: () => _selectFilter('Upcoming'),
                );

                final card3 = _SummaryCard(
                  label: "Completed",
                  count: "3",
                  countColor: const Color(0xFF30C46A),
                  isSelected: _selectedFilter == 'Completed',
                  onTap: () => _selectFilter('Completed'),
                );

                if (isMobile) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      card1,
                      const SizedBox(height: 16),
                      card2,
                      const SizedBox(height: 16),
                      card3,
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(child: card1),
                      const SizedBox(width: 16),
                      Expanded(child: card2),
                      const SizedBox(width: 16),
                      Expanded(child: card3),
                    ],
                  );
                }
              }),

              const SizedBox(height: 24),

              // SEARCH + FILTER ROW (Right-aligned)
              LayoutBuilder(builder: (context, constraints) {
                final bool isMobile = constraints.maxWidth < 600;

                Widget searchWidget = Container(
                  width: isMobile ? null : 200,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search",
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade500,
                        size: 18,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                );

                if (isMobile) {
                  searchWidget = Expanded(child: searchWidget);
                }

                return Row(
                  mainAxisAlignment:
                      isMobile ? MainAxisAlignment.start : MainAxisAlignment.end,
                  children: [
                    searchWidget,
                    const SizedBox(width: 12),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        setState(() {
                          if (_frequencyFilter == value) {
                            _frequencyFilter = null; // Toggle off
                          } else {
                            _frequencyFilter = value;
                          }
                        });
                      },
                      offset: const Offset(0, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      elevation: 4,
                      itemBuilder: (context) =>
                          ['Daily', 'Weekly', 'Mock Revision'].map((option) {
                        final isSelected = _frequencyFilter == option;
                        return PopupMenuItem<String>(
                          value: option,
                          padding: EdgeInsets.zero,
                          height: 40,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            color: isSelected
                                ? const Color(0xFFF2F2F2)
                                : Colors.transparent,
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected
                                    ? Colors.black
                                    : Colors.grey.shade800,
                                fontWeight: isSelected
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.tune,
                              color: Colors.grey.shade700,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Filter",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 24),

              // PRACTICE ITEM CARDS (FILTERED)
              ..._getFilteredPracticeCards(),
            ],
          ),
        ),
      ),
    );
  }
}

// SUMMARY CARD WIDGET
class _SummaryCard extends StatefulWidget {
  final String label;
  final String count;
  final Color countColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.countColor,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  State<_SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<_SummaryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: widget.isSelected ? const Color(0xFFFAFAFA) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.12 : 0.08),
                blurRadius: _isHovered ? 20 : 16,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: widget.isSelected
                      ? Colors.grey.shade800
                      : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.count,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: widget.countColor,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// PRACTICE ITEM CARD WIDGET
class _PracticeItemCard extends StatefulWidget {
  final String title;
  final String description;
  final String? subject;
  final String? month;
  final String? date;
  final String? time;
  final String? duration;
  final String? questions;
  final String? frequency;
  final String? score;
  final String? buttonText;
  final bool showButton;
  final VoidCallback onStartPractice;

  const _PracticeItemCard({
    required this.title,
    required this.description,
    this.subject,
    this.month,
    this.date,
    this.time,
    this.duration,
    this.questions,
    this.frequency,
    this.score,
    this.buttonText,
    this.showButton = true,
    required this.onStartPractice,
  });

  @override
  State<_PracticeItemCard> createState() => _PracticeItemCardState();
}

class _PracticeItemCardState extends State<_PracticeItemCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),

              // Description
              Text(
                widget.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),

              // METADATA ROW
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (widget.subject != null)
                    _MetadataItem(
                      icon: Icons.bookmark_border,
                      text: widget.subject!,
                    ),
                  if (widget.month != null)
                    _MetadataItem(
                      icon: Icons.calendar_today_outlined,
                      text: widget.month!,
                    ),
                  if (widget.date != null)
                    _MetadataItem(
                      icon: Icons.event_outlined,
                      text: widget.date!,
                    ),
                  if (widget.score != null)
                    _MetadataItem(
                      icon: Icons.star_border,
                      text: widget.score!,
                    ),
                  if (widget.questions != null)
                    _MetadataItem(
                      icon: Icons.help_outline,
                      text: widget.questions!,
                    ),
                  if (widget.time != null)
                    _MetadataItem(
                      icon: Icons.access_time,
                      text: widget.time!,
                    ),
                  if (widget.duration != null)
                    _MetadataItem(
                      icon: Icons.timer_outlined,
                      text: widget.duration!,
                    ),
                  if (widget.frequency != null)
                    _MetadataItem(
                      icon: widget.frequency == 'Daily'
                          ? Icons.calendar_today_outlined
                          : Icons.calendar_view_month_outlined,
                      text: widget.frequency!,
                      iconColor: const Color(0xFF6E6E6E),
                      iconSize: 18,
                      textColor: const Color(0xFF000000),
                      fontSize: 14,
                      spacing: 6,
                    ),
                ],
              ),
            ],
          );

          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                if (widget.showButton) ...[
                  const SizedBox(height: 20),
                  // Button full width or aligned? width: double.infinity usually good for mobile actions
                  SizedBox(
                    width: double.infinity,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) => setState(() => _isHovered = true),
                      onExit: (_) => setState(() => _isHovered = false),
                      child: GestureDetector(
                        onTap: widget.onStartPractice,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _isHovered
                                ? const Color(0xFFF8F8F8)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: _isHovered
                                  ? const Color(0xFFD0D0D0)
                                  : const Color(0xFFE0E0E0),
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.buttonText ?? "Start Practice",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT SIDE - CONTENT
                Expanded(
                  child: content,
                ),

                if (widget.showButton) ...[
                  const SizedBox(width: 20),

                  // RIGHT SIDE - BUTTON
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _isHovered = true),
                    onExit: (_) => setState(() => _isHovered = false),
                    child: GestureDetector(
                      onTap: widget.onStartPractice,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _isHovered
                              ? const Color(0xFFF8F8F8)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: _isHovered
                                ? const Color(0xFFD0D0D0)
                                : const Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.buttonText ?? "Start Practice",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          }
        },
      ),
    );
  }
}

// METADATA ITEM WIDGET
class _MetadataItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final double iconSize;
  final double fontSize;
  final Color? textColor;
  final double spacing;

  const _MetadataItem({
    required this.icon,
    required this.text,
    this.iconColor,
    this.iconSize = 14,
    this.fontSize = 12,
    this.textColor,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: iconColor ?? Colors.grey.shade600,
        ),
        SizedBox(width: spacing),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor ?? Colors.grey.shade700,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
