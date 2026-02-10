import 'dart:math';

class Images {
  ///----------------- Brand -----------------------------------//
  static String logoIcon = 'assets/images/logo/colakin_logo.png';
  static String elephant = 'assets/images/logo/main_logo.png';
  static String elephantSmall = 'assets/images/logo/elephantSmall.png';
  static String logoCircle = 'assets/images/logo/logo_circle.png';
  static String loginLogo = 'assets/images/logo/login_logo.png';
  static String shape = 'assets/images/logo/Shape.png';
  static String logoLeftBar = 'assets/images/logo/Logo.png';
  static String logo = 'assets/images/logo/Logo.png';

  ///********************** Icons  *****************************/
  static String basepath = "assets/icon";
  static String googleLogo = 'assets/icon/google.png';
  static String dashboardIcon = '$basepath/dashboard.png';
  static String analytics = '$basepath/analytics.png';
  static String assignments = '$basepath/assignments.png';
  static String attendance = '$basepath/attendance.png';
  static String filterupdate = '$basepath/filterupdate.png';
  static String calendar = '$basepath/calendar.png';
  static String classes = '$basepath/classes.png';
  static String fingerprint = '$basepath/fingerprint.png';
  static String grading = '$basepath/grading.png';
  static String help = '$basepath/help.png';
  static String notification = '$basepath/notification.png';
  static String search = '$basepath/search.png';
  static String setting = '$basepath/setting.png';
  static String students = '$basepath/students.png';
  static String eye = '$basepath/eye.png';
  static String activeAssignment = '$basepath/activeAssignment.png';
  static String grade = '$basepath/grade.png';
  static String clock = '$basepath/clock.png';
  static String book = '$basepath/book.png';
  static String bulb = '$basepath/bulb.png';
  static String checkMark = '$basepath/checkMark.png';
  static String exampleSearch = '$basepath/exampleSearch.png';
  static String pencil = '$basepath/pencil.png';
  static String rubric = '$basepath/rubric.png';
  static String save = '$basepath/save.png';
  static String sendCross = '$basepath/sendCross.png';
  static String star = '$basepath/star.png';
  static String submitArrow = '$basepath/submitArrow.png';
  static String downBarArrow = '$basepath/downBar.png';
  static String upBarArrow = '$basepath/topBar.png';
  static String upload = '$basepath/upload.png';
  static String rightArrow = '$basepath/rightArrow.png';
  static String gradiantFingerprint = '$basepath/gradiantFingerprint.png';
  static String arrow = '$basepath/Arrow.png';
  static String backEditorArrow = '$basepath/backEditorArrow.png';
  static String bulletPoint = '$basepath/bullet_Point.png';
  static String centered = '$basepath/centered.png';
  static String highlightedColor = '$basepath/highlighteColorr.png';
  static String indentLeft = '$basepath/indent_Left.png';
  static String indentRight = '$basepath/indent_Right.png';
  static String italic = '$basepath/Italic.png';
  static String leftAligned = '$basepath/left_aligned.png';
  static String numberedList = '$basepath/numberedList.png';
  static String paintPalette = '$basepath/paintPalette.png';
  static String rightAligned = '$basepath/right_Aligned.png';
  static String rightEditorArrow = '$basepath/rightEditorArrow.png';
  static String spacing = '$basepath/spacing.png';
  static String underlined = '$basepath/Underlined.png';
  static String comment = '$basepath/comment.png';
  static String schoolAdmin = '$basepath/schoolAdmin.png';
  static String comstudentRegisterment = '$basepath/studentRegister.png';
  static String integrations = '$basepath/integrations.png';
  static String canvas = '$basepath/canvas_logo.png';
  static String schoology = '$basepath/schoology_logo.png';
  static String excel = '$basepath/excel_logo.png';
  static String connect = '$basepath/connect.png';
  static String data = '$basepath/data.png';
  static String log = '$basepath/log.png';
  static String guide = '$basepath/guide.png';
  static String school = '$basepath/school.png';
  static String teacher = '$basepath/teacher.png';
  static String student = '$basepath/student.png';
  static String classIcon = '$basepath/class.png';
  static String assignment = '$basepath/assignment.png';
  static String gradeLms = '$basepath/grade_lms.png';
  static String sync = '$basepath/sync.png';
  static String delete = '$basepath/delete.png';
  static String connected = '$basepath/connected.png';
  static String disconnected = '$basepath/disconnected.png';
  static String success = '$basepath/success.png';
  static String unreadNotification = '$basepath/unread_icon.png';
  static String unread = '$basepath/Icon-Bell.png';
  static String performance_icon = '$basepath/hugeicons_assignments.png';
  ///----------------- Dummy Image -----------------------------------//

  static List<String> avatars = List.generate(
      12, (index) => 'assets/images/dummy/avatar-${index + 1}.jpg');

  static List<String> squareImages =
      List.generate(15, (index) => 'assets/images/dummy/${index + 1}.jpg');

  static List<String> landscapeImages =
      List.generate(4, (index) => 'assets/images/dummy/l${index + 1}.jpg');

  static List<String> portraitImages =
      List.generate(3, (index) => 'assets/images/dummy/p${index + 1}.jpg');

  static List<String> dashboard = List.generate(
      6, (index) => 'assets/images/dummy/dashboard-${index + 1}.jpg');

  static List<String> fileManager = List.generate(
      2, (index) => 'assets/images/dummy/fileManager-${index + 1}.jpg');

  static List<String> landing = List.generate(
      3, (index) => 'assets/images/dummy/landing-${index + 1}.jpg');

  static List<String> social = List.generate(
      5, (index) => 'assets/images/dummy/social-${index + 1}.jpg');

  static List<String> product =
      List.generate(7, (index) => 'assets/images/dummy/h${index + 1}.jpg');

  static List<String> login =
      List.generate(6, (index) => 'assets/images/dummy/login${index + 1}.jpg');

  static List<String> nft =
      List.generate(1, (index) => 'assets/images/dummy/nft.jpg');

  static List<String> cartoon =
      List.generate(8, (index) => 'assets/images/dummy/m${index + 1}.jpg');

  static List<String> cartoonBackground =
      List.generate(8, (index) => 'assets/images/dummy/a${index + 1}.jpg');

  static String ethLogoIcon = 'assets/images/nft/ethereum-eth-logo.png';

  static List<String> shoppingImage = List.generate(
      10, (index) => 'assets/images/shopping_images/photo${index + 1}.jpg');

  /// Food
  static String fruits = 'assets/images/food/fruits.jpg';
  static String fruitsJuice = 'assets/images/food/fruit_juice.jpg';
  static String veggies = 'assets/images/food/veggies.jpg';
  static String canvasGuideSs = "assets/images/canvas_guide_ss.jpg";

  static String randomImage(List<String> images) {
    return images[Random().nextInt(images.length)];
  }
}
