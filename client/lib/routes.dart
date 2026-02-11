import 'package:vantanceCA/controller/apps/teacher/teacher_assignments_controller.dart';
import 'package:vantanceCA/views/apps/school/integrations/schoology/schoology_screen.dart';
import 'package:vantanceCA/views/auth/create_new_password.dart';
import 'package:vantanceCA/helpers/utils/utils.dart';
import 'package:vantanceCA/views/apps/file/file_manager.dart';
import 'package:vantanceCA/views/apps/file/file_uploader.dart';
import 'package:vantanceCA/views/apps/fitness/fitness_screen.dart';
import 'package:vantanceCA/views/apps/platform_admin/admin_analytics.dart';
import 'package:vantanceCA/views/apps/platform_admin/admin_biling_plan.dart';
import 'package:vantanceCA/views/apps/platform_admin/admin_dashboard.dart';
import 'package:vantanceCA/views/apps/platform_admin/admin_school.dart';
import 'package:vantanceCA/views/apps/platform_admin/admin_support_ticket.dart';
import 'package:vantanceCA/views/apps/platform_admin/admin_users.dart';
import 'package:vantanceCA/views/apps/platform_admin/admin_support_view.dart';
import 'package:vantanceCA/models/platform_support_model.dart';
import 'package:vantanceCA/views/auth/forgot_password.dart';
import 'package:vantanceCA/views/apps/school/integrations/excel/excel_connection_screen.dart';
import 'package:vantanceCA/views/apps/school/integrations/lms_connection_screen.dart';
import 'package:vantanceCA/views/apps/school/integrations/school_integrations.dart';
import 'package:vantanceCA/views/apps/school/school_anylytics.dart';
import 'package:vantanceCA/views/apps/school/school_classes.dart';
import 'package:vantanceCA/views/apps/school/school_view_details_widget.dart';
import 'package:vantanceCA/views/apps/school/school_billing.dart';
import 'package:vantanceCA/views/apps/school/payment_success_page.dart';
import 'package:vantanceCA/views/apps/school/success_page.dart';
import 'package:vantanceCA/views/apps/school/payment_failed_page.dart';
import 'package:vantanceCA/views/apps/school/school_dashboard.dart';
import 'package:vantanceCA/views/apps/school/school_setting.dart';
import 'package:vantanceCA/views/apps/school/school_security_privacy_page.dart';
import 'package:vantanceCA/views/apps/student/student_assignment.dart';
import 'package:vantanceCA/views/apps/student/student_calender.dart';
import 'package:vantanceCA/views/apps/student/student_classes.dart';
import 'package:vantanceCA/views/apps/student/student_view_classes.dart';
import 'package:vantanceCA/views/apps/student/student_writing_pad.dart';
import 'package:vantanceCA/views/apps/teacher/teacher_analytics/teacher_analytics.dart';
import 'package:vantanceCA/views/apps/teacher/teacher_assignments/teacher_assignment_review.dart';
import 'package:vantanceCA/views/apps/teacher/teacher_assignments/teacher_assignment_view.dart';
import 'package:vantanceCA/views/apps/teacher/teacher_assignments/teacher_assignments.dart';
import 'package:vantanceCA/views/apps/teacher/teacher_assignments/teacher_assignments_detail.dart';
import 'package:vantanceCA/views/apps/teacher/teacher_calendar/teacher_calendar.dart';
import 'package:vantanceCA/views/apps/teacher/teacher_classes/teacher_classes.dart';
import 'package:vantanceCA/views/apps/teacher/teacher_classes/teacher_classes_detail_page.dart';
import 'package:vantanceCA/views/apps/teacher/teacher_dashboard/teacher_dashboard.dart';
import 'package:vantanceCA/views/apps/teacher/teacher_fingerprints/teacher_fingerprint_detail.dart';
import 'package:vantanceCA/views/apps/teacher/teacher_fingerprints/teacher_writing_fingerprint.dart';
import 'package:vantanceCA/views/apps/teacher/teacher_fingerprints/teacher_writing_fingerprint_review.dart';
import 'package:vantanceCA/views/apps/teacher/teacher_grading/teacher_grading.dart';
import 'package:vantanceCA/views/apps/teacher/teacher_grading/teacher_grading_review.dart';
import 'package:vantanceCA/views/auth/locked.dart';
import 'package:vantanceCA/views/auth/login.dart';
import 'package:vantanceCA/views/auth/register.dart';
import 'package:vantanceCA/views/extra_pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vantanceCA/views/apps/school/school_consent_status_page.dart';
import 'package:vantanceCA/views/apps/school/school_consent_status_disagree.dart';
import 'helpers/services/auth_services.dart';
import 'views/auth/locked_2.dart';
import 'views/error_pages/coming_soon_page.dart';
import 'views/error_pages/error_404.dart';
import 'views/error_pages/error_500.dart';
import 'views/error_pages/maintenance_page.dart';
import 'views/extra_pages/faqs_page.dart';
import 'views/extra_pages/docs_site.dart';
import 'views/extra_pages/pricing.dart';
import 'views/extra_pages/help_page.dart';
import 'package:vantanceCA/views/extra_pages/deleteAccount.dart';

import 'package:vantanceCA/helpers/storage/local_storage.dart';
import 'package:vantanceCA/views/apps/student/main_layout.dart';
import 'package:vantanceCA/views/apps/student/papers_screen.dart';
import 'package:vantanceCA/views/apps/student/practices_page.dart';
import 'package:vantanceCA/views/apps/student/practice_screen_exact.dart';
import 'package:vantanceCA/views/apps/student/settings_screen.dart';
import 'package:vantanceCA/views/apps/student/student_result_page.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return AuthService.isLoggedIn
        ? null
        : const RouteSettings(name: '/auth/login');
  }
}

getPageRoute() {
  var routes = [
    GetPage(
      name: '/',
      page: () {
        switch (RoleUtils.currentRole) {
          case "TEACHER":
            return TeacherDashboardPage();
          case "LEARNER":
            return StudentClassesPage();
          case "INSTITUTE_ADMIN":
            return SchoolDashboardPage();
          case "PLATFORM_ADMIN":
            return AdminDashboardPage();
          default:
            return LoginPage();
        }
      },
    ),

    GetPage(
      name: '/delete/account',
      page: () => const DeleteAccountPage(),
      // middlewares: [AuthMiddleware()],
    ),

    GetPage(name: '/faqs', page: () => const FAQPage()),
    // GetPage(name: '/demo', page: () => const DemoPage()),

    GetPage(
        name: '/pricing',
        page: () => const Pricing(),
        middlewares: [AuthMiddleware()]),

    GetPage(
      name: '/dashboard',
      page: () => const AdminDashboardPage(),
    ),

    ///------------------------------ Student ------------------------------///

    GetPage(
      name: '/student/class',
      page: () => const StudentClassesPage(),
    ),
    GetPage(
      name: '/student/classdetail',
      page: () => const StudentViewClassesPage(),
    ),
    GetPage(
      name: '/student/assignment',
      page: () => const StudentAssignmentPage(),
    ),
    GetPage(
      name: '/student/calendar',
      page: () => const StudentCalenderPage(),
    ),
    GetPage(
      name: '/student/writingpad',
      page: () => const StudentWritingPadPage(),
    ),
    GetPage(
      name: '/student/faqs',
      page: () => const FAQPage(),
    ),
    GetPage(
      name: '/student/onboarding',
      page: () => const OnboardingPage(persona: 'student'),
    ),

    ///------------------------------ Student ------------------------------///

    GetPage(
      name: '/student/main-layout',
      page: () => const MainLayout(),
    ),

    GetPage(
      name: '/student/papers',
      page: () => const PapersScreen(),
    ),

    GetPage(
      name: '/student/practices',
      page: () => const PracticesPage(),
    ),

    GetPage(
      name: '/student/practice-session',
      page: () => const QuizScreenExact(),
    ),

    GetPage(
      name: '/student/settings',
      page: () => SettingsScreen(),
    ),

    GetPage(
      name: '/student/result',
      page: () => const StudentResultPage(),
    ),

    ///------------------------------ School ------------------------------///
    GetPage(
      name: '/school/dashboard',
      page: () => const SchoolDashboardPage(),
    ),
    GetPage(
      name: '/school/classes',
      page: () => const SchoolClassesPage(),
    ),

    GetPage(
      name: '/school/classesdetail',
      page: () => const SchoolClassDetailPage(),
    ),

    GetPage(
      name: '/school/analytics',
      page: () => const SchoolAnylyticsPage(),
    ),

    GetPage(
      name: '/school/integrations',
      page: () {
        if (LocalStorage.getIsDemoSchool() == "N") {
          return SchoolIntegrationsPage();
        } else {
          return SchoolDashboardPage();
        }
      },
    ),

    GetPage(
      name: '/school/integrations/lms_connection',
      page: () {
        if (LocalStorage.getIsDemoSchool() == "N") {
          return LmsConnectionScreen();
        } else {
          return SchoolDashboardPage();
        }
      },
    ),

    GetPage(
      name: '/school/integrations/excel_connection',
      page: () {
        if (LocalStorage.getIsDemoSchool() == "N") {
          return ExcelConnectionScreen();
        } else {
          return SchoolDashboardPage();
        }
      },
    ),
    GetPage(
        name: "/school/integrations/schoology_screen",
        // page: () => SchoologyConnectionScreen(),
        page: () {
          if (LocalStorage.getIsDemoSchool() == "N") {
            return SchoologyScreen();
          } else {
            return SchoolDashboardPage();
          }
        }),

    GetPage(
      name: '/school/setting',
      page: () => const SchoolSettingPage(),
    ),
    GetPage(
      name: '/school/security',
      page: () => const SchoolSecurityPrivacyPage(),
    ),
    GetPage(
      name: '/school/faqs',
      page: () => const FAQPage(),
    ),
    GetPage(
      name: '/school/help',
      page: () => const HelpPage(),
    ),
    GetPage(
      name: '/school/onboarding',
      page: () => const OnboardingPage(persona: 'school'),
    ),
    GetPage(
      name: '/school/billing/success',
      page: () => const PaymentSuccessPage(),
    ),
    GetPage(
      name: '/student/billing/fail',
      page: () => const PaymentFailedPage(),
    ),
    GetPage(
      name: '/school/billing',
      page: () => const SchoolBillingPage(),
    ),
    GetPage(
      name: '/school/billing/paid',
      page: () => const PaymentSuccessPageIn(),
    ),
    GetPage(
      name: '/school/consent_agree',
      page: () {
        final params = Get.parameters;
        return SchoolConsentStatusPage(
          source: params['source'],
          sourceId: params['source_id'],
        );
      },
    ),

    GetPage(
      name: '/school/consent_disagree',
      page: () {
        final params = Get.parameters;
        return SchoolConsentDisagreePage(
          source: params['source'],
          sourceId: params['source_id'],
        );
      },
    ),

    ///------------------------------ Admin ------------------------------///
    GetPage(
      name: '/admin/dashboard',
      page: () => const AdminDashboardPage(),
    ),
    GetPage(
      name: '/admin/schools',
      page: () => const AdminSchoolPage(),
    ),
    GetPage(
      name: '/admin/users',
      page: () => const AdminUsersPage(),
    ),

    GetPage(
      name: '/admin/analytics',
      page: () => const AdminAnalyticsPage(),
    ),
    GetPage(
      name: '/admin/activities',
      page: () => const AdminAnalyticsPage(),
    ),
    GetPage(
      name: '/admin/billing',
      page: () => const AdminBilingPlanPage(),
    ),
    GetPage(
      name: '/admin/support',
      page: () => const AdminSupportTicketPage(),
    ),
    GetPage(
      name: '/admin/support/view',
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        final ticket = args['ticket'] as SupportModel;
        return AdminSupportViewPage(ticket: ticket);
      },
    ),

    // GetPage(
    //   name: '/admin/faqs',
    //   page: () => const FAQPage(),
    // ),
    GetPage(
      name: '/admin/docs',
      page: () => const DocsSite(),
    ),

    ///------------------------------ Teacher ------------------------------///
    GetPage(
      name: '/teacher/assignmentdetail',
      page: () => const TeacherAssignmentsDetail(), // matches your widget class
      binding: BindingsBuilder(() {
        Get.put(TeacherAssignmentsController());
      }),
    ),

    GetPage(
      name: '/teacher/dashboard',
      page: () => const TeacherDashboardPage(),
    ),
    GetPage(
      name: '/teacher/classes',
      page: () => const TeacherClassesPage(),
    ),
    GetPage(
      name: '/teacher/fingerprint',
      page: () => const TeacherWritingFingerprintPage(),
    ),
    GetPage(
      name: '/teacher/assignments',
      page: () => const TeacherAssignmentsPage(),
    ),
    GetPage(
      name: '/teacher/grading',
      page: () => const TeacherGradingPage(),
    ),
    GetPage(
      name: '/teacher/calendar',
      page: () => const TeacherCalendarPage(),
    ),
    GetPage(
      name: '/teacher/analytics',
      page: () => const TeacherAnalyticsPage(),
    ),
    GetPage(
      name: '/teacher/classesdetail',
      page: () => const TeacherClassesDetailPage(),
    ),
    GetPage(
      name: '/teacher/fingerprintdetail',
      page: () => const TeacherFingerprintDetail(),
    ),

    GetPage(
      name: '/teacher/gradingreview',
      page: () => const TeacherGradingReviewPage(),
    ),
    GetPage(
      name: '/teacher/fingerprintreview',
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        final learnerId = args['learnerId'] as String? ?? '';
        final taskId = args['taskId'] as String? ?? '';
        return TeacherWritingFingerprintReview(
          learnerId: learnerId,
          taskId: taskId,
        );
      },
    ),

    GetPage(
      name: '/teacher/assignmentreview',
      page: () => const TeacherAssignmentReview(),
      // page: () => const TeacherGradingReviewPage(),
    ),
    GetPage(
      name: '/teacher/assignmentview',
      page: () => const TeacherAssignmentView(),
    ),

    GetPage(
      name: '/teacher/faqs',
      page: () => const FAQPage(),
    ),
    GetPage(
      name: '/teacher/onboarding',
      page: () => const OnboardingPage(persona: 'teacher'),
    ),

    ///---------------- File ----------------///

    GetPage(
        name: '/apps/files',
        page: () => const FileManager(),
        middlewares: [AuthMiddleware()]),

    GetPage(
        name: '/apps/file-uploader',
        page: () => const FileUploader(),
        middlewares: [AuthMiddleware()]),

    GetPage(
        name: '/fitness',
        page: () => const FitnessScreen(),
        middlewares: [AuthMiddleware()]),

    ///---------------- KanBan ----------------///

    ///---------------- Auth ----------------///

    GetPage(name: '/auth/login', page: () => const LoginPage()),

    GetPage(
      name: '/auth/forgot_password',
      page: () => const ForgotPasswordPage(),
    ),
    GetPage(
      name: '/auth/reset-password',
      page: () => const CreateNewPasswordPage(),
    ),

    GetPage(name: '/auth/register', page: () => const Register()),
    GetPage(
        name: '/auth/locked',
        page: () => const LockedPage(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/auth/locked1',
        page: () => const LockedPage2(),
        middlewares: [AuthMiddleware()]),

    ///---------------- Error ----------------///

    GetPage(
        name: '/coming-soon',
        page: () => const ComingSoonPage(),
        middlewares: [AuthMiddleware()]),

    GetPage(
        name: '/error-404',
        page: () => const Error404(),
        middlewares: [AuthMiddleware()]),

    GetPage(
        name: '/error-500',
        page: () => const Error500(),
        middlewares: [AuthMiddleware()]),

    GetPage(
        name: '/maintenance',
        page: () => const MaintenancePage(),
        middlewares: [AuthMiddleware()]),

    ///---------------- Chat ----------------///
  ];
  return routes
      .map(
        (e) => GetPage(
            name: e.name,
            page: e.page,
            middlewares: e.middlewares,
            transition: Transition.noTransition),
      )
      .toList();
}
