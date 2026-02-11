import 'dart:async';
import 'dart:math' as math;
import 'package:vantanceCA/controller/apps/student/practice_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vantanceCA/views/layouts/layout.dart';

class QuizScreenExact extends StatefulWidget {
  final VoidCallback? onExit;
  const QuizScreenExact({super.key, this.onExit}); // Accepts onExit

  @override
  State<QuizScreenExact> createState() => _QuizScreenExactState();
}

class _QuizScreenExactState extends State<QuizScreenExact> {
  late QuizController _controller;
  final QuillController _quillController = QuillController.basic();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // We keep table widgets in the view as they contain their own text controllers
  final Map<int, List<Widget>> _tablesByQuestion = {};

  @override
  void initState() {
    super.initState();
    _controller = QuizController();
    _controller.addListener(_onControllerChange);
    _quillController.addListener(_onEditorChange);
  }

  void _onControllerChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onEditorChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _focusNode.unfocus();
    _controller.removeListener(_onControllerChange);
    _quillController.removeListener(_onEditorChange);
    _quillController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showSubmitConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Confirm Submission",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Are you sure you want to submit this assignment?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          _controller.submitExam();
                          
                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Assignment submitted successfully!"),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // Exit after short delay
                          Future.delayed(const Duration(seconds: 1), () {
                            if (widget.onExit != null) {
                              widget.onExit!();
                            }
                          });
                        },
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xff004AAD), Color(0xffCB6CE6)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Text(
                              "Confirm",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(dialogContext).pop(),
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFFD1D5DB), width: 1),
                            borderRadius: BorderRadius.circular(24),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF374151),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleSave() {
    if (_quillController.document.isEmpty()) return;

    _controller.saveAnswer(
      _quillController.document.toPlainText(),
    );

    // Clear the main editor for the next answer
    _quillController.clear();

    // Clear any tables for the current question (View logic)
    setState(() {
      if (_tablesByQuestion.containsKey(_controller.currentQuestionIndex)) {
        _tablesByQuestion[_controller.currentQuestionIndex] = [];
      }
    });
  }

  void _editAnswer(int index, Document document) {
    // Load the answer content back into the main editor
    _quillController.document = Document.fromDelta(document.toDelta());

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
    return Layout(
      shrinkContent: true,
      selectedPage: 1, // Practices
      child: Builder(
        builder: (context) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final currentSavedAnswers =
              _controller.getSavedAnswersForCurrentQuestion();

          return SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
              child: Column(
                children: [
                  _buildTopHeader(),
                  const SizedBox(height: 24),
                  // Scrollable question and saved answers section
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildQuestionCard(),
                          const SizedBox(height: 60),

                          // Render saved answers for THIS question
                          if (currentSavedAnswers.isNotEmpty)
                            ...currentSavedAnswers.asMap().entries.map((entry) {
                              return Column(
                                children: [
                                  _buildPreviewCard(entry.key, entry.value),
                                  const SizedBox(height: 24),
                                ],
                              );
                            }),

                          // Add some bottom padding for scrolling comfort
                          const SizedBox(height: 20),
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
          );
        },
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Exit Button
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2A2A2A)),
            onPressed: widget.onExit,
            tooltip: "Exit",
          ),
        ),
        Expanded(
          child: Column(
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
          ),
        ),
        // Timer Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer_outlined,
                  size: 18, color: Color(0xFF555555)),
              const SizedBox(width: 8),
              Text(
                _formatTime(_controller.remainingSeconds),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 24,
                height: 24,
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    final question = _controller.currentQuestion;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.text,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        height: 1.6,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      question.subtext,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF444444),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...question.bullets
                        .map((bullet) => _buildBulletPoint(bullet)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Icon(Icons.circle, size: 6, color: Color(0xFF666666)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.5,
                color: const Color(0xFF555555),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerEditor() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toolbar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildToolbarButton(
                  icon: Icons.undo,
                  onPressed: () {
                    if (_quillController.hasUndo) _quillController.undo();
                  },
                ),
                _buildToolbarButton(
                  icon: Icons.redo,
                  onPressed: () {
                    if (_quillController.hasRedo) _quillController.redo();
                  },
                ),
                const SizedBox(width: 8),
                _buildToolbarButton(
                  icon: Icons.format_bold,
                  onPressed: () => _toggleAttribute(Attribute.bold),
                  isActive: _isAttributeActive(Attribute.bold),
                ),
                _buildToolbarButton(
                  icon: Icons.format_italic,
                  onPressed: () => _toggleAttribute(Attribute.italic),
                  isActive: _isAttributeActive(Attribute.italic),
                ),
                _buildToolbarButton(
                  icon: Icons.format_underline,
                  onPressed: () => _toggleAttribute(Attribute.underline),
                  isActive: _isAttributeActive(Attribute.underline),
                ),
                const SizedBox(width: 8),
                _buildToolbarButton(
                  icon: Icons.format_align_left,
                  onPressed: () => _toggleAttribute(Attribute.leftAlignment),
                  isActive: _isAttributeActive(Attribute.leftAlignment),
                ),
                _buildToolbarButton(
                  icon: Icons.format_align_center,
                  onPressed: () => _toggleAttribute(Attribute.centerAlignment),
                  isActive: _isAttributeActive(Attribute.centerAlignment),
                ),
                _buildToolbarButton(
                  icon: Icons.format_align_right,
                  onPressed: () => _toggleAttribute(Attribute.rightAlignment),
                  isActive: _isAttributeActive(Attribute.rightAlignment),
                ),
                const SizedBox(width: 8),
                _buildToolbarButton(
                  icon: Icons.calculate_outlined,
                  onPressed: _showCalculator,
                ),
                _buildToolbarButton(
                  icon: Icons.table_chart_outlined,
                  onPressed: _insertTable,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Editor Area
          Container(
            constraints: const BoxConstraints(
              minHeight: 50,
              maxHeight: 150,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QuillEditor.basic(
                    controller: _quillController,
                    focusNode: _focusNode,
                  ),
                  // Display tables for the current question
                  if (_tablesByQuestion
                      .containsKey(_controller.currentQuestionIndex))
                    ..._tablesByQuestion[_controller.currentQuestionIndex]!,
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildPreviewCard(int index, String content) {
    // Create a Document from the String content (saved as plain text)
    final document = Document()..insert(0, content);

    // Create a temporary controller for read-only display
    final tempController = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Answer ${index + 1}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF666666),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    color: Colors.blue,
                    onPressed: () => _editAnswer(index, document),
                    tooltip: 'Edit Answer',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: Colors.red,
                    onPressed: () => _controller.deleteAnswer(index),
                    tooltip: 'Delete Answer',
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          QuillEditor.basic(
            controller: tempController,
            focusNode: FocusNode(), // Dummy focus node for read-only
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
              onPressed: _previousQuestion,
              icon: const Icon(Icons.arrow_back,
                  size: 16, color: Color(0xFF888888)),
              label: Text(
                'Previous',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF888888),
                ),
              ),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: _nextQuestion,
              child: Row(
                children: [
                  Text(
                    'Next',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward,
                      size: 16, color: Colors.black),
                ],
              ),
            ),
          ],
        ),

        // Right side: Skip, Save, Submit
        Row(
          children: [
            TextButton.icon(
              onPressed: _nextQuestion, // Skip usually just goes next
              icon: const Icon(Icons.skip_next_outlined,
                  size: 16, color: Color(0xFF888888)),
              label: Text(
                'skip',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF888888),
                ),
              ),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: _handleSave,
              icon: const Icon(Icons.save_outlined,
                  size: 16, color: Color(0xFF888888)),
              label: Text(
                'Save',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF888888),
                ),
              ),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: _showSubmitConfirmationDialog,
              icon: const Icon(Icons.check_circle_outline,
                  size: 16, color: Colors.black),
              label: Text(
                'Submit',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
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
    final radius = math.min(size.width, size.height) / 2;

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
