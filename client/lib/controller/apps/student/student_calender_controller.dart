import 'package:vantanceCA/helpers/services/student_service.dart';
import 'package:vantanceCA/models/student_calendar_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vantanceCA/controller/my_controller.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../helpers/storage/local_storage.dart';

class StudentCalenderController extends MyController {
  RxInt selectedTabIndex = 0.obs;
  CalendarController calendarController = CalendarController();
  Rx<StudentCalendarModel> studentCalenderList = StudentCalendarModel().obs;
  RxBool isLoading = false.obs;
  RxList<Appointment> appointments = <Appointment>[].obs;
  RxInt currentMonth = DateTime.now().month.obs;
  RxInt currentYear = DateTime.now().year.obs;

  Future<void> getStudentClassData(
      {required int taskMonth, required int taskYear}) async {
    isLoading(true);

    final entityId = LocalStorage.getDBEntityID();
    print("✅ Entity ID fetched from LocalStorage: $entityId");

    if (entityId == null || entityId.isEmpty) {
      print("❌ No entityId found in LocalStorage");
      isLoading(false);
      return;
    }

    final response = await StudentService.getStudentCalendarAPI(
      learnerId: entityId,
      taskMonth: taskMonth,
      taskYear: taskYear,
    );

    if (response != null) {
      studentCalenderList.value = StudentCalendarModel.fromJson(response.data);
      _updateAppointments();
      isLoading(false);
    } else {
      isLoading(false);
    }
  }

  void updateCalendarMonthYear(int month, int year) {
    if (month != currentMonth.value || year != currentYear.value) {
      currentMonth.value = month;
      currentYear.value = year;
      getStudentClassData(taskMonth: month, taskYear: year);
    }
  }

  void _updateAppointments() {
    final List<Appointment> newAppointments = [];

    if (studentCalenderList.value.tasksDueSummary != null) {
      for (var task in studentCalenderList.value.tasksDueSummary!) {
        if (task.dueDate != null) {
          final startTime = task.dueDate!.toLocal();
          // Set a default 30-minute duration for tasks (adjust if needed)
          final endTime = startTime.add(const Duration(minutes: 30));

          newAppointments.add(
            Appointment(
              id: task.taskId,
              startTime: startTime,
              endTime: endTime,
              subject: task.className ?? 'Untitled Task',
              notes: task.taskTitle,
              color: Colors.deepPurple,
              isAllDay: false,
            ),
          );
        }
      }
    }

    appointments.assignAll(newAppointments);
  }

  @override
  void onInit() {
    getStudentClassData(
        taskMonth: currentMonth.value, taskYear: currentYear.value);
    super.onInit();
  }
}
