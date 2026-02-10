import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DateTimePickerController extends GetxController {
  RxString selectedDate = ''.obs;
  RxString selectedTime = ''.obs;
  RxBool isDateSelected = false.obs;
  RxBool isTimeSelected = false.obs;

  String? _lastInvalidTime;

  void updateSelectedDate(String date) {
    selectedDate.value = date;
    isDateSelected.value = date.isNotEmpty;

    // Reset time if invalid after date change
    if (isTimeSelected.value && !_isValidTime(selectedTime.value)) {
      selectedTime.value = '';
      isTimeSelected.value = false;
    }
  }

  void updateSelectedTime(String time) {
    if (time.isEmpty) {
      selectedTime.value = '';
      isTimeSelected.value = false;
      return;
    }

    if (_isValidTime(time)) {
      selectedTime.value = time;
      isTimeSelected.value = true;
      _lastInvalidTime = null;
    } else {
      if (_lastInvalidTime != time) {
        Get.snackbar("Invalid Time", "The selected time is earlier than now.");
        _lastInvalidTime = time;
      }
      selectedTime.value = '';
      isTimeSelected.value = false;
    }
  }

  bool _isValidTime(String time) {
    try {
      if (!isDateSelected.value) return true;

      final dateFormat = DateFormat('MMM dd, yyyy');
      final timeFormat = DateFormat('hh:mm a');

      final selectedDateObj = dateFormat.parse(selectedDate.value);
      final selectedTimeObj = timeFormat.parse(time);

      final now = DateTime.now();

      final selectedDateTime = DateTime(
        selectedDateObj.year,
        selectedDateObj.month,
        selectedDateObj.day,
        selectedTimeObj.hour,
        selectedTimeObj.minute,
      );

      if (_isSameDay(selectedDateObj, now)) {
        return selectedDateTime.isAfter(now);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  void reset() {
    selectedDate.value = '';
    selectedTime.value = '';
    isDateSelected.value = false;
    isTimeSelected.value = false;
    _lastInvalidTime = null;
  }

  String getFormattedDateTime() {
    if (isDateSelected.value && isTimeSelected.value) {
      try {
        final dateFormat = DateFormat('MMM dd, yyyy');
        final date = dateFormat.parse(selectedDate.value);

        final timeFormat = DateFormat('hh:mm a');
        final time = timeFormat.parse(selectedTime.value);

        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        return dateTime.toIso8601String();
      } catch (e) {
        return DateTime.now().toIso8601String();
      }
    } else if (isDateSelected.value) {
      try {
        final dateFormat = DateFormat('MMM dd, yyyy');
        final date = dateFormat.parse(selectedDate.value);
        final dateTime = DateTime(date.year, date.month, date.day);
        return dateTime.toIso8601String();
      } catch (e) {
        return DateTime.now().toIso8601String();
      }
    }
    return DateTime.now().toIso8601String();
  }
}
