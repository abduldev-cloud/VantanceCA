import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widget/result_card.dart';
import 'package:binary_success/models/result_model.dart';
import 'package:binary_success/services/result_service.dart';
import 'package:binary_success/views/layouts/layout.dart';

class StudentResultPage extends StatefulWidget {
  const StudentResultPage({super.key});

  @override
  State<StudentResultPage> createState() => _StudentResultPageState();
}

class _StudentResultPageState extends State<StudentResultPage> {
  final TextEditingController _searchController = TextEditingController();
  final ResultService _resultService = ResultService();
  List<ResultModel> _results = [];
  bool _isLoading = true;
  
  FilterStatus _filterStatus = FilterStatus.all;

  List<ResultModel> get _filteredResults {
    // First filter by search text if any
    var list = _results;
    if (_searchController.text.isNotEmpty) {
      list = list.where((item) => 
        item.title.toLowerCase().contains(_searchController.text.toLowerCase()) || 
        item.subject.toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }

    // Then filter by status
    switch (_filterStatus) {
      case FilterStatus.all:
        return list;
      case FilterStatus.notAnswered:
        return list.where((r) => r.na > 0).toList();
      case FilterStatus.wrongAnswered:
        return list.where((r) => r.wa > 0).toList();
      case FilterStatus.partiallyAnswered:
        return list.where((r) => r.pa > 0).toList();
      case FilterStatus.correctAnswered:
        return list.where((r) => r.ca > 0).toList();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadResults();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  Future<void> _loadResults() async {
    try {
      final results = await _resultService.getResults();
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print("Error loading results in UI: $e");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Layout(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final displayList = _filteredResults;

    return Layout(
      shrinkContent: true,
      selectedPage: 2, // Index for Result
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          double padding = isMobile ? 24.0 : 40.0;

          return SingleChildScrollView(
            padding: EdgeInsets.only(top: 24, left: padding, right: padding, bottom: padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isMobile),
                const SizedBox(height: 32),
                _buildFilterRow(isMobile),
                const SizedBox(height: 24),
                displayList.isEmpty 
                  ? Center(child: Text("No results found", style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)))
                  : ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: displayList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = displayList[index];
                        return ResultCard(
                          title: item.title,
                          description: item.description,
                          subject: item.subject,
                          date: item.date,
                          frequency: item.frequency,
                          naCount: item.na,
                          waCount: item.wa,
                          paCount: item.pa,
                          caCount: item.ca,
                        );
                      },
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Results",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF666666),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow(bool isMobile) {
    // In mobile, we might want to stack search and filter
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
               spacing: 12,
               runSpacing: 12,
               alignment: WrapAlignment.end,
               children: [
                 _buildSearchBar(width: double.infinity),
                 ResultFilterDropdown(
                    onSelected: (status) {
                      setState(() {
                         _filterStatus = status ?? FilterStatus.all;
                      });
                    },
                 ),
               ],
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildSearchBar(width: 240),
        const SizedBox(width: 12),
        ResultFilterDropdown(
          onSelected: (status) {
            setState(() {
                _filterStatus = status ?? FilterStatus.all;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar({required double width}) {
    return Container(
      width: width == double.infinity ? null : width,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // Rectangle with curved edge
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search",
          hintStyle: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFFAAAAAA),
          ),
          prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFFAAAAAA)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(top: 10), // Align text vertically
        ),
        style: GoogleFonts.inter(fontSize: 13),
      ),
    );
  }
}

enum FilterStatus {
  all,
  notAnswered,
  wrongAnswered,
  partiallyAnswered,
  correctAnswered
}

class ResultFilterDropdown extends StatelessWidget {
  final Function(FilterStatus?) onSelected;

  const ResultFilterDropdown({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        // Convert string back to FilterStatus?
        FilterStatus? status;
        switch (value) {
          case 'all':
            status = FilterStatus.all;
            break;
          case 'notAnswered':
            status = FilterStatus.notAnswered;
            break;
          case 'wrongAnswered':
            status = FilterStatus.wrongAnswered;
            break;
          case 'partiallyAnswered':
            status = FilterStatus.partiallyAnswered;
            break;
          case 'correctAnswered':
            status = FilterStatus.correctAnswered;
            break;
        }
        onSelected(status);
      },
      surfaceTintColor: Colors.transparent, // Remove red/pink tint
      color: Colors.white,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'all',
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text('All', style: TextStyle(fontSize: 14)),
        ),
        const PopupMenuItem<String>(
          value: 'notAnswered',
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text('NA - Not Answered', style: TextStyle(fontSize: 14)),
        ),
        const PopupMenuItem<String>(
          value: 'wrongAnswered',
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text('WA - Wrong Answered', style: TextStyle(fontSize: 14)),
        ),
        const PopupMenuItem<String>(
          value: 'partiallyAnswered',
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text('PA - Partially Answered', style: TextStyle(fontSize: 14)),
        ),
        const PopupMenuItem<String>(
          value: 'correctAnswered',
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text('CA - Correct Answered', style: TextStyle(fontSize: 14)),
        ),
      ],
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.filter_list, size: 16, color: Colors.black54),
            SizedBox(width: 8),
            Text("Filter", style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
