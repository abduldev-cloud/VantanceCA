import 'package:binary_success/helpers/services/teacher_service.dart';
import 'package:binary_success/widgets/common_status_dialog.dart';
import 'package:flutter/material.dart' hide Element;
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

class RichSelectableHtml extends StatefulWidget {
  final String htmlContent;
  final Function(int start, int end, String text) onSelectionChanged;
  final List<dynamic> comments;
  final double popupWidth;
  final int? currentSelectionStart;
  final int? currentSelectionEnd;
  final Function(List<dynamic>)? onCommentsUpdated;
  final void Function(Offset position)? onTextClick;
  final void Function(String webHtmlSelectedText)? onIconClick;

  const RichSelectableHtml({
    super.key,
    required this.htmlContent,
    this.comments = const [],
    required this.onSelectionChanged,
    this.isGradeSubmitted = false, // Added
    this.gradingData, // Added
    this.learnerTaskId, // Added
    this.currentSelectionStart,
    this.currentSelectionEnd,
    this.popupWidth = 500.0,
    this.onCommentsUpdated,
    this.onTextClick,
    this.onIconClick,
  });

  final bool isGradeSubmitted;
  final dynamic gradingData;
  final dynamic learnerTaskId;

  @override
  State<RichSelectableHtml> createState() => _RichSelectableHtmlState();
}

class _LineInfo {
  final double top;
  final double height;
  final int startCharIndex;
  final int endCharIndex;
  _LineInfo(this.top, this.height, this.startCharIndex, this.endCharIndex);
}

class _RichSelectableHtmlState extends State<RichSelectableHtml> {
  late TextSpan _textSpan;
  late String _fullPlainText;
  final GlobalKey _innerStackKey = GlobalKey();
  OverlayEntry? _activePopup;
  List<_LineInfo> _lines = [];
  int? selectionStart;
  int? selectionEnd;
  String selectedText = "";

  String webHtmlSelectedText = "";

  late List<Map<String, dynamic>> _comments;

  @override
  void initState() {
    super.initState();
    _comments =
        widget.comments.map((c) => Map<String, dynamic>.from(c)).toList();
    _removeDuplicateCommentsFromApi();

    final sanitizedHtml =
        widget.htmlContent.replaceAll(RegExp(r'[\u0000-\u001F]'), '');
    final doc = html_parser.parse(sanitizedHtml);
    final baseSpan = _buildBaseSpan(doc.body!);
    _fullPlainText = _extractTextFromSpan(baseSpan);

    int cursor = 0;

    TextSpan apply(TextSpan span) {
      final List<TextSpan> newChildren = [];
      final spanText = span.text ?? '';
      if (spanText.isNotEmpty) {
        final leafText = spanText;
        final leafStart = cursor;
        final leafEnd = leafStart + leafText.length;

        final cutPoints = <int>{0, leafText.length};
        for (final c in _comments) {
          final int cs = (c['selection_start'] is int)
              ? c['selection_start'] as int
              : int.tryParse('${c['selection_start']}') ?? 0;
          final int ce = (c['selection_end'] is int)
              ? c['selection_end'] as int
              : int.tryParse('${c['selection_end']}') ?? 0;
          if (ce > leafStart && cs < leafEnd) {
            cutPoints.add((cs - leafStart).clamp(0, leafText.length));
            cutPoints.add((ce - leafStart).clamp(0, leafText.length));
          }
        }

        final sortedCuts = cutPoints.toList()..sort();
        for (int i = 0; i < sortedCuts.length - 1; i++) {
          final a = sortedCuts[i];
          final b = sortedCuts[i + 1];
          if (a == b) continue;
          final seg = leafText.substring(a, b);
          final segGlobalStart = leafStart + a;
          final segGlobalEnd = leafStart + b;

          final overlapping = _comments.where((c) {
            final int cs = (c['selection_start'] is int)
                ? c['selection_start'] as int
                : int.tryParse('${c['selection_start']}') ?? 0;
            final int ce = (c['selection_end'] is int)
                ? c['selection_end'] as int
                : int.tryParse('${c['selection_end']}') ?? 0;
            return cs < segGlobalEnd && ce > segGlobalStart;
          }).toList();

          if (overlapping.isNotEmpty) {
            final highlightStyle = (span.style ?? const TextStyle())
                .copyWith(backgroundColor: const Color(0xFFBED3F6));
            final recognizer = TapGestureRecognizer()
              ..onTapDown = (details) {
                final RenderBox box = _innerStackKey.currentContext!
                    .findRenderObject() as RenderBox;
                if (widget.isGradeSubmitted) {
                  _showCenteredCommentPopup(overlapping);
                } else {
                  _showEditCommentDialog(overlapping);
                }
              };
            newChildren.add(TextSpan(
                text: seg, style: highlightStyle, recognizer: recognizer));
          } else {
            newChildren.add(TextSpan(text: seg, style: span.style));
          }
        }

        cursor = leafEnd;
      }

      if (span.children != null && span.children!.isNotEmpty) {
        for (final child in span.children!) {
          newChildren.add(apply(child as TextSpan));
        }
      }

      if (newChildren.isEmpty)
        return TextSpan(text: span.text, style: span.style);
      return TextSpan(children: newChildren, style: span.style);
    }

    _textSpan = apply(baseSpan);
  }

  void _removeDuplicateCommentsFromApi() {
    if (_comments.isEmpty) return;

    _comments = _comments.map((c) => Map<String, dynamic>.from(c)).toList();

    final Map<String, Map<String, dynamic>> latestComments = {};

    for (final comment in _comments) {
      final key = "${comment['selection_start']}_${comment['selection_end']}}";

      DateTime? newUpdated = _parseDate(comment['updated_at']) ??
          _parseDate(comment['created_at']);

      if (!latestComments.containsKey(key)) {
        latestComments[key] = comment;
      } else {
        final existing = latestComments[key]!;
        final existingUpdated = _parseDate(existing['updated_at']) ??
            _parseDate(existing['created_at']);
        if (newUpdated != null &&
            (existingUpdated == null || newUpdated.isAfter(existingUpdated))) {
          latestComments[key] = comment; // replace with newer one
        }
      }
    }

    _comments = latestComments.values.toList();
  }

  DateTime? _parseDate(dynamic dateStr) {
    if (dateStr == null) return null;
    try {
      return DateTime.parse(dateStr.toString());
    } catch (_) {
      return null;
    }
  }

  TextSpan _buildBaseSpan(dom.Node node,
      {int olIndex = 0, int indentLevel = 0}) {
    TextStyle? mergeStyles(TextStyle? a, TextStyle? b) {
      if (a == null) return b;
      if (b == null) return a;
      return a.merge(b);
    }

    Color? parseColorString(String value) {
      final v = value.trim();
      try {
        if (v.startsWith('#')) {
          var hex = v.replaceFirst('#', '');
          if (hex.length == 3) {
            hex = hex.split('').map((c) => '$c$c').join();
          }
          if (hex.length == 6) {
            return Color(int.parse('0xFF$hex'));
          } else if (hex.length == 8) {
            return Color(int.parse('0x$hex'));
          }
        } else if (v.toLowerCase().startsWith('rgb')) {
          final nums = v.replaceAll(RegExp(r'[^0-9.,]'), '').split(',');
          if (nums.length >= 3) {
            final r = int.parse(nums[0].trim());
            final g = int.parse(nums[1].trim());
            final b = int.parse(nums[2].trim());
            double a = 1.0;
            if (nums.length == 4) {
              a = double.tryParse(nums[3].trim()) ?? 1.0;
            }
            return Color.fromARGB(
              (a * 255).round().clamp(0, 255),
              r.clamp(0, 255),
              g.clamp(0, 255),
              b.clamp(0, 255),
            );
          }
        }
      } catch (_) {}
      return null;
    }

    if (node.nodeType == dom.Node.TEXT_NODE) {
      return TextSpan(text: node.text ?? '');
    } else if (node is dom.Element) {
      final tag = node.localName?.toLowerCase() ?? '';
      final children = node.nodes;

      // parse inline style
      TextStyle? inlineStyle;
      final styleAttr = (node.attributes['style'] ?? '').trim();
      if (styleAttr.isNotEmpty) {
        final parts = styleAttr.split(';');
        for (var part in parts) {
          if (part.trim().isEmpty) continue;
          final kv = part.split(':');
          if (kv.length < 2) continue;
          final key = kv[0].trim().toLowerCase();
          final value = kv.sublist(1).join(':').trim();
          if (key == 'color') {
            final c = parseColorString(value);
            if (c != null)
              inlineStyle =
                  (inlineStyle ?? const TextStyle()).copyWith(color: c);
          } else if ((key == 'background-color' || key == 'background')) {
            final c = parseColorString(value);
            if (c != null) {
              inlineStyle = (inlineStyle ?? const TextStyle()).copyWith(
                background: Paint()..color = c,
              );
            }
          } else if (key == 'text-decoration' &&
              value.toLowerCase().contains('underline')) {
            inlineStyle = (inlineStyle ?? const TextStyle())
                .copyWith(decoration: TextDecoration.underline);
          } else if (key == 'font-weight' && value.trim() == 'bold') {
            inlineStyle = (inlineStyle ?? const TextStyle())
                .copyWith(fontWeight: FontWeight.bold);
          } else if (key == 'font-style' && value.trim() == 'italic') {
            inlineStyle = (inlineStyle ?? const TextStyle())
                .copyWith(fontStyle: FontStyle.italic);
          }
        }
      }

      // support <font color="">
      if (node.attributes.containsKey('color')) {
        final c = parseColorString(node.attributes['color']!);
        if (c != null)
          inlineStyle = (inlineStyle ?? const TextStyle()).copyWith(color: c);
      }

      // children spans
      final childSpans = children
          .map((c) => _buildBaseSpan(c, indentLevel: indentLevel))
          .toList();

      switch (tag) {
        case 'b':
        case 'strong':
          return TextSpan(
              children: childSpans,
              style: mergeStyles(
                  const TextStyle(fontWeight: FontWeight.bold), inlineStyle));

        case 'i':
        case 'em':
          return TextSpan(
              children: childSpans,
              style: mergeStyles(
                  const TextStyle(fontStyle: FontStyle.italic), inlineStyle));

        case 'u':
          return TextSpan(
              children: childSpans,
              style: mergeStyles(
                  const TextStyle(decoration: TextDecoration.underline),
                  inlineStyle));

        case 'a':
          final href = node.attributes['href'] ?? '';
          return TextSpan(
            children: childSpans,
            style: mergeStyles(
                const TextStyle(
                    color: Colors.blue, decoration: TextDecoration.underline),
                inlineStyle),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                if (href.isNotEmpty) {
                  final uri = Uri.parse(href);
                  if (await canLaunchUrl(uri))
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
          );

        case 'p':
          return TextSpan(
              children: [...childSpans, const TextSpan(text: '\n')],
              style: inlineStyle);

        case 'br':
          return const TextSpan(text: '\n');

        case 'h1':
        case 'h2':
        case 'h3':
        case 'h4':
        case 'h5':
        case 'h6':
          final fontSizes = {
            'h1': 24.0,
            'h2': 22.0,
            'h3': 20.0,
            'h4': 18.0,
            'h5': 16.0,
            'h6': 14.0
          };
          return TextSpan(
            children: [
              const TextSpan(text: '\n'),
              ...childSpans,
              const TextSpan(text: '\n')
            ],
            style: mergeStyles(
                TextStyle(
                    fontSize: fontSizes[tag], fontWeight: FontWeight.bold),
                inlineStyle),
          );

        case 'ul':
          return TextSpan(
              children: children
                  .map((c) => _buildBaseSpan(c, indentLevel: indentLevel + 1))
                  .toList(),
              style: inlineStyle);

        case 'ol':
          int index = 1;
          return TextSpan(
            children: children.map((c) {
              if (c is dom.Element && c.localName?.toLowerCase() == 'li') {
                final span = _buildBaseSpan(c,
                    olIndex: index, indentLevel: indentLevel + 1);
                index++;
                return span;
              }
              return const TextSpan(text: '');
            }).toList(),
            style: inlineStyle,
          );

        case 'li':
          final bullet = olIndex > 0 ? '$olIndex. ' : '• ';
          final indentSpaces = ' ' * (indentLevel * 2);
          return TextSpan(
            text: '$indentSpaces$bullet',
            children: [...childSpans, const TextSpan(text: '\n')],
            style: mergeStyles(
                const TextStyle(height: 1.4, color: Colors.black), inlineStyle),
          );

        case 'blockquote':
          return TextSpan(
              children: childSpans,
              style: mergeStyles(
                  const TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.grey),
                  inlineStyle));

        case 'code':
        case 'pre':
          return TextSpan(
              children: childSpans,
              style: mergeStyles(
                  const TextStyle(
                      fontFamily: 'monospace',
                      backgroundColor: Color(0xFFEFEFEF)),
                  inlineStyle));

        case 'hr':
          return const TextSpan(text: '\n────────────────────────\n');

        default:
          return TextSpan(children: childSpans, style: inlineStyle);
      }
    }

    return const TextSpan(text: '');
  }

  String _extractTextFromSpan(TextSpan span) {
    String text = span.text ?? '';
    if (span.children != null && span.children!.isNotEmpty) {
      for (final child in span.children!) {
        text += _extractTextFromSpan(child as TextSpan);
      }
    }
    return text;
  }

  void _computeLineMetrics(double availableWidth, TextStyle baseStyle) {
    final tp = TextPainter(
        text: _textSpan, textDirection: TextDirection.ltr, maxLines: null);
    tp.layout(minWidth: 0, maxWidth: availableWidth);
    final metrics = tp.computeLineMetrics();
    _lines = [];
    for (final m in metrics) {
      final startPos =
          tp.getPositionForOffset(Offset(0, m.baseline - m.ascent));
      final endPos =
          tp.getPositionForOffset(Offset(m.width - 1, m.baseline - m.ascent));
      final startIndex = startPos.offset;
      var endIndex = endPos.offset;
      if (endIndex <= startIndex) endIndex = startIndex + 1;
      final top = m.baseline - m.ascent;
      _lines.add(_LineInfo(top, m.height, startIndex, endIndex));
    }
  }

  Future<bool> _updateComment(Map c, String newText) async {
    if (widget.isGradeSubmitted) {
      Get.snackbar("Info", "Cannot update comment. Task already graded.");
      return false;
    }

    if (newText.isEmpty) {
      Get.snackbar("Validation", "Please enter a comment.");
      return false;
    }

    final start = widget.currentSelectionStart ?? c['selection_start'];
    final end = widget.currentSelectionEnd ?? c['selection_end'];

    final isDuplicate = _comments.any((existing) =>
        existing['comment_id'] != c['comment_id'] &&
        (existing['selection_start'].toString() == start.toString()) &&
        (existing['selection_end'].toString() == end.toString()) &&
        (existing['comment_text'].toString().trim().toLowerCase() ==
            newText.trim().toLowerCase()));

    if (isDuplicate) {
      Get.snackbar(
          "Duplicate", "Same comment already exists for this selection.");
      return false;
    }

    final newCommentId = await TeacherGradingService.saveLearnerTaskComments(
      reviewComments: {
        "comment_id": c['comment_id'] ?? "",
        "learner_task_id": widget.learnerTaskId,
        "teacher_id": c['teacher_id'],
        "comment_text": newText,
        "selection_start": start,
        "selection_end": end,
      },
    );

    if (newCommentId != null) {
      final newComments = List.from(_comments);
      final index =
          newComments.indexWhere((com) => com['comment_id'] == c['comment_id']);
      if (index != -1) {
        newComments[index] = {
          ...c,
          "comment_text": newText,
          "selection_start": start,
          "selection_end": end,
          "created_date": DateTime.now().toIso8601String(),
        };
      }

      widget.onCommentsUpdated?.call(newComments);

      _activePopup?.remove();
      _activePopup = null;

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      StatusDialog.show(
        isSuccess: true,
        message: "Comment updated successfully.",
        autoCloseSeconds: 2,
      );
      return true;
    } else {
      Get.snackbar("Error", "Failed to update comment");
      return false;
    }
  }

  Future<void> _showEditCommentDialog(List<dynamic> comments) async {
    // Local controllers for each comment
    final controllers = {
      for (var c in comments)
        "${c['comment_id']}":
            TextEditingController(text: c['comment_text'] ?? "")
    };

    bool isSubmitting = false;

    await Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Center(
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    constraints: const BoxConstraints(maxWidth: 600),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: comments.map((c) {
                        final commentId = "${c['comment_id']}";

                        return StatefulBuilder(
                          builder: (context, localSetState) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: controllers[commentId],
                                  maxLength: 500,
                                  maxLines: null,
                                  minLines: 1,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                    hintText: "Enter Comment (max 500 chars)",
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    hintStyle: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      color: const Color(0xffB4B4B4),
                                    ),
                                  ),
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    color: Colors.black,
                                  ),
                                  autofocus: true,
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: isSubmitting
                                        ? null
                                        : () async {
                                            final text = controllers[commentId]!
                                                .text
                                                .trim();
                                            if (text.isEmpty) {
                                              Get.snackbar("Validation",
                                                  "Please enter a comment.");
                                              return;
                                            }
                                            if (text.length > 500) {
                                              Get.snackbar("Validation",
                                                  "Max 500 characters allowed.");
                                              return;
                                            }
                                            localSetState(
                                                () => isSubmitting = true);
                                            await _updateComment(c, text);
                                            localSetState(
                                                () => isSubmitting = false);
                                          },
                                    child: isSubmitting
                                        ? SizedBox(
                                            width: 24.w,
                                            height: 24.h,
                                            child:
                                                const CircularProgressIndicator(
                                                    strokeWidth: 2),
                                          )
                                        : SvgPicture.string(
                                            ''' <svg width="28" height="28" viewBox="0 0 30 30" fill="none" xmlns="http://www.w3.org/2000/svg"> <path d="M13.5 14.7L12.15 16.05C11.875 16.325 11.525 16.4625 11.1 16.4625C10.675 16.4625 10.325 16.325 10.05 16.05C9.775 15.775 9.6375 15.425 9.6375 15C9.6375 14.575 9.775 14.225 10.05 13.95L13.95 10.05C14.25 9.75001 14.6 9.60001 15 9.60001C15.4 9.60001 15.75 9.75001 16.05 10.05L19.95 13.95C20.225 14.225 20.3625 14.575 20.3625 15C20.3625 15.425 20.225 15.775 19.95 16.05C19.675 16.325 19.325 16.4625 18.9 16.4625C18.475 16.4625 18.125 16.325 17.85 16.05L16.5 14.7V19.5C16.5 19.925 16.356 20.281 16.068 20.568C15.78 20.855 15.424 20.999 15 21C14.576 21.001 14.22 20.857 13.932 20.568C13.644 20.279 13.5 19.923 13.5 19.5V14.7ZM15 9.53674e-06C12.925 9.53674e-06 10.975 0.394009 9.15 1.18201C7.325 1.97001 5.7375 3.03851 4.3875 4.38751C3.0375 5.73651 1.969 7.32401 1.182 9.15001C0.395002 10.976 0.0010019 12.926 1.89873e-06 15C-0.000998101 17.074 0.393002 19.024 1.182 20.85C1.971 22.676 3.0395 24.2635 4.3875 25.6125C5.7355 26.9615 7.323 28.03 9.15 28.818C10.977 29.606 12.927 30 15 30C17.073 30 19.023 29.606 20.85 28.818C22.677 28.03 24.2645 26.9615 25.6125 25.6125C26.9605 24.2635 28.0295 22.676 28.8195 20.85C29.6095 19.024 30.003 17.074 30 15C29.997 12.926 29.603 10.976 28.818 9.15001C28.033 7.32401 26.9645 5.73651 25.6125 4.38751C24.2605 3.03851 22.673 1.96951 20.85 1.18051C19.027 0.39151 17.077 -0.00199127 15 9.53674e-06ZM15 3.00001C18.35 3.00001 21.1875 4.16251 23.5125 6.48751C25.8375 8.81251 27 11.65 27 15C27 18.35 25.8375 21.1875 23.5125 23.5125C21.1875 25.8375 18.35 27 15 27C11.65 27 8.8125 25.8375 6.4875 23.5125C4.1625 21.1875 3 18.35 3 15C3 11.65 4.1625 8.81251 6.4875 6.48751C8.8125 4.16251 11.65 3.00001 15 3.00001Z" fill="#9F3CBB"/> </svg> ''',
                                            width: 28.r,
                                            height: 28.r,
                                          ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  // Close icon
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close,
                          size: 22, color: Colors.black87),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      barrierDismissible: true,
    );
  }

  void _showCenteredCommentPopup(List<dynamic> comments) {
    _activePopup?.remove();
    _activePopup = null;

    final overlay = Overlay.of(context);

    // Track which comment is in edit mode
    Map<String, bool> editing = {
      for (var c in comments) "${c['comment_id']}": false
    };

    // Text controllers per comment
    Map<String, TextEditingController> controllers = {
      for (var c in comments)
        "${c['comment_id']}":
            TextEditingController(text: c['comment_text'] ?? "")
    };

    final entry = OverlayEntry(
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      _activePopup?.remove();
                      _activePopup = null;
                    },
                    behavior: HitTestBehavior.translucent,
                    child: const SizedBox.expand(),
                  ),
                ),

                // Popup in center
                Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: widget.popupWidth,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: comments.map<Widget>((c) {
                          String formattedDate = c['created_at'] ?? '';
                          try {
                            final dt = DateTime.parse(c['created_at']);
                            final diff = DateTime.now().difference(dt);
                            if (diff.inDays >= 1) {
                              formattedDate =
                                  "${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago";
                            } else if (diff.inHours >= 1) {
                              formattedDate =
                                  "${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago";
                            } else if (diff.inMinutes >= 1) {
                              formattedDate =
                                  "${diff.inMinutes} min${diff.inMinutes > 1 ? 's' : ''} ago";
                            } else {
                              formattedDate = "just now";
                            }
                          } catch (_) {}

                          final teacherName = c['teacher_name'] ?? 'Unknown';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      teacherName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(c['comment_text'] ?? ''),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    overlay.insert(entry);
    _activePopup = entry;
  }

  void _showCommentPopup(Map comment) {
    final List<dynamic> overlapping = [comment]; // only one comment here
    if (widget.isGradeSubmitted) {
      _showCenteredCommentPopup(overlapping);
    } else {
      widget.onIconClick?.call(webHtmlSelectedText);

      _showEditCommentDialog(overlapping);
    }
  }

  @override
  void dispose() {
    _activePopup?.remove();
    _activePopup = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double containerPadding = 12.0;
    const double iconSize = 22.0;
    return Container(
      padding: const EdgeInsets.all(containerPadding),
      height: 360,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200)),
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // TextPainter to measure text
              final textPainter = TextPainter(
                text: TextSpan(
                  text: _fullPlainText,
                  style: const TextStyle(fontSize: 14.0, height: 1.4),
                ),
                textDirection: TextDirection.ltr,
                maxLines: null,
              )..layout(maxWidth: constraints.maxWidth - 40);

              final Map<double, int> lineIconCount = {};

              List<Widget> iconWidgets = [];

              for (int i = 0; i < _comments.length; i++) {
                final c = _comments[i];

                final int cs = (c['selection_start'] is int)
                    ? c['selection_start'] as int
                    : int.tryParse('${c['selection_start']}') ?? 0;
                final int ce = (c['selection_end'] is int)
                    ? c['selection_end'] as int
                    : int.tryParse('${c['selection_end']}') ?? 0;

                if (cs >= ce || cs >= _fullPlainText.length) continue;

                final boxes = textPainter.getBoxesForSelection(
                  TextSelection(baseOffset: cs, extentOffset: ce),
                );

                if (boxes.isEmpty) continue;

                final firstBox = boxes.first;
                final top = firstBox.bottom - iconSize / 2;
                final count = lineIconCount[top] ?? 0;
                lineIconCount[top] = count + 1;
                const spacing = 4.0;
                final left = constraints.maxWidth -
                    (iconSize + 8.0) -
                    (count * (iconSize + spacing));

                iconWidgets.add(
                  Positioned(
                    left: left,
                    top: top,
                    width: iconSize,
                    height: iconSize,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _showCommentPopup(c),
                        child: SvgPicture.asset(
                          "assets/icon/comment.svg",
                          width: iconSize,
                          height: iconSize,
                        ),
                      ),
                    ),
                  ),
                );
                // }
              }

              return Stack(
                key: _innerStackKey,
                children: [
                  IgnorePointer(
                    ignoring: widget.isGradeSubmitted,
                    child: MouseRegion(
                      cursor: widget.isGradeSubmitted
                          ? SystemMouseCursors.basic
                          : SystemMouseCursors.text,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 40),
                        child: Listener(
                          behavior: HitTestBehavior.translucent,
                          onPointerDown: (event) {
                            if (widget.isGradeSubmitted) return;

                            if (event.kind == PointerDeviceKind.mouse &&
                                event.buttons == kPrimaryMouseButton) {
                              widget.onTextClick?.call(event.position);
                            }
                          },
                          child: SelectableText.rich(
                            _textSpan,
                            showCursor: !widget.isGradeSubmitted,
                            cursorColor: Colors.blue,
                            enableInteractiveSelection:
                                !widget.isGradeSubmitted,
                            onSelectionChanged: (sel, cause) {
                              if (widget.isGradeSubmitted) return;
                              final start = sel.start;
                              final end = sel.end;
                              if (start >= 0 &&
                                  end > start &&
                                  end <= _fullPlainText.length) {
                                final selected =
                                    _fullPlainText.substring(start, end);
                                widget.onSelectionChanged
                                    .call(start, end, selected);
                                setState(() {
                                  webHtmlSelectedText = selected;
                                });
                              }
                            },
                            style: const TextStyle(fontSize: 14.0, height: 1.4),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Comment icons
                  ...iconWidgets,
                ],
              );
            },
          ),
        );
      }),
    );
  }
}
