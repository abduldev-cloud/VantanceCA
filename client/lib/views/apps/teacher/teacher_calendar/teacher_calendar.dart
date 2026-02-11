
import 'package:vantanceCA/controller/apps/teacher/teacher_calendar_controller.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_card.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/views/layouts/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class TeacherCalendarPage extends StatefulWidget {
  const TeacherCalendarPage({super.key});

  @override
  TeacherCalendarPageState createState() => TeacherCalendarPageState();
}

class TeacherCalendarPageState extends State<TeacherCalendarPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late TeacherCalendarController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TeacherCalendarController());
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      selectedPage: 5,
      child: GetBuilder<TeacherCalendarController>(
        builder: (controller) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.titleMedium(
                  "Calendar",
                  style: GoogleFonts.inter(
                    fontSize: 28.sp,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                    color: contentTheme.k142228,
                  ),
                ),
                MyText.bodySmall(
                  "Track upcoming assignments and deadlines",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: contentTheme.k142228,
                  ),
                ),
                MySpacing.height(35),
                MyCard(
                  width: MySpacing.fullWidth(context) * .75,
                  borderRadiusAll: 25,
                  marginAll: 8,
                  height: MySpacing.fullHeight(context) * 1.2,
                  paddingAll: 25,
                  child: Obx(
                    () => SfCalendar(
                      controller: controller.calendarController,
                      showCurrentTimeIndicator: true,
                      showDatePickerButton: true,
                      showTodayButton: true,
                      showNavigationArrow: true,
                      view: CalendarView.month, // Month view only
                     allowedViews: const [
  CalendarView.month,
  CalendarView.schedule
],
                      backgroundColor: Colors.white,
                      dataSource: _TaskDataSource(controller.appointments.value),
                      allowViewNavigation: true,
                      timeZone: 'Atlantic Standard Time',
                      // Removed allowedViews for restriction, handled externally
                      headerStyle: CalendarHeaderStyle(
                        textStyle: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        backgroundColor: Colors.white,
                      ),
                      showWeekNumber: false,
                      todayHighlightColor: contentTheme.primary,
                      allowDragAndDrop: false,
                      allowAppointmentResize: false,
                      appointmentBuilder: appointmentBuilder,
                      monthCellBuilder: monthCellBuilder,
                      monthViewSettings: const MonthViewSettings(
                        monthCellStyle: MonthCellStyle(textStyle: TextStyle()),
                        appointmentDisplayCount: 2,
                        showTrailingAndLeadingDates: false,
                        appointmentDisplayMode:
                            MonthAppointmentDisplayMode.appointment,
                      ),
                    timeSlotViewSettings: const TimeSlotViewSettings(
  timeIntervalHeight: 100, // was 70
  timeInterval: Duration(hours: 1), // keep 1 hour per slot
),

                    onTap: (CalendarTapDetails details) {
  if (details.targetElement == CalendarElement.appointment &&
      details.appointments != null &&
      details.appointments!.isNotEmpty) {
    final Appointment tapped = details.appointments!.first;

    if (tapped.notes == "assignment" && tapped.id != null) {
      Get.toNamed(
        "/teacher/assignmentdetail",
        arguments: {"taskId": tapped.id},
      );
    } else if (tapped.notes == "fingerprint" && tapped.id != null) {
      Get.toNamed(
        "/teacher/fingerprintdetail",
        arguments: {"taskId": tapped.id},
      );
    }
  }
},

                      onViewChanged: (ViewChangedDetails details) {
                        final DateTime visibleDate =
                            details.visibleDates[details.visibleDates.length ~/ 2];
                        controller.updateCalendarMonthYear(
                            visibleDate.month, visibleDate.year);
                      },
                    ),
                  ),
                ),
              ],
            ).paddingOnly(
              right: MySpacing.fullWidth(context) * 0.04,
            ),
          );
        },
      ),
    );
  }
Widget monthCellBuilder(BuildContext buildContext, MonthCellDetails details) {
    final Color backgroundColor = Colors.white;
    final Color defaultColor = Theme.of(buildContext).brightness == Brightness.dark ? Colors.black12 : Colors.black12;
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: defaultColor, width: 0.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isToday(details.date)
            ? Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      details.date.day.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            : Text(
                details.date.day.toString(),
                style: const TextStyle(color: Colors.black),
              ),
      ),
    );
  }
Widget appointmentBuilder(
    BuildContext context, CalendarAppointmentDetails calendarAppointmentDetails) {
  final Appointment appointment = calendarAppointmentDetails.appointments.first;

  // Calculate available height from cell
  final double availableHeight = calendarAppointmentDetails.bounds.height;

  // Dynamically set task height based on view
  final bool isMonthView = availableHeight < 80; // Month view cells are usually small
  final double taskHeight = isMonthView
      ? availableHeight * 0.9 // Month view: slightly larger but close
      : availableHeight * 1; // Day view: use almost full height

  return Stack(
    clipBehavior: Clip.none,
    children: [
      // TASK CONTAINER
      Container(
        height: isMonthView
            ? taskHeight.clamp(24, 34) // Month view -> compact
            : taskHeight.clamp(42, 56), // Day view -> more height
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        margin: EdgeInsets.symmetric(
          horizontal: 4,
          vertical: isMonthView ? 1 : 3, // Month view -> very little gap
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
            colors: [
              contentTheme.primary.withAlpha(77),
              const Color(0xff004AAD).withAlpha(77),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        Flexible(
  child: Text(
    appointment.subject ?? 'No Class', // className
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    ),
  ),
),
const SizedBox(height: 1),
Flexible(
  child: Text(
    appointment.location ?? 'Untitled Task', // taskTitle
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
      fontSize: 12,
      color: Colors.black,
    ),
  ),
),
 
          ],
        ),
      ),

      // "MORE" ICON — FLOATING (BOTTOM-RIGHT OUTSIDE TASKS)
      if (calendarAppointmentDetails.isMoreAppointmentRegion)
        Positioned(
          right: -1,
          bottom: isMonthView ? 0 : 1,
          child: Container(
           
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 8, 8, 8),
            ),
            child: const Icon(
              Icons.more_horiz,
              size: 12,
              color: Color.fromARGB(255, 246, 249, 252),
            ),
          ),
        ),
    ],
  );
}



  bool _isToday(DateTime date) {
    final DateTime now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class _TaskDataSource extends CalendarDataSource {
  _TaskDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) => appointments![index].startTime;

  @override
  DateTime getEndTime(int index) => appointments![index].endTime;

  @override
  String getSubject(int index) => "${appointments![index].subject}";
  @override
  Color getColor(int index) => appointments![index].color;

  @override
  bool isAllDay(int index) => false;
}
