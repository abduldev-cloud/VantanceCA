import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class StudentCalenderPage extends StatefulWidget {
  const StudentCalenderPage({super.key});

  @override
  State<StudentCalenderPage> createState() => _StudentCalenderPageState();
}

class _StudentCalenderPageState extends State<StudentCalenderPage> {
  final CalendarController _calendarController = CalendarController();
  CalendarView _currentView = CalendarView.month;
  DateTime _displayDate = DateTime.now();
  List<Appointment> _appointments = <Appointment>[];

  @override
  void initState() {
    super.initState();
    _appointments = <Appointment>[]; // Start with no events
  }

  void _onViewChanged(CalendarView view) {
    setState(() {
      _currentView = view;
      _calendarController.view = view;
      if (view == CalendarView.day) {
        _displayDate = DateTime.now();
        _calendarController.displayDate = _displayDate;
      }
    });
  }

  void _previous() {
    _calendarController.backward!();
  }

  void _next() {
    _calendarController.forward!();
  }

  void _addEvent(DateTime date) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController titleController = TextEditingController();
        return AlertDialog(
          title: Text('Add Reminder',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              hintText: 'Event Title',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    _appointments.add(Appointment(
                      startTime: date,
                      endTime: date.add(const Duration(hours: 1)),
                      subject: titleController.text,
                      color: const Color(0xff8E8E93), // Purple color
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _formatMonthYear(DateTime date) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Light grey background
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16.0 : 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Text(
              'Calendar',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track upcoming assignments and deadlines',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 30),

            // Main Calendar Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.all(isMobile ? 12.0 : 20.0),
              height: 700,
              child: Column(
                children: [
                  // Custom Calendar Header
                  _buildCustomHeader(),
                  const SizedBox(height: 20),
                  // Calendar Content
                  Expanded(
                    child: SfCalendar(
                      controller: _calendarController,
                      view: _currentView,
                      dataSource: _DataSource(_appointments),
                      backgroundColor: Colors.white,
                      headerHeight: 0,
                      firstDayOfWeek: 7, // Sunday

                      // Month Styling
                      monthViewSettings: const MonthViewSettings(
                        appointmentDisplayMode:
                            MonthAppointmentDisplayMode.appointment,
                        showAgenda: false,
                        numberOfWeeksInView: 6,
                        monthCellStyle: MonthCellStyle(
                          textStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          trailingDatesTextStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Color(0xFFBDBDBD),
                          ),
                          leadingDatesTextStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Color(0xFFBDBDBD),
                          ),
                        ),
                      ),

                      // Schedule Styling
                      scheduleViewSettings: const ScheduleViewSettings(
                        appointmentItemHeight: 50,
                        hideEmptyScheduleWeek: false,
                        monthHeaderSettings: MonthHeaderSettings(height: 0),
                      ),

                      // Time Slot Styling
                      timeSlotViewSettings: const TimeSlotViewSettings(
                        timeFormat: 'h a',
                        timeIntervalHeight: 80,
                        timeTextStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Color(0xFF757575),
                        ),
                      ),

                      // Headers
                      viewHeaderStyle: ViewHeaderStyle(
                        dayTextStyle: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF757575),
                        ),
                        dateTextStyle: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),

                      todayHighlightColor: const Color(0xFF2196F3),
                      todayTextStyle: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      selectionDecoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.transparent),
                      ),

                      // View Changed Callback
                      onViewChanged: (ViewChangedDetails details) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted && details.visibleDates.isNotEmpty) {
                            final int midIndex =
                                details.visibleDates.length ~/ 2;
                            setState(() {
                              _displayDate = details.visibleDates[midIndex];
                            });
                          }
                        });
                      },
                      onTap: (CalendarTapDetails details) {
                        if (details.targetElement ==
                                CalendarElement.calendarCell &&
                            details.date != null) {
                          _addEvent(details.date!);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isMobile = constraints.maxWidth < 600;

      if (isMobile) {
        return Column(
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 10.0,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _previous,
                        icon: const Icon(Icons.chevron_left,
                            color: Color(0xFF616161)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: _next,
                        icon: const Icon(Icons.chevron_right,
                            color: Color(0xFF616161)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatMonthYear(_displayDate),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildViewButton('Today', CalendarView.day),
                  const SizedBox(width: 8),
                  _buildViewButton('Month', CalendarView.month),
                  const SizedBox(width: 8),
                  _buildViewButton('Schedule', CalendarView.schedule),
                ],
              ),
            ),
          ],
        );
      } else {
        return Row(
          children: [
            IconButton(
              onPressed: _previous,
              icon: const Icon(Icons.chevron_left, color: Color(0xFF616161)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: _next,
              icon: const Icon(Icons.chevron_right, color: Color(0xFF616161)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 24),
            Text(
              _formatMonthYear(_displayDate),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const Spacer(),
            // Pill Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildViewButton('Today', CalendarView.day),
                const SizedBox(width: 8),
                _buildViewButton('Month', CalendarView.month),
                const SizedBox(width: 8),
                _buildViewButton('Schedule', CalendarView.schedule),
              ],
            ),
          ],
        );
      }
    });
  }

  Widget _buildViewButton(String label, CalendarView view) {
    final bool isActive = _currentView == view;

    return InkWell(
      onTap: () => _onViewChanged(view),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xff8E8E93) : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? const Color(0xff8E8E93) : const Color(0xFF616161),
          ),
        ),
      ),
    );
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}
