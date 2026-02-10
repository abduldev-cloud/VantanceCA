import 'package:flutter_dotenv/flutter_dotenv.dart';

class API {
  static final String baseURl = dotenv.env['BASE_URL']!;
  static final String integrationBaseURl = dotenv.env['INTEGRATION_BASE_URL']!;
  static final String apiURL = dotenv.env['API_URL']!;
  static final String alfrescoBaseURL = dotenv.env['ALFRESCO_BASE_URL']!;
  static final String baseNotificationURL =
      dotenv.env['BASE_NOTIFICATION_URL']!;

  static final String affrescoSubmitUrl = dotenv.env['AFFRESCO_SUBMIT_URL']!;
  static final String purchaseUrl = dotenv.env['PURCHASE_URL']!;
  static final String subscriptionBaseUrl =
      dotenv.env['SUBSCRIPTION_BASE_URL']!;
  static final String generalChatUrl = dotenv.env['GENERAL_CHAT_URL']!;
  static final String faqUrl = dotenv.env['FAQ_URL']!;
  static final String institutionUrl = dotenv.env['INSTITUTION_URL']!;
  static final String schoologyUrl = dotenv.env['SCHOOLOGY_URL']!;

  static const String admin = 'admin';
  static const String realms = 'realms';
  static const String login = 'login';
  static const String binarysuccess = 'binarysuccess';
  static const String users = 'users';
  static const String groups = 'groups';
  static const String protocol = 'protocol';
  static const String openid = 'openid-connect';
  static const String token = 'token';
  static const String roleMappings = 'role-mappings';
  static const String clients = 'clients';
  static const String roles = 'roles';
  static const String logout = 'logout';
  static const String refreshToken = 'refresh-token';
  static final String streamChat = dotenv.env['STREAM_CHAT_URL']!;
  static const String binarysuccessStudentClasses =
      'binarysuccess_student_classes';
  static const String studentViewClass = 'student_viewclass';
  static const String binarysuccessStudentCalendar =
      'binarysuccess_student_calendar';
  static const String binarysuccessStudentTeacherWriting_pad =
      'binarysuccess_student_teacher_writing_pad';
  static const String binarysuccessStudentAssignment =
      'binarysuccess_student_assignment';
  static const String teacherClasses = 'teacher_classes';
  static const String teacherDashboard = 'teacher_dashboard';
  static const String teacherFingerprintView = 'teacher_fingerprint-view';
  static const String teacherAssignment = 'teacher_assignment';
  static const String teacherGrading = 'teacher_grading';
  static const String getTaskDetails = 'get_taskdetails';
  static const String writingpad = 'writingpad';
}

class AppConstant {
  static final String clientSecret = dotenv.env['CLIENT_SECRET']!;
  static final String clientID = dotenv.env['CLIENT_ID']!;
  static final String clientIDs = dotenv.env['CLIENT_IDS']!;
  static final String googleClientIDs = dotenv.env['GOOGLE_CLIENT_IDS']!;

  static final String csvTemplateDownloadUrl =
      dotenv.env['CSV_TEMPLATE_DOWNLOAD_URL']!;
  static final String excelTemplateDownloadUrl =
      dotenv.env['EXCEL_TEMPLATE_DOWNLOAD_URL']!;

  static const int defaultPageNumber = 1;
  static const int defaultPageSize = 10;
}
