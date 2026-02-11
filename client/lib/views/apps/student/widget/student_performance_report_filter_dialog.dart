import 'package:flutter/material.dart';
import 'package:vantanceCA/models/student_performance_report_question_model.dart';

class FilterDropdown extends StatelessWidget {
  final Function(QuestionStatus?) onSelected;

  const FilterDropdown({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        // Convert string back to QuestionStatus?
        QuestionStatus? status;
        switch (value) {
          case 'all':
            status = null;
            break;
          case 'notAnswered':
            status = QuestionStatus.notAnswered;
            break;
          case 'wrongAnswered':
            status = QuestionStatus.wrongAnswered;
            break;
          case 'partiallyAnswered':
            status = QuestionStatus.partiallyAnswered;
            break;
          case 'correctAnswered':
            status = QuestionStatus.correctAnswered;
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
          borderRadius: BorderRadius.circular(4),
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
