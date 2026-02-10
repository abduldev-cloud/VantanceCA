import 'package:binary_success/helpers/utils/datetime_utils.dart';
import 'package:binary_success/models/integration_log_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogsTable extends StatelessWidget {
  final List<IntegrationLog> logs;
  const LogsTable({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(5),
      },
      children: [
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Text(
                  "Log Date & Time",
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Text(
                  "Message",
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        if (logs.isEmpty)
          const TableRow(children: [
            TableCell(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Text("No logs available"),
              ),
            ),
            TableCell(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Text("-"),
              ),
            ),
          ])
        else
          ...logs.map((IntegrationLog log) {
            return TableRow(
              children: [
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text(
                      _formatDateTime(DateTimeUtils.utcIsoToLocalDateTime(log.datetime.toString())!),
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text(log.message),
                  ),
                ),
              ],
            );
          },
          ),
      ],
    );
  }

  static String _formatDateTime(DateTime dateTime) {
    return "${dateTime.toLocal()}".split('.')[0]; // simple format
  }
}
