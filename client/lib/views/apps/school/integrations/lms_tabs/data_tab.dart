import 'package:binary_success/controller/apps/school/lms_integration_controller.dart';
import 'package:binary_success/helpers/utils/datetime_utils.dart';
import 'package:binary_success/helpers/utils/ui_mixins.dart';
import 'package:binary_success/helpers/widgets/app_button.dart';
import 'package:binary_success/images.dart';
import 'package:binary_success/models/middleware_assignment_model.dart';
import 'package:binary_success/models/middleware_class_model.dart';
import 'package:binary_success/models/middleware_enrollments_model.dart';
import 'package:binary_success/models/middleware_grade_model.dart';
import 'package:binary_success/models/paginated_data_model.dart';
import 'package:binary_success/views/apps/school/integrations/lms_tabs/widgets/header_text.dart';
import 'package:binary_success/views/apps/school/widget/pagination_controls.dart';
import 'package:flutter/material.dart';
import 'package:binary_success/views/apps/school/integrations/widgets/custom_tab_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DataTab extends StatefulWidget {
  const DataTab({super.key});

  @override
  State<DataTab> createState() => _DataTabState();
}

class _DataTabState extends State<DataTab>
    with SingleTickerProviderStateMixin, UIMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  final List<TabItem> _tabs = [
    TabItem(label: 'Class', icon: Images.classIcon),
    TabItem(label: 'Teachers', icon: Images.teacher),
    TabItem(label: 'Teacher Enrollment', icon: Images.teacher),
    TabItem(label: 'Students', icon: Images.student),
    TabItem(label: 'Student Enrollment', icon: Images.student),
    TabItem(label: 'Assignment', icon: Images.assignment),
    TabItem(label: 'Grade', icon: Images.gradeLms),
  ];

  // Controller instance
  final LmsIntegrationController controller =
      Get.put(LmsIntegrationController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
  }

  Future<void> _syncData() async {
    if (controller.integrationData.value != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Obx(() {
            if (!controller.isSyncingData.value) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            }
            return AlertDialog(
              title: Text("Sync in progress"),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: const Color(0xff004AAD),
                      size: 50,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "The sync is running in the background. This process may take a while. "
                      "You will receive a notification when it is complete.",
                    ),
                  ],
                ),
              ),
              actions: [
                AppButton(
                  title: "Ok",
                  onTap: () {
                    Get.back();
                  },
                )
              ],
            );
          });
        },
      );

      await controller.syncData(controller.integrationData.value!.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: HeaderText(
            title: "Canvas - Connected",
            subtitle:
                "Canvas integration active – managing courses and grades in real time",
          ),
        ),
        SizedBox(height: 40),
        SizedBox(
          height: 48,
          child: CustomTabBar(
            onTabSelected: (index) {},
            controller: _tabController,
            tabs: _tabs,
            selectedIndex: _selectedIndex,
            centerAlign: false,
            indicatorColor: contentTheme.darkPurple,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ClassTab(onSync: _syncData, controller: controller),
              TeacherTab(onSync: _syncData, controller: controller),
              TeacherEnrollmentsTab(onSync: _syncData, controller: controller),
              StudentTab(onSync: _syncData, controller: controller),
              StudentEnrollmentsTab(onSync: _syncData, controller: controller),
              AssignmentsTab(onSync: _syncData, controller: controller),
              GradesTab(onSync: _syncData, controller: controller)
            ],
          ),
        ),
      ],
    );
  }
}

class NoDataTab extends StatelessWidget {
  const NoDataTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("No data to show"));
  }
}

class TeacherTab extends StatelessWidget {
  final VoidCallback onSync;
  final LmsIntegrationController controller;

  const TeacherTab({super.key, required this.onSync, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _buildTabContent(
          onSync, controller.middlewareTeachers.value, controller,
          (newPage, query, isPageChange) {
        controller.fetchMiddlewareTeachers(
            controller.integrationData.value!.id, newPage,
            query: query, isPageChange: isPageChange);
      },
          isLoading: controller.isFetchingTeachers,
          query: controller.teachersQuery);
    });
  }
}

class TeacherEnrollmentsTab extends StatelessWidget {
  final VoidCallback onSync;
  final LmsIntegrationController controller;

  const TeacherEnrollmentsTab(
      {super.key, required this.onSync, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _buildTabContent(
          onSync, controller.teacherEnrollments.value, controller,
          (newPage, query, isPageChange) {
        controller.fetchTeacherEnrollments(
            controller.integrationData.value!.id, newPage,
            query: query, isPageChange: isPageChange);
      },
          isLoading: controller.isFetchingTeacherEnrollments,
          query: controller.teacherEnrollmentsQuery);
    });
  }
}

class StudentTab extends StatelessWidget {
  final VoidCallback onSync;
  final LmsIntegrationController controller;

  const StudentTab({super.key, required this.onSync, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _buildTabContent(
          onSync, controller.middlewareStudents.value, controller,
          (newPage, query, isPageChange) {
        controller.fetchMiddlewareStudents(
            controller.integrationData.value!.id, newPage,
            query: query, isPageChange: isPageChange);
      },
          isLoading: controller.isFetchingStudents,
          query: controller.studentsQuery);
    });
  }
}

class StudentEnrollmentsTab extends StatelessWidget {
  final VoidCallback onSync;
  final LmsIntegrationController controller;

  const StudentEnrollmentsTab(
      {super.key, required this.onSync, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _buildTabContent(
          onSync, controller.studentEnrollments.value, controller,
          (newPage, query, isPageChange) {
        controller.fetchStudentEnrollments(
            controller.integrationData.value!.id, newPage,
            query: query, isPageChange: isPageChange);
      },
          isLoading: controller.isFetchingStudentEnrollments,
          query: controller.studentEnrollmentsQuery);
    });
  }
}

class ClassTab extends StatelessWidget {
  final VoidCallback onSync;
  final LmsIntegrationController controller;

  const ClassTab({super.key, required this.onSync, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _buildTabContent(
          onSync, controller.middlewareClasses.value, controller,
          (newPage, query, isPageChange) {
        controller.fetchMiddlewareClasses(
            controller.integrationData.value!.id, newPage,
            query: query, isPageChange: isPageChange);
      },
          isLoading: controller.isFetchingClasses,
          query: controller.classesQuery);
    });
  }
}

class AssignmentsTab extends StatelessWidget {
  final VoidCallback onSync;
  final LmsIntegrationController controller;

  const AssignmentsTab(
      {super.key, required this.onSync, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _buildTabContent(
          onSync, controller.middlewareAssignments.value, controller,
          (newPage, query, isPageChange) {
        controller.fetchMiddlewareAssignments(newPage,
            query: query, isPageChange: isPageChange);
      },
          isLoading: controller.isFetchingAssignments,
          query: controller.assignmentsQuery,
          showSync: false);
    });
  }
}

class GradesTab extends StatelessWidget {
  final VoidCallback onSync;
  final LmsIntegrationController controller;

  const GradesTab({super.key, required this.onSync, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _buildTabContent(
          onSync, controller.middlewareGrades.value, controller,
          (newPage, query, isPageChange) {
        controller.fetchMiddlewareGrades(newPage,
            query: query, isPageChange: isPageChange);
      },
          isLoading: controller.isFetchingGrades,
          query: controller.gradesQuery,
          showSync: false);
    });
  }
}

Widget _buildTabContent(
    VoidCallback onSync,
    PaginatedResponse? response,
    LmsIntegrationController controller,
    Function(int, String, bool) onPageChanged,
    {bool showSync = true,
    required RxString query,
    required RxBool isLoading}) {
  final data = response?.data ?? [];

  final bool isSyncDisabled = controller.isSyncingData.value ||
      controller.integrationMode.value?.integrationMode == "OFF" ||
      controller.integrationMode.value?.integrationStatus == "STARTED" ||
      controller.integrationData.value == null ||
      DateTimeUtils.isTokenExpired(
          controller.integrationData.value?.expiresAt?.toIso8601String());

  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Spacer(),
            SizedBox(
              width: 200,
              height: 50.h,
              child: TextField(
                controller: TextEditingController.fromValue(
                  TextEditingValue(
                    text: query.value,
                    selection:
                        TextSelection.collapsed(offset: query.value.length),
                  ),
                ),
                // UPDATED LOGIC: Always allow searching, even if data is empty
                onChanged: (value) {
                  query.value = value;
                  onPageChanged(1, value, false);
                },
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ),
            showSync ? const SizedBox(width: 10) : SizedBox(),
            if (showSync)
              AppButton(
                onTap: isSyncDisabled ? null : onSync,
                title: "Sync",
                prefixIconPath: Images.sync,
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
          ],
        ),
        const SizedBox(height: 20),
        isLoading.value
            ? Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Color(0xff004AAD), size: 50),
              )
            : data.isEmpty
                ? const Center(child: Text("No data to show"))
                : Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildTable(data),
                          ),
                        ),
                        const SizedBox(height: 10),
                        PaginationControls(
                          currentPage: response?.page ?? 1,
                          totalPages: response?.totalPages ?? 1,
                          onPageChanged: (newPage) {
                            onPageChanged(newPage, query.value, true);
                          },
                        ),
                      ],
                    ),
                  ),
      ],
    ),
  );
}

Widget _buildTable(List data) {
  if (data is List<MiddlewareAssignment>) {
    return AssignmentTableWidget(data: data);
  } else if (data is List<MiddlewareGrade>) {
    return GradeTableWidget(data: data);
  } else if (data is List<MiddlewareEnrollments>) {
    return EnrollmentsTableWidget(data: data);
  }
  return DataTableWidget(data: data);
}

class DataTableWidget extends StatelessWidget {
  final List data;
  const DataTableWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(
          color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(3),
        4: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          children: [
            TableCell(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text("Middleware Id",
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.bold)))),
            TableCell(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text("BinarySuccess Id",
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.bold)))),
            TableCell(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text("LMS Id",
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.bold)))),
            TableCell(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text("Name",
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.bold)))),
            TableCell(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text("Created Date",
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.bold)))),
          ],
        ),
        for (var item in data)
          TableRow(
            children: [
              TableCell(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: Text(item.middlewareId ?? '-'))),
              TableCell(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: Text(item.binarysuccessId?.toString() ?? '-'))),
              TableCell(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: Text(item is MiddlewareClass
                          ? item.classId
                          : item.userId ?? '-'))),
              TableCell(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: Text(item is MiddlewareClass
                          ? item.className
                          : "${item.firstName} ${item.lastName}" ?? '-'))),
              TableCell(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: Text(DateTimeUtils.utcIsoToLocalDateTime(
                              item.createdAt.toString())
                          .toString()))),
            ],
          ),
      ],
    );
  }
}

class AssignmentTableWidget extends StatelessWidget {
  final List<MiddlewareAssignment> data;
  const AssignmentTableWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(
          color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(3),
        4: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          children: [
            TableCell(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text("Institute Id",
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.bold)))),
            TableCell(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text("Binary Success Id",
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.bold)))),
            TableCell(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text("Title",
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.bold)))),
            TableCell(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text("Due At",
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.bold)))),
            TableCell(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text("Created Date",
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.bold)))),
          ],
        ),
        for (var item in data)
          TableRow(
            children: [
              TableCell(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: Text(item.instituteId ?? '-'))),
              TableCell(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: Text(item.binarySuccessId.toString() ?? '-'))),
              TableCell(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: Text(item.title.toString()))),
              TableCell(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: Text(item.dueAt.toString()))),
              TableCell(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: Text(DateTimeUtils.utcIsoToLocalDateTime(
                              item.createdAt.toString())
                          .toString()))),
            ],
          ),
      ],
    );
  }
}

class GradeTableWidget extends StatelessWidget {
  final List<MiddlewareGrade> data;
  const GradeTableWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(
          color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(3),
        4: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          children: [
            TableCell(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text("Assignment Id",
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.bold)))),
            TableCell(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text("Binary Success Id",
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.bold)))),
            TableCell(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text("Learner Id",
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.bold)))),
            TableCell(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text("Score",
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.bold)))),
            TableCell(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text("Created Date",
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.bold)))),
          ],
        ),
        for (var item in data)
          TableRow(
            children: [
              TableCell(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: Text(item.assignmentBinarySuccessId ?? '-'))),
              TableCell(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: Text(item.binarySuccessId.toString() ?? '-'))),
              TableCell(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: Text(item.studentBinarySuccessId ?? '-'))),
              TableCell(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: Text(item.score.toString()))),
              TableCell(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: Text(DateTimeUtils.utcIsoToLocalDateTime(
                              item.createdAt.toString())
                          .toString()))),
            ],
          ),
      ],
    );
  }
}

class EnrollmentsTableWidget extends StatelessWidget {
  final List<MiddlewareEnrollments> data;
  const EnrollmentsTableWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(
          color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(3),
        4: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          children: [
            TableCell(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text("Enrollment Id",
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.bold)))),
            TableCell(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text("Full Name",
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.bold)))),
            TableCell(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text("Class",
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.bold)))),
            TableCell(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text("Created Date",
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.bold)))),
          ],
        ),
        for (var item in data)
          TableRow(
            children: [
              TableCell(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: Text(item.enrollmentId ?? '-'))),
              TableCell(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: Text(
                          "${item.firstName ?? ""} ${item.lastName ?? ""}"))),
              TableCell(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: Text(item.className ?? '-'))),
              TableCell(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: Text(DateTimeUtils.utcIsoToLocalDateTime(
                              item.createdAt.toString())
                          .toString()))),
            ],
          ),
      ],
    );
  }
}
