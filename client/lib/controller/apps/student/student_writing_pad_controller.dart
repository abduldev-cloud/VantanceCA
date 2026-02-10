import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:binary_success/helpers/constant/app_constant.dart';
import 'package:binary_success/controller/my_controller.dart';
import 'package:binary_success/helpers/services/student_service.dart';
import 'package:binary_success/models/student_assignment_model.dart';
import 'package:binary_success/models/writing_pad_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../helpers/storage/local_storage.dart';
import 'package:binary_success/models/submit_draft_model.dart';
import 'package:binary_success/helpers/services/teacher_service.dart';

class StudentWritingPadController extends MyController {
  RxInt selectedTabIndex = 0.obs;
  Rx<WritingPadModel> writingPadModel = WritingPadModel().obs;
  RxBool isLoading = false.obs;
  TextEditingController sageAI = TextEditingController();
  RxList<SageAIModel> sageAIList = <SageAIModel>[].obs;
  RxString learnerHtmlContent = ''.obs; // <-- NEW FIELD FOR HTML CONTENT

  RxString currentWritingContent = ''.obs;
  RxInt aiPromptsUsed = 0.obs;
  final int aiPromptsLimit = 5;

  RxBool isThinking = false.obs;
  RxString thinkingMessageId = ''.obs;

  final String taskId;

  StudentWritingPadController({required this.taskId});

  @override
  void onInit() {
    getWritingPadData(id: taskId);
    super.onInit();
  }

  /// ------------------- GET WRITING PAD DATA --------------------
  Future<void> getWritingPadData({required String id}) async {
    isLoading(true);
    final entityId = LocalStorage.getDBEntityID();
    if (entityId == null || entityId.isEmpty) {
      print("❌ No entityId found in LocalStorage");
      isLoading(false);
      return;
    }

    final response =
        await StudentService.getWritingPadAPI(learnerId: entityId, id: id);

    if (response != null) {
      writingPadModel(WritingPadModel.fromJson(response.data));
      final aiPrompts = response.data["ai_prompts"] as List? ?? [];
      aiPromptsUsed.value = aiPrompts.length;

      sageAIList.clear();
      for (final prompt in aiPrompts) {
        sageAIList.add(SageAIModel(
          text: prompt["prompt_text"] ?? "",
          isMe: true,
        ));
        sageAIList.add(SageAIModel(
          text: prompt["ai_response"] ?? "",
          isMe: false,
        ));
      }
      // Only start timer if we actually have a dueDate
      if (writingPadModel.value.taskSummary != null &&
          writingPadModel.value.taskSummary!.isNotEmpty &&
          writingPadModel.value.taskSummary!.first.dueDate != null) {
        startCountdownTimer();
      } else {
        countdownText.value = "No due date available";
      }

      String preprocessHtml(String html) {
        return html
            .replaceAll('\u0014', '&mdash;') // Unicode checkmark ✓
            .replaceAll('\u0019', "'")
            .replaceAll('\u2019', "'") // right single quote
            .replaceAll('\u2018', "'") // left single quote
            .replaceAll('\u201C', '"') // left double quote
            .replaceAll('\u201D', '"') // right double quote
            .replaceAll('\u2014', '-')
            .replaceAll('\u2014', '—') // em dash → hyphen
            .replaceAll('\u2013', '-') // en dash → hyphen
            .replaceAll('\u2026', '...') // ellipsis
            .replaceAll(
                RegExp(r'[^\x00-\x7F]'), '?'); // replace unsupported chars
      }

      // ====== MINIMAL ALFRESCO HTML LOGIC (ADD ONLY, DON'T REMOVE ANYTHING) ======
      final summary = writingPadModel.value.taskSummary?.first;
      if (summary != null &&
          (summary.taskStatus == 'SUBMITTED' ||
              summary.taskStatus == 'GRADED' ||
              summary.taskStatus == 'DRAFT' ||
              summary.taskStatus == 'ASSIGNED') &&
          summary.alfrescoSiteId != null &&
          summary.alfrescoFolderPath != null &&
          summary.fileName != null) {
        try {
          final fileNameNoExt = summary.fileName!.replaceAll('.html', '');

          final htmlRaw = await StudentService.fetchLearnerHtmlResponse(
            siteId: summary.alfrescoSiteId!,
            folderPath: summary.alfrescoFolderPath!,
            taskId: fileNameNoExt,
          );

          learnerHtmlContent.value = preprocessHtml(htmlRaw ?? '');
          print('Fetched Alfresco HTML content for writing pad.');
        } catch (e) {
          learnerHtmlContent.value = '';
          print('Error fetching/parsing learner HTML from Alfresco: $e');
        }
      } else {
        learnerHtmlContent.value = '';
      }

      // ====== END MINIMAL ALFRESCO HTML LOGIC ======
    }
    isLoading(false);
  }

  /// ------------------- COUNTDOWN TIMER --------------------
  var countdownText = ''.obs; // Reactive countdown string
  Timer? _timer;

  void startCountdownTimer() {
    updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateCountdown();
    });
  }

  void updateCountdown() {
    // Guard: no data case
    if (writingPadModel.value.taskSummary == null ||
        writingPadModel.value.taskSummary!.isEmpty) {
      countdownText.value = "No task data";
      return;
    }

    final dueDate = writingPadModel.value.taskSummary!.first.dueDate;
    if (dueDate == null) {
      countdownText.value = "No due date";
      return;
    }

    final now = DateTime.now().toUtc();
    final difference = dueDate.difference(now);

    if (difference.isNegative) {
      countdownText.value = "Past due date";
      return;
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    countdownText.value = "${days.toString().padLeft(2, '0')}days:"
        "${hours.toString().padLeft(2, '0')}h:"
        "${minutes.toString().padLeft(2, '0')}m:"
        "${seconds.toString().padLeft(2, '0')}s";
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // Add this method to StudentWritingPadController
  Future<bool> saveDraft(String htmlContent) async {
    try {
      final entityId = LocalStorage.getDBEntityID();
      if (entityId == null || entityId.isEmpty) {
        print("❌ No entityId found in LocalStorage");
        return false;
      }

      final taskSummary = writingPadModel.value.taskSummary?.first;
      if (taskSummary == null) return false;

      final dioInstance = Dio();
      final request = DraftAssignmentAlfrescoRequest(
        siteId: taskSummary.alfrescoSiteId ?? "null",
        folderPath: taskSummary.alfrescoFolderPath ?? "",
        alfrescoTaskId: taskSummary.alfrescoTaskId ?? "null",
        alfrescoStudentID: taskSummary.alfrescoLearnerId ?? "null",
        htmlBytes: Uint8List.fromList(htmlContent.codeUnits),
        fileName: "editor_content_${taskSummary.taskId}.html",
      );

      final formData = await request.toFormData();
      final response = await dioInstance.post(
        "${API.baseURl}/alfresco/save-draft",
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      if (response.statusCode == 200) {
        final fileNameFromAlfresco = response.data["file_name"];
        final dbResponse =
            await AssignmentAlfrescoDraftService.saveLearnerTaskAsDraft(
          taskId: taskSummary.taskId!,
          learnerId: entityId,
          wordCount: getWordCount(htmlContent).toString(),
          fileName: fileNameFromAlfresco,
        );

        return dbResponse;
      }
      return false;
    } catch (e) {
      print("Error saving draft: $e");
      return false;
    }
  }

  // Helper method to count words
  int getWordCount(String htmlContent) {
    final RegExp htmlTags = RegExp(r'<[^>]+>');
    String cleanText = htmlContent.replaceAll(htmlTags, ' ');
    cleanText = cleanText.replaceAll('&nbsp;', ' ');
    List<String> words = cleanText
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    return words.length;
  }

  Future<void> listenToSSEWithDio(
      String userMessage, String studentResponse) async {
    final bool draftSaved = await saveDraft(studentResponse);
    if (!draftSaved) {
      print("⚠️ Draft save failed, but continuing with AI chat");
    }

    final dio = Dio();
    String thinkingMessageId = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      final entityId = LocalStorage.getDBEntityID();
      if (entityId == null || entityId.isEmpty) {
        print("❌ No entityId found in LocalStorage");
        return;
      }

      // Get task details to obtain llm_session_id
      final taskDetailsResponse = await dio.get(
        "${API.baseURl}/db/writingpad/get_taskdetails/",
        queryParameters: {
          'learner_id': entityId,
          'task_id': taskId,
        },
      );

      if (taskDetailsResponse.statusCode != 200) {
        print(
            "❌ Failed to get task details: ${taskDetailsResponse.statusCode}");
        return;
      }

      final data = taskDetailsResponse.data;
      print("📋 Task details response: $data");

      final taskSummary = (data["task_summary"] as List?)?.first;

      // Extract llm_session_id from the response
      String? llmSessionId;
      if (taskSummary != null && taskSummary is Map<String, dynamic>) {
        llmSessionId = taskSummary["llm_session_id"];
      }

      if (llmSessionId == null || llmSessionId.isEmpty) {
        print("❌ No llm_session_id found in task details response");
        return;
      }

      print("✅ Retrieved llm_session_id: $llmSessionId");

      // Add user message to chat FIRST
      final userMessageId = DateTime.now().millisecondsSinceEpoch.toString();
      sageAIList.add(SageAIModel(
        text: userMessage,
        isMe: true,
        id: userMessageId,
      ));

      // Add thinking message
      sageAIList.add(SageAIModel(
        text: "Thinking...",
        isMe: false,
        id: thinkingMessageId,
        isThinking: true,
      ));

      isThinking.value = true;

      // Prepare request data
      final requestData = {
        "sessionId": llmSessionId,
        "question": userMessage,
        "studentResponse": studentResponse,
      };

      print("📤 Sending request to stream-chat: $requestData");

      // Call the stream-chat API with the obtained sessionId
      final response = await dio.post(
        "${API.baseURl}/ai/sage-ai-chat",
        data: requestData,
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            HttpHeaders.acceptHeader: 'text/event-stream',
            HttpHeaders.contentTypeHeader: 'application/json',
          },
        ),
      );

      print("📥 Response status: ${response.statusCode}");
      print("📥 Response headers: ${response.headers}");
      print("📥 Raw response data: ${response.data}");

      String finalResponse = "";

      if (response.statusCode == 200) {
        final responseString = response.data.toString().trim();
        print("🎯 Raw response: '$responseString'");

        finalResponse = responseString;

        try {
          // Parse the JSON response
          final jsonResponse = json.decode(responseString);

          // Extract the aiResponse field
          if (jsonResponse is Map<String, dynamic> &&
              jsonResponse.containsKey('aiResponse')) {
            finalResponse = jsonResponse['aiResponse'].toString();
          } else if (jsonResponse is Map<String, dynamic> &&
              jsonResponse.containsKey('infoMsg') &&
              jsonResponse['infoMsg'] is Map<String, dynamic> &&
              jsonResponse['infoMsg'].containsKey('textResponse')) {
            // Fallback to textResponse if aiResponse is not available
            finalResponse = jsonResponse['infoMsg']['textResponse'].toString();
          }

          // Clean up the response text (remove extra quotes)
          finalResponse = finalResponse.replaceAll('"', '').trim();
        } catch (e) {
          print("❌ Failed to parse JSON response: $e");
          // If parsing fails, use the original response
        }

        print("🎯 Final response to display: '$finalResponse'");
      } else {
        print("❌ API call failed: ${response.statusCode}");
        finalResponse =
            "Failed to get response from AI. Status: ${response.statusCode}";
      }

      // Replace thinking message with actual response
      final thinkingIndex =
          sageAIList.indexWhere((msg) => msg.id == thinkingMessageId);
      if (thinkingIndex != -1) {
        sageAIList[thinkingIndex] = SageAIModel(
          text: finalResponse.isNotEmpty
              ? finalResponse
              : "No response received from AI.",
          isMe: false,
          id: thinkingMessageId,
        );
      } else {
        // If thinking message was already removed, add the response as a new message
        sageAIList.add(SageAIModel(
          text: finalResponse.isNotEmpty
              ? finalResponse
              : "No response received from AI.",
          isMe: false,
          id: DateTime.now().millisecondsSinceEpoch.toString(),
        ));
      }

      isThinking.value = false;

      // Save the chat to backend
      if (finalResponse.isNotEmpty && response.statusCode == 200) {
        try {
          final saveChatResponse = await dio.post(
            "${API.baseURl}/sage-ai/save-chat",
            data: {
              "learner_id": entityId,
              "task_id": taskId,
              "prompt_text": userMessage,
              "ai_response": finalResponse,
            },
          );

          print("💾 Chat saved response: ${saveChatResponse.data}");
          aiPromptsUsed.value++;
        } catch (e) {
          print("❌ Failed to save chat: $e");
        }
      }
    } catch (e) {
      print("❌ SSE Connection Error: $e");
      print("❌ Error type: ${e.runtimeType}");

      // Replace thinking message with error message
      final thinkingIndex =
          sageAIList.indexWhere((msg) => msg.id == thinkingMessageId);
      if (thinkingIndex != -1) {
        sageAIList[thinkingIndex] = SageAIModel(
          text: e is DioException
              ? "Connection error: ${e.response?.data ?? e.toString()}"
              : "Connection error: ${e.toString()}",
          isMe: false,
          id: thinkingMessageId,
        );
      } else {
        // If thinking message was already removed, add error as a new message
        sageAIList.add(SageAIModel(
          text: e is DioException
              ? "Connection error: ${e.response?.data ?? e.toString()}"
              : "Connection error: ${e.toString()}",
          isMe: false,
          id: DateTime.now().millisecondsSinceEpoch.toString(),
        ));
      }

      isThinking.value = false;
    }

    // Print final state of sageAIList for debugging
    print(
        "📋 Final sageAIList: ${sageAIList.map((e) => '${e.isMe ? "User" : "AI"}: ${e.text}').toList()}");
  }

  /// ------------------- HELPERS --------------------
  String getInitials(String name) {
    final names = name.trim().split(' ');
    if (names.length >= 2) {
      return names[0][0].toUpperCase() + names[1][0].toUpperCase();
    } else if (names.length == 1 && names[0].isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return '';
  }
}

// Update the SageAIModel to include id and isThinking properties
class SageAIModel {
  final String text;
  final bool isMe;
  final String id;
  final bool isThinking;

  SageAIModel({
    required this.text,
    required this.isMe,
    this.id = '',
    this.isThinking = false,
  });
}
