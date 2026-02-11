import 'package:vantanceCA/helpers/theme/admin_theme.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class StudentHtmlWidget extends StatefulWidget {
  final ContentTheme contentTheme;
  final HtmlEditorController htmlEditorController;
  final Function(String)
      onZoomChanged; // Callback to notify parent of zoom change

  const StudentHtmlWidget({
    super.key,
    required this.contentTheme,
    required this.htmlEditorController,
    required this.onZoomChanged,
  });

  @override
  State<StudentHtmlWidget> createState() => _StudentHtmlWidgetState();
}

class _StudentHtmlWidgetState extends State<StudentHtmlWidget> {
  int textSize = 2;
  String selectedValue = "100%";
  String selectedFontValue = "Medium";

  final List<String> zoomLevels = [
    'Fit',
    '50%',
    '75%',
    '90%',
    '100%',
  ];

  final List<String> fontSizeList = ['Small', 'Medium', 'Large'];

  int selectedFontSize = 12;

  final Map<int, int> fontSizeMap = {
    8: 1, // xx-small
    10: 2, // x-small
    12: 3, // small
    14: 4, // medium
    18: 5, // large
    24: 6, // x-large
    36: 7, // xx-large
  };
  Color selectedColor = Colors.black;
  Color selectedBackgroundColor = Colors.white;
  List<String> textColorList = [
    '0xff000000', // Black
    '0xff5F6368', // Gray
    '0xff80868B', // Light Gray
    '0xffFFFFFF', // White
    '0xffD93025', // Red
    '0xffF9AB00', // Orange
    '0xffFDD663', // Yellow
    '0xff188038', // Green
    '0xff137333', // Teal
    '0xff1A73E8', // Blue
    '0xff4285F4', // Light Blue
    '0xff9333EA', // Purple
    '0xffE91E63', // Pink
    '0xff795548', // Brown
  ];
  List<String> googleDocsHighlightColors = [
    'transparent', // None
    '#FFF475', // Yellow
    '#CCFF90', // Green
    '#A7FFEB', // Cyan
    '#CBF0F8', // Light Blue
    '#D7AEFB', // Light Purple
    '#F28B82', // Light Red
    '#FBBC04', // Orange
    '#E8EAED', // Gray
  ];
  final List<Color> colorOptions = [
    Colors.black,
    Colors.grey[800]!,
    Colors.grey,
    Colors.grey[400]!,
    Colors.grey[200]!,
    Colors.white,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.cyan,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.red[100]!,
    Colors.orange[100]!,
    Colors.yellow[100]!,
    Colors.green[100]!,
    Colors.cyan[100]!,
    Colors.blue[100]!,
    Colors.purple[100]!,
    Colors.pink[100]!,
    Colors.red[200]!,
    Colors.orange[200]!,
    Colors.yellow[200]!,
    Colors.green[200]!,
    Colors.cyan[200]!,
    Colors.blue[200]!,
    Colors.purple[200]!,
    Colors.pink[200]!,
    Colors.red[300]!,
    Colors.orange[300]!,
    Colors.yellow[300]!,
    Colors.green[300]!,
    Colors.cyan[300]!,
    Colors.blue[300]!,
    Colors.purple[300]!,
    Colors.pink[300]!,
  ];

  bool isColorOpen = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 35.w, left: 20.w),
      padding: EdgeInsets.only(top: 8.h, left: 20.w, bottom: 8.h, right: 20.w),
      decoration: BoxDecoration(
        border: Border.all(color: widget.contentTheme.kD9D9D9),
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xffEEECFF),
            Color(0xffEEECFF),
            Color(0xffDBEBFF),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: widget.contentTheme.kFEFDFF,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: widget.contentTheme.kD9D9D9),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    widget.htmlEditorController.execCommand('undo');
                  },
                  child: Image.asset(
                    Images.backEditorArrow,
                    width: 18.w,
                    height: 18.h,
                  ),
                ),
                MySpacing.width(10),
                InkWell(
                  onTap: () {
                    widget.htmlEditorController.execCommand('redo');
                  },
                  child: Image.asset(
                    Images.rightEditorArrow,
                    width: 18.w,
                    height: 18.h,
                  ),
                ),
                MySpacing.width(15),
                PopupMenuButton<String>(
                  initialValue: selectedValue,
                  onSelected: (value) {
                    setState(() {
                      selectedValue = value;
                    });
                    widget.onZoomChanged(value);
                  },
                  itemBuilder: (context) {
                    return zoomLevels.map((value) {
                      return PopupMenuItem<String>(
                        value: value,
                        child: PointerInterceptor(
                          child: SizedBox(
                            width: 100,
                            child: Text(
                              value,
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList();
                  },
                  child: Container(
                    width: 100,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: widget.contentTheme.kFEFDFF,
                      // borderRadius: BorderRadius.circular(10.r),
                      // border: Border.all(color: widget.contentTheme.kD9D9D9),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedValue,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down_outlined,
                          size: 20.dm,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: widget.contentTheme.kFEFDFF,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: widget.contentTheme.kD9D9D9),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: selectPreviousFontSize,
                  child: Text(
                    '-',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
                MySpacing.width(10),
                PopupMenuButton<int>(
                  onSelected: (value) {
                    updateFontSize(value);
                  },
                  itemBuilder: (context) => fontSizeMap.keys.map((size) {
                    return PopupMenuItem<int>(
                      value: size,
                      child: PointerInterceptor(
                        child: Text(
                          size.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  child: Container(
                    width: 48,
                    alignment: Alignment.center,
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                    child: Text(
                      selectedFontSize.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                MySpacing.width(10),
                InkWell(
                  onTap: selectNextFontSize,
                  child: Text(
                    '+',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          /* Container(
            margin: EdgeInsets.symmetric(horizontal: 10.w),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: widget.contentTheme.kFEFDFF,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: widget.contentTheme.kD9D9D9),
            ),
            child: PopupMenuButton<String>(
              initialValue: selectedFontValue,
              onSelected: (value) async {
                setState(() {
                  selectedFontValue = value;
                });
                widget.htmlEditorController.execCommand(
                  'fontSize',
                  argument: selectedFontValue == "Small"
                      ? "2"
                      : selectedFontValue == "Medium"
                          ? "4"
                          : selectedFontValue == "Large"
                              ? "5"
                              : selectedFontValue == "Extra Large"
                                  ? "7"
                                  : "2",
                );
              },
              offset: Offset(0, 0),
              itemBuilder: (context) {
                return fontSizeList.map((value) {
                  return PopupMenuItem<String>(
                    value: value,
                    child: PointerInterceptor(
                      child: Text(
                        value,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedFontValue,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down_outlined,
                      size: 20.dm,
                      color: widget.contentTheme.k142228,
                    ),
                  ],
                ),
              ),
            ),
          ),*/

          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7),
            decoration: BoxDecoration(
              color: widget.contentTheme.kFEFDFF,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: widget.contentTheme.kD9D9D9),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    widget.htmlEditorController.execCommand('bold');
                  },
                  child: Text(
                    'B',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
                MySpacing.width(10),
                InkWell(
                  onTap: () {
                    widget.htmlEditorController.execCommand('italic');
                  },
                  child: Image.asset(
                    Images.italic,
                    width: 16.w,
                    height: 17.h,
                  ),
                ),
                MySpacing.width(10),
                InkWell(
                  onTap: () {
                    widget.htmlEditorController.execCommand('underline');
                  },
                  child: Image.asset(
                    Images.underlined,
                    width: 18.w,
                    height: 17.h,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) {
                  return AlertDialog(
                    alignment: Alignment.topCenter,
                    insetPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 25),
                    content: SizedBox(
                      width: MySpacing.fullWidth(context) * 0.15,
                      height: MySpacing.fullHeight(context) * 0.20,
                      child: GridView.count(
                        crossAxisCount: 8,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 10,
                        children: colorOptions.map((color) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedColor = color;
                                widget.htmlEditorController.execCommand(
                                  'foreColor',
                                  argument:
                                      "#${color.value.toRadixString(16).padLeft(8, '0').substring(2, 8)}",
                                );
                              });
                              Get.back();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                              child: selectedColor == color
                                  ? Icon(Icons.check, size: 20)
                                  : SizedBox(),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ).paddingOnly(top: 30);
                },
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: widget.contentTheme.kFEFDFF,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: widget.contentTheme.kD9D9D9),
              ),
              child: Row(
                children: [
                  Image.asset(
                    Images.paintPalette,
                    width: 20.w,
                    height: 18.h,
                  ),
                  MySpacing.width(5),
                  Text(
                    'Color',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    alignment: Alignment.topCenter,
                    insetPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 25),
                    content: SizedBox(
                      width: MySpacing.fullWidth(context) * 0.15,
                      height: MySpacing.fullHeight(context) * 0.20,
                      child: GridView.count(
                        crossAxisCount: 8,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 10,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: colorOptions.map((color) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedBackgroundColor = color;
                              });
                              widget.htmlEditorController.execCommand(
                                'hiliteColor',
                                argument:
                                    "#${color.value.toRadixString(16).padLeft(8, '0').substring(2, 8)}",
                              );
                              Get.back();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                              child: selectedBackgroundColor == color
                                  ? Icon(Icons.check, size: 20)
                                  : SizedBox(),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ).paddingOnly(top: 30);
                },
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7),
              decoration: BoxDecoration(
                color: widget.contentTheme.kFEFDFF,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: widget.contentTheme.kD9D9D9),
              ),
              child: Row(
                children: [
                  Image.asset(
                    Images.highlightedColor,
                    width: 20.w,
                    height: 18.h,
                  ),
                  MySpacing.width(5),
                  Text(
                    'Color',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9),
            decoration: BoxDecoration(
              color: widget.contentTheme.kFEFDFF,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: widget.contentTheme.kD9D9D9),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    widget.htmlEditorController
                        .execCommand('insertUnorderedList');
                  },
                  child: Image.asset(
                    Images.bulletPoint,
                    width: 22.w,
                    height: 20.h,
                  ),
                ),
                InkWell(
                  onTap: () {
                    widget.htmlEditorController
                        .execCommand('insertOrderedList');
                  },
                  child: Image.asset(
                    Images.numberedList,
                    width: 22.w,
                    height: 20.h,
                  ).paddingSymmetric(horizontal: 10),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8),
            decoration: BoxDecoration(
              color: widget.contentTheme.kFEFDFF,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: widget.contentTheme.kD9D9D9),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    widget.htmlEditorController.execCommand('justifyLeft');
                  },
                  child: Image.asset(
                    Images.rightAligned,
                    width: 22.w,
                    height: 24.h,
                  ),
                ),
                InkWell(
                  onTap: () {
                    widget.htmlEditorController.execCommand('justifyCenter');
                  },
                  child: Image.asset(
                    Images.centered,
                    width: 22.w,
                    height: 24.h,
                  ).paddingSymmetric(horizontal: 10.w),
                ),
                InkWell(
                  onTap: () {
                    widget.htmlEditorController.execCommand('justifyRight');
                  },
                  child: Image.asset(
                    Images.leftAligned,
                    width: 22.w,
                    height: 24.h,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7),
            decoration: BoxDecoration(
              color: widget.contentTheme.kFEFDFF,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: widget.contentTheme.kD9D9D9),
            ),
            child: Row(
              children: [
                PopupMenuButton(
                  onSelected: (value) async {
                    //remove internal annotation
                    widget.htmlEditorController.changeLineHeight(value);
                  },
                  itemBuilder: (BuildContext context) {
                    return ["0.8", "1.0", "1.2", "1.4", "1.6", "1.8", "2"]
                        .map((behavior) {
                      return PopupMenuItem(
                        value: behavior.toString(),
                        height: 32,
                        child: PointerInterceptor(
                          child: MyText.bodySmall(
                            behavior,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: widget.contentTheme.k142228,
                            ),
                          ),
                        ),
                      );
                    }).toList();
                  },
                  color: widget.contentTheme.background,
                  child: Image.asset(
                    Images.spacing,
                    width: 22.w,
                    height: 24.h,
                  ),
                ),
                InkWell(
                  onTap: () {
                    widget.htmlEditorController.execCommand('outdent');
                  },
                  child: Image.asset(
                    Images.indentLeft,
                    width: 22.w,
                    height: 24.h,
                  ).paddingSymmetric(horizontal: 10.w),
                ),
                InkWell(
                  onTap: () {
                    widget.htmlEditorController.execCommand('indent');
                  },
                  child: Image.asset(
                    Images.indentRight,
                    width: 22.w,
                    height: 24.h,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getFontSize(int size) {
    return "";
  }

  void updateFontSize(int displaySize) {
    if (fontSizeMap.containsKey(displaySize)) {
      setState(() {
        selectedFontSize = displaySize;
        widget.htmlEditorController.execCommand(
          'fontSize',
          argument: fontSizeMap[displaySize].toString(),
        );
      });
    }
  }

  void selectNextFontSize() {
    final fontSizes = fontSizeMap.keys.toList();
    final currentIndex = fontSizes.indexOf(selectedFontSize);
    if (currentIndex < fontSizes.length - 1) {
      updateFontSize(fontSizes[currentIndex + 1]);
    }
  }

  void selectPreviousFontSize() {
    final fontSizes = fontSizeMap.keys.toList();
    final currentIndex = fontSizes.indexOf(selectedFontSize);
    if (currentIndex > 0) {
      updateFontSize(fontSizes[currentIndex - 1]);
    }
  }
}
