import 'package:get/get.dart';

class CommonDialogDropdownController extends GetxController {
  RxString selectedValue = ''.obs;
  RxList<String> items = <String>[].obs;

  void updateSelectedValue(String? value) {
    if (value != null) {
      selectedValue.value = value;
    }
  }

  void setItems(List<String> newItems) {
    items.value = newItems;
    if (items.isNotEmpty && selectedValue.value.isEmpty) {
      selectedValue.value = items.first;
    }
  }

  void reset() {
    selectedValue.value = items.isNotEmpty ? items.first : '';
  }
}
