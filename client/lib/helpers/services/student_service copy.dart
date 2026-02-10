class StudentService {
  static Future<ServiceResponse?> getStudentCalendarAPI({
    required String learnerId,
    required int taskMonth,
    required int taskYear,
  }) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));

    // Return mock data
    return ServiceResponse(
      data: {
        'tasksDueSummary': [
          {
            'taskId': '1',
            'className': 'Mathematics',
            'taskTitle': 'Algebra Homework',
            'dueDate':
                DateTime(taskYear, taskMonth, 15, 10, 0).toIso8601String(),
          },
          {
            'taskId': '2',
            'className': 'Physics',
            'taskTitle': 'Lab Report',
            'dueDate':
                DateTime(taskYear, taskMonth, 20, 14, 0).toIso8601String(),
          },
          {
            'taskId': '3',
            'className': 'Accounting',
            'taskTitle': 'Daily Practice',
            'dueDate':
                DateTime(taskYear, taskMonth, 14, 09, 0).toIso8601String(),
          },
          {
            'taskId': '4',
            'className': 'Economics',
            'taskTitle': 'Mock Test Preparation',
            'dueDate':
                DateTime(taskYear, taskMonth, 18, 11, 30).toIso8601String(),
          },
          {
            'taskId': '5',
            'className': 'Business Studies',
            'taskTitle': 'Case Study Analysis',
            'dueDate':
                DateTime(taskYear, taskMonth, 22, 16, 0).toIso8601String(),
          },
          {
            'taskId': '6',
            'className': 'Practice',
            'taskTitle': 'Full Length Mock Exam',
            'dueDate':
                DateTime(taskYear, taskMonth, 25, 10, 0).toIso8601String(),
          },
        ]
      },
    );
  }
}

class ServiceResponse {
  final dynamic data;
  ServiceResponse({this.data});
}
