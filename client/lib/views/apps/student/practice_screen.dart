import 'dart:math' as math;
import 'package:vantanceCA/controller/apps/student/practice_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizScreenExact extends StatefulWidget {
  final VoidCallback? onExit;

  const QuizScreenExact({super.key, this.onExit});

  @override
  State<QuizScreenExact> createState() => _QuizScreenExactState();
}

class _QuizScreenExactState extends State<QuizScreenExact> {
  late QuizController _controller;
  final QuillController _quillController = QuillController.basic();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _answerController = TextEditingController();

  // We keep table widgets in the view as they contain their own text controllers
  final Map<int, List<Widget>> _tablesByQuestion = {};

  // Store text answers for each question
  final Map<int, String> _textAnswers = {};

  @override
  void initState() {
    super.initState();
    _controller = QuizController();
    _controller.addListener(_onControllerChange);
    _quillController.addListener(_onEditorChange);
    _answerController.addListener(_onAnswerTextChange);

    // Set up callback for when time runs out
    _controller.onTimeUp = _handleTimeUp;
  }

  void _onControllerChange() {
    // Load saved answer for current question when question changes
    _loadAnswerForCurrentQuestion();
    setState(() {});
  }

  void _onEditorChange() {
    setState(() {});
  }

  void _onAnswerTextChange() {
    // Auto-save answer as user types
    _textAnswers[_controller.currentQuestionIndex] = _answerController.text;
  }

  void _loadAnswerForCurrentQuestion() {
    // Load saved answer for the current question
    final savedAnswer = _textAnswers[_controller.currentQuestionIndex] ?? '';
    _answerController.text = savedAnswer;
  }

  void _handleTimeUp() {
    // Show dialog that practice session has been auto-submitted
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(
            'Time\'s Up!',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          content: Text(
            'The practice session time has ended. Your answers have been automatically submitted. You can no longer edit or submit new answers.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    _quillController.removeListener(_onEditorChange);
    _answerController.removeListener(_onAnswerTextChange);
    _quillController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _answerController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_answerController.text.isEmpty) return;

    _controller.saveAnswer(_answerController.text);

    // Clear the main editor for the next answer
    _answerController.clear();

    // Clear any tables for the current question (View logic)
    setState(() {
      if (_tablesByQuestion.containsKey(_controller.currentQuestionIndex)) {
        _tablesByQuestion[_controller.currentQuestionIndex] = [];
      }
    });
  }

  void _editAnswer(int index, String answer) {
    // Load the answer content back into the main editor
    _answerController.text = answer;

    // Remove this answer from the saved list via controller
    _controller.deleteAnswer(index);
  }

  void _nextQuestion() {
    _controller.nextQuestion();
    _quillController.clear();
  }

  void _previousQuestion() {
    _controller.previousQuestion();
    _quillController.clear();
  }

  void _handleSubmit() {
    // Show confirmation dialog before submitting
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Submit Practice Session?',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          content: Text(
            'Are you sure you want to submit your practice session? You will not be able to make any changes after submission.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _submitExam();
              },
              child: Text(
                'Yes',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _submitExam() {
    // Mark exam as submitted in the controller
    _controller.submitExam();

    // Show success message
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Completed!',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.green,
            ),
          ),
          content: Text(
            'Your practice session has been successfully submitted. Thank you!',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleExit() {
    // Show confirmation dialog before exiting
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.exit_to_app_rounded,
                color: Color(0xFFD32F2F),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Exit Practice Session?',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your progress will be saved automatically:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              _buildExitInfoRow(
                  Icons.check_circle_outline, 'All answers saved'),
              const SizedBox(height: 8),
              _buildExitInfoRow(Icons.timer_outlined, 'Timer state preserved'),
              const SizedBox(height: 8),
              _buildExitInfoRow(
                  Icons.bookmark_outline, 'Current question bookmarked'),
              const SizedBox(height: 16),
              Text(
                'You can resume from where you left off when you return.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // The state is already being saved automatically by the controller
                // Use callback if provided, otherwise pop navigator
                if (widget.onExit != null) {
                  widget.onExit!();
                } else {
                  Navigator.of(context).pop(); // Exit the practice screen
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Exit',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExitInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF4CAF50),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  String _formatTime(int totalSeconds) {
    final hours = (totalSeconds ~/ 3600).toString();
    final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String get _currentDateString {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  String get _currentTimeString {
    final now = DateTime.now();
    final hour =
        now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  bool _isAttributeActive(Attribute attribute) {
    final style = _quillController.getSelectionStyle();
    return style.attributes.containsKey(attribute.key) &&
        style.attributes[attribute.key]!.value == attribute.value;
  }

  void _toggleAttribute(Attribute attribute) {
    final isToggled = _isAttributeActive(attribute);
    if (isToggled) {
      _quillController.formatSelection(Attribute.clone(attribute, null));
    } else {
      _quillController.formatSelection(attribute);
    }
  }

  void _insertTable() {
    showDialog(
      context: context,
      builder: (context) => const TableSelectionDialog(),
    ).then((value) {
      if (value != null && value is Map<String, int>) {
        final rows = value['rows']!;
        final cols = value['cols']!;

        // Create the table widget
        final tableWidget = _buildEditableTable(rows, cols);

        setState(() {
          // Initialize list for current question if not exists
          if (!_tablesByQuestion
              .containsKey(_controller.currentQuestionIndex)) {
            _tablesByQuestion[_controller.currentQuestionIndex] = [];
          }

          // Add the table to the current question
          _tablesByQuestion[_controller.currentQuestionIndex]!.add(tableWidget);
        });
      }
    });
  }

  Widget _buildEditableTable(int rows, int cols) {
    // Create a unique key for this table instance
    final tableKey = UniqueKey();

    return Container(
      key: tableKey,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Table(
        border: TableBorder.all(color: Colors.black54, width: 1),
        columnWidths: {
          for (var item in List.generate(cols, (index) => index))
            item: const FlexColumnWidth()
        },
        children: List.generate(rows, (rowIndex) {
          return TableRow(
            children: List.generate(cols, (colIndex) {
              return Container(
                constraints: const BoxConstraints(minHeight: 40),
                child: TextField(
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  void _showCalculator() {
    showDialog(
      context: context,
      builder: (context) => const CalculatorDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentSavedAnswers = _controller.getSavedAnswersForCurrentQuestion();

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: isMobile 
              ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0)
              : const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
          child: Column(
            children: [
              // Fixed top header
              _buildTopHeader(),
              const SizedBox(height: 24),
              // Scrollable content area (question card + saved answers)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question card (no internal scrolling)
                      _buildQuestionCard(),
                      const SizedBox(height: 24),
                      // Saved answers section (no internal scrolling)
                      if (currentSavedAnswers.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...currentSavedAnswers.asMap().entries.map((entry) {
                              return Column(
                                children: [
                                  _buildPreviewCard(entry.key, entry.value),
                                  const SizedBox(height: 16),
                                ],
                              );
                            }),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Fixed answer box at bottom
              _buildAnswerEditor(),
              const SizedBox(height: 16),
              // Fixed navigation at bottom
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    final titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF2A2A2A),
            ),
            children: [
              const TextSpan(text: 'Paper '),
              const TextSpan(
                text: 'Accountancy',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: '  /  Unit '),
              const TextSpan(
                text: 'Meaning Scope of Accounting',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: '  /  Questions '),
              TextSpan(
                text:
                    '${_controller.currentQuestionIndex + 1}/${_controller.questions.length}', // Dynamic Question Number
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF6B6B6B),
            ),
            children: [
              const TextSpan(text: 'Foundation: '),
              const TextSpan(
                text: '2025',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black),
              ),
              const TextSpan(text: '  |  Due Date: '),
              TextSpan(
                text: _currentDateString,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black),
              ),
              const TextSpan(text: '  |  Time: '),
              TextSpan(
                text: _currentTimeString,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );

    // Reuse existing Row(Timer + Exit) code logic by keeping structure but wrapping in responsive widget
    // The previous code had `Row( children: [ Expanded(child: titleSection), Row(Timer+Exit) ] )`
    // We will recreate the Timer+Exit row here to use it.
    
    final actionsRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer_outlined,
                  size: 18, color: Color(0xFF6B6B6B)),
              const SizedBox(width: 8),
              Text(
                _formatTime(_controller.remainingSeconds),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4A4A4A),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 10),
              // Play/Pause Button inside Circle
              InkWell(
                onTap: () {
                  if (_controller.isTimerPaused) {
                    _controller.resumeTimer();
                  } else {
                    _controller.pauseTimer();
                  }
                },
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Circular progress indicator
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CustomPaint(
                          painter: TimerPainter(
                            progress: _controller.remainingSeconds /
                                _controller.totalTimeSeconds,
                            color: _controller.remainingSeconds < 300
                                ? Colors.red
                                : const Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                      // Play/Pause icon in center
                      Icon(
                        _controller.isTimerPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        size: 14,
                        color: const Color(0xFF2A2A2A),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Exit Button
        InkWell(
          onTap: _controller.isExamSubmitted ? null : _handleExit,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _controller.isExamSubmitted
                  ? Colors.grey.shade200
                  : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.exit_to_app_rounded,
                  size: 18,
                  color: _controller.isExamSubmitted
                      ? Colors.grey.shade400
                      : const Color(0xFFD32F2F),
                ),
                const SizedBox(width: 6),
                Text(
                  'Exit',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _controller.isExamSubmitted
                        ? Colors.grey.shade400
                        : const Color(0xFFD32F2F),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleSection,
          const SizedBox(height: 16),
          // Actions row full width or aligned
          actionsRow,
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: titleSection),
          actionsRow,
        ],
      );
    }
  }

  Widget _buildQuestionCard() {
    final question = _controller.currentQuestion;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? screenWidth : screenWidth * 0.75,
        ),
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F2), // Light beige/cream background
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Title
            Text(
              question.title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),

            // Main question text with (a) prefix
            RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.6,
                  color: const Color(0xFF333333),
                ),
                children: [
                  TextSpan(
                    text: '(a)  ',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: question.text),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Subtext header (bold)
            Text(
              question.subtext,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2A2A2A),
              ),
            ),

            const SizedBox(height: 12),

            // Numbered bullet points
            ...question.bullets.asMap().entries.map((entry) {
              return _buildNumberedBulletPoint(entry.key + 1, entry.value);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberedBulletPoint(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '$number.',
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.6,
                color: const Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.6,
                color: const Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerEditor() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toolbar with soft rounded square buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildIconButton(Icons.undo),
                const SizedBox(width: 8),
                _buildIconButton(Icons.redo),
                const SizedBox(width: 8),
                _buildIconButton(Icons.format_bold),
                const SizedBox(width: 8),
                _buildIconButton(Icons.format_italic),
                const SizedBox(width: 8),
                _buildIconButton(Icons.format_underline),
                const SizedBox(width: 8),
                _buildIconButton(Icons.format_align_left),
                const SizedBox(width: 8),
                _buildIconButton(Icons.format_align_center),
                const SizedBox(width: 8),
                _buildIconButton(Icons.format_align_right),
                const SizedBox(width: 8),
                _buildIconButton(Icons.code),
                const SizedBox(width: 8),
                _buildIconButton(Icons.table_chart),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Answer Input Field
          TextField(
            controller: _answerController,
            enabled: !_controller.isExamSubmitted && !_controller.isTimerPaused,
            maxLines: null,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: _controller.isExamSubmitted
                  ? "Practice session submitted - No further edits allowed"
                  : _controller.isTimerPaused
                      ? "Timer paused - Resume to continue editing"
                      : "Type your Answer",
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 20,
        color: const Color(0xFF9E9E9E),
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      width: 32,
      height: 32,
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        color: isActive ? Colors.blue : const Color(0xFF666666),
      ),
    );
  }

  Widget _buildPreviewCard(int index, String answer) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F2), // Light beige/cream background
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Answer label and action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Answer Label
                Text(
                  'Answer ${index + 1}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF666666),
                    letterSpacing: 0.5,
                  ),
                ),
                // Edit/Delete buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      color: _controller.isExamSubmitted
                          ? Colors.grey.shade300
                          : Colors.grey.shade600,
                      onPressed: _controller.isExamSubmitted
                          ? null
                          : () => _editAnswer(index, answer),
                      tooltip: 'Edit Answer',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: _controller.isExamSubmitted
                          ? Colors.grey.shade300
                          : Colors.grey.shade600,
                      onPressed: _controller.isExamSubmitted
                          ? null
                          : () => _controller.deleteAnswer(index),
                      tooltip: 'Delete Answer',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Display the user's typed answer
            Text(
              answer,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF333333),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatementOfCostTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // Header
          Container(
            color: const Color(0xFFEEEEEE),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Particulars',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "Amount (`)",
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Row 1: Personnel Cost Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Personnel Cost:',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Row 2: Collection Personnel
          _buildTableRow(
              'Collection Personnel (3 × 10 × 800 × 30)', '7,20,000'),
          // Row 3: Supervisor
          _buildTableRow('Supervisor (2 × 3 × 1,200 × 30)', '2,16,000'),
          // Row 4: Security Personnel
          _buildTableRow('Security Personnel (3 × 10 × 500 × 30)', '4,50,000'),
          // Row 5: Total Cost
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFEEEEEE),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Total Cost',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '13,86,000',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(String label, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              amount,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side: Previous, Next
        Row(
          children: [
            TextButton.icon(
              onPressed: _controller.isExamSubmitted ? null : _previousQuestion,
              icon: Icon(Icons.arrow_back,
                  size: 16,
                  color: _controller.isExamSubmitted
                      ? Colors.grey.shade300
                      : const Color(0xFF888888)),
              label: Text(
                'Previous',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _controller.isExamSubmitted
                      ? Colors.grey.shade300
                      : const Color(0xFF888888),
                ),
              ),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: _controller.isExamSubmitted ? null : _nextQuestion,
              child: Row(
                children: [
                  Text(
                    'Next',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _controller.isExamSubmitted
                          ? Colors.grey.shade300
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward,
                      size: 16,
                      color: _controller.isExamSubmitted
                          ? Colors.grey.shade300
                          : Colors.black),
                ],
              ),
            ),
          ],
        ),

        // Right side: Skip, Save, Submit
        Row(
          children: [
            TextButton.icon(
              onPressed: _controller.isExamSubmitted ? null : _nextQuestion,
              icon: Icon(Icons.skip_next_outlined,
                  size: 16,
                  color: _controller.isExamSubmitted
                      ? Colors.grey.shade300
                      : const Color(0xFF888888)),
              label: Text(
                'skip',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _controller.isExamSubmitted
                      ? Colors.grey.shade300
                      : const Color(0xFF888888),
                ),
              ),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: _controller.isExamSubmitted ? null : _handleSave,
              icon: Icon(Icons.save_outlined,
                  size: 16,
                  color: _controller.isExamSubmitted
                      ? Colors.grey.shade300
                      : const Color(0xFF888888)),
              label: Text(
                'Save',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _controller.isExamSubmitted
                      ? Colors.grey.shade300
                      : const Color(0xFF888888),
                ),
              ),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: _controller.isExamSubmitted ? null : _handleSubmit,
              icon: Icon(Icons.check_circle_outline,
                  size: 16,
                  color: _controller.isExamSubmitted
                      ? Colors.grey.shade300
                      : Colors.black),
              label: Text(
                'Submit',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _controller.isExamSubmitted
                      ? Colors.grey.shade300
                      : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TimerPainter extends CustomPainter {
  final double progress;
  final Color color;

  TimerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 2.5;

    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant TimerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class CalculatorDialog extends StatefulWidget {
  const CalculatorDialog({super.key});

  @override
  State<CalculatorDialog> createState() => _CalculatorDialogState();
}

class _CalculatorDialogState extends State<CalculatorDialog> {
  String _output = "0";
  String _currentNumber = "";
  double _num1 = 0;
  double _num2 = 0;
  String _operand = "";

  void _buttonPressed(String buttonText) {
    if (buttonText == "C") {
      _output = "0";
      _currentNumber = "";
      _num1 = 0;
      _num2 = 0;
      _operand = "";
    } else if (buttonText == "+" ||
        buttonText == "-" ||
        buttonText == "/" ||
        buttonText == "X") {
      _num1 = double.parse(_output);
      _operand = buttonText;
      _currentNumber = "";
    } else if (buttonText == ".") {
      if (_currentNumber.contains(".")) {
        return;
      } else {
        _currentNumber = _currentNumber + buttonText;
      }
    } else if (buttonText == "=") {
      _num2 = double.parse(_output);

      if (_operand == "+") {
        _output = (_num1 + _num2).toString();
      }
      if (_operand == "-") {
        _output = (_num1 - _num2).toString();
      }
      if (_operand == "X") {
        _output = (_num1 * _num2).toString();
      }
      if (_operand == "/") {
        _output = (_num1 / _num2).toString();
      }

      _num1 = 0;
      _num2 = 0;
      _operand = "";
      _currentNumber = _output; // Allow chaining
    } else {
      _currentNumber = _currentNumber + buttonText;
      _output = _currentNumber;
    }

    setState(() {});
  }

  Widget _buildButton(String buttonText, {Color? color, Color? textColor}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey[200],
            foregroundColor: textColor ?? Colors.black,
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          onPressed: () => _buttonPressed(buttonText),
          child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
              child: Text(
                _output,
                style: const TextStyle(
                  fontSize: 48.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            Column(
              children: [
                Row(
                  children: [
                    _buildButton("7"),
                    _buildButton("8"),
                    _buildButton("9"),
                    _buildButton("/",
                        color: Colors.orange, textColor: Colors.white),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("4"),
                    _buildButton("5"),
                    _buildButton("6"),
                    _buildButton("X",
                        color: Colors.orange, textColor: Colors.white),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("1"),
                    _buildButton("2"),
                    _buildButton("3"),
                    _buildButton("-",
                        color: Colors.orange, textColor: Colors.white),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("."),
                    _buildButton("0"),
                    _buildButton("00"),
                    _buildButton("+",
                        color: Colors.orange, textColor: Colors.white),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("C",
                        color: Colors.red[100], textColor: Colors.red),
                    _buildButton("=",
                        color: Colors.blue, textColor: Colors.white),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class TableSelectionDialog extends StatefulWidget {
  const TableSelectionDialog({super.key});

  @override
  State<TableSelectionDialog> createState() => _TableSelectionDialogState();
}

class _TableSelectionDialogState extends State<TableSelectionDialog> {
  int _rows = 3;
  int _cols = 3;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insert Table',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rows'),
                      const SizedBox(height: 8),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        controller:
                            TextEditingController(text: _rows.toString()),
                        onChanged: (val) =>
                            setState(() => _rows = int.tryParse(val) ?? 3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Columns'),
                      const SizedBox(height: 8),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        controller:
                            TextEditingController(text: _cols.toString()),
                        onChanged: (val) =>
                            setState(() => _cols = int.tryParse(val) ?? 3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {'rows': _rows, 'cols': _cols});
                  },
                  child: const Text('Insert'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
