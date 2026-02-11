import 'package:vantanceCA/controller/my_controller.dart';
import 'package:vantanceCA/helpers/widgets/my_text_utils.dart';

class FaqsController extends MyController {
  List<String> dummyTexts =
      List.generate(12, (index) => MyTextUtils.getDummyText(60));
}
