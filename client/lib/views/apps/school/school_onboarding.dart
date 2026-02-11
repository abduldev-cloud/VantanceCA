// import 'package:vantanceCA/controller/error_pages/onboarding_controller.dart';
// import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
// import 'package:vantanceCA/helpers/widgets/app_button.dart';
// import 'package:vantanceCA/helpers/widgets/my_responsiv.dart';
// import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
// import 'package:vantanceCA/helpers/widgets/my_text.dart';
// import 'package:vantanceCA/images.dart';
// import 'package:vantanceCA/widgets/custom_textfield.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';

// class SchoolOnboardingPage extends StatefulWidget {
//   const SchoolOnboardingPage({super.key});

//   @override
//   State<SchoolOnboardingPage> createState() => _SchoolOnboardingPageState();
// }

// class _SchoolOnboardingPageState extends State<SchoolOnboardingPage>
//     with SingleTickerProviderStateMixin, UIMixin {
//   late SchoolOnboardingController controller;
//   @override
//   void initState() {
//     super.initState();
//     controller = Get.put(SchoolOnboardingController());

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final inviteCode = Get.parameters['invite_code'];
//       if (inviteCode == null) {
//         Get.snackbar("Error", "Invite code is required for onboarding");
//         Get.offAllNamed('/auth/login');
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: MyResponsive(
//         builder: (BuildContext context, _, screenMT) => screenMT.isMobile ||
//                 screenMT.isTablet
//             ? Center(
//                 child: MyText.labelMedium(
//                   "Mobile view is not supportable",
//                   style: GoogleFonts.inter(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 20,
//                   ),
//                 ),
//               )
//             : GetBuilder<SchoolOnboardingController>(
//                 init: controller,
//                 builder: (controller) {
//                   final schoolData =
//                       controller.partialSchoolModel.value?.toMap() ?? {};

//                   return Align(
//                     child: AutofillGroup(
//                       child: Form(
//                         key: controller.formKey,
//                         child: Container(
//                           width: MySpacing.fullWidth(context) * 0.70,
//                           padding: MySpacing.symmetric(
//                               horizontal: MySpacing.fullWidth(context) * 0.07,
//                               vertical: MySpacing.fullHeight(context) * 0.05),
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(25),
//                               color: contentTheme.background,
//                               gradient: LinearGradient(
//                                   begin: Alignment.centerLeft,
//                                   end: Alignment.centerRight,
//                                   colors: [
//                                     Color(0xffEEECFF),
//                                     Color(0xffEEECFF),
//                                     Color(0xffDBEBFF),
//                                   ])),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               SizedBox(
//                                 width: MySpacing.fullWidth(context) * 0.24,
//                                 child: SingleChildScrollView(
//                                   child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Align(
//                                           child: MyText.bodyMedium(
//                                             "ONBOARDING",
//                                             style: GoogleFonts.inter(
//                                                 fontSize: 30.sp,
//                                                 fontWeight: FontWeight.w500,
//                                                 letterSpacing: 1.02,
//                                                 color: contentTheme.k030303),
//                                           ),
//                                         ),
//                                         MySpacing.height(7),
//                                         Align(
//                                           child: MyText.bodySmall(
//                                             "Welcome to the School Onboarding",
//                                             style: GoogleFonts.inter(
//                                                 fontSize: 12.sp,
//                                                 fontWeight: FontWeight.w400,
//                                                 color: contentTheme.k636364),
//                                           ),
//                                         ),
//                                         35.verticalSpace,
//                                         MyText.bodyMedium(
//                                           "School Details",
//                                           style: GoogleFonts.inter(
//                                             fontSize: 15.sp,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                         15.verticalSpace,
//                                         if (controller.isLoading.value)
//                                           Center(
//                                             child: CircularProgressIndicator(),
//                                           )
//                                         else if (schoolData.isEmpty)
//                                           MyText.bodySmall(
//                                             "No school details available",
//                                             style: GoogleFonts.inter(
//                                               fontSize: 12.sp,
//                                               fontWeight: FontWeight.w400,
//                                               color: contentTheme.k636364,
//                                             ),
//                                           )
//                                         else
//                                           ListView.builder(
//                                             shrinkWrap: true,
//                                             physics:
//                                                 NeverScrollableScrollPhysics(),
//                                             itemCount: schoolData.length,
//                                             itemBuilder: (context, index) {
//                                               final key = schoolData.keys
//                                                   .elementAt(index);
//                                               final value = schoolData[key]!;
//                                               return Padding(
//                                                 padding: EdgeInsets.symmetric(
//                                                     vertical: 6),
//                                                 child: Row(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     Expanded(
//                                                         flex: 1,
//                                                         child: MyText.bodySmall(
//                                                           "$key:",
//                                                           style:
//                                                               GoogleFonts.inter(
//                                                             fontSize: 12.sp,
//                                                             fontWeight:
//                                                                 FontWeight.w500,
//                                                             color: contentTheme
//                                                                 .k636364,
//                                                           ),
//                                                         )),
//                                                     10.horizontalSpace,
//                                                     Expanded(
//                                                       flex: 1,
//                                                       child: MyText.bodySmall(
//                                                         value,
//                                                         style:
//                                                             GoogleFonts.inter(
//                                                           fontSize: 12.sp,
//                                                           fontWeight:
//                                                               FontWeight.w500,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               );
//                                             },
//                                           ),
//                                         20.verticalSpace,
//                                         MyText.bodyMedium(
//                                           "Personal Details",
//                                           style: GoogleFonts.inter(
//                                             fontSize: 15.sp,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                         20.verticalSpace,
//                                         SizedBox(
//                                           width: MySpacing.fullWidth(context) *
//                                               0.20,
//                                           child: TextInputFields(
//                                             validator: (value) {
//                                               if (value!.isEmpty) {
//                                                 return "Please enter first name";
//                                               }
//                                               return null;
//                                             },
//                                             controller: controller.firstName,
//                                             name: "First Name",
//                                             filled: true,
//                                             hintText: "Enter your first name",
//                                           ),
//                                         ),
//                                         20.verticalSpace,
//                                         SizedBox(
//                                           width: MySpacing.fullWidth(context) *
//                                               0.20,
//                                           child: TextInputFields(
//                                             validator: (value) {
//                                               if (value!.isEmpty) {
//                                                 return "Please enter last name";
//                                               }
//                                               return null;
//                                             },
//                                             controller: controller.lastName,
//                                             name: "Last Name",
//                                             filled: true,
//                                             hintText: "Enter your last name",
//                                           ),
//                                         ),
//                                         20.verticalSpace,
//                                         SizedBox(
//                                           width: MySpacing.fullWidth(context) *
//                                               0.20,
//                                           child: TextInputFields(
//                                             autofillHints: const [
//                                               AutofillHints.password
//                                             ],
//                                             validator: (value) {
//                                               if (value!.isEmpty) {
//                                                 return "Please enter password";
//                                               }
//                                               return null;
//                                             },
//                                             controller: controller.password,
//                                             name: "Password",
//                                             suffixIconConstraints:
//                                                 BoxConstraints(
//                                                     maxHeight: 30.h,
//                                                     maxWidth: 30.w),
//                                             suffixWidget: InkWell(
//                                                 onTap: () {
//                                                   controller
//                                                       .onChangeShowPassword();
//                                                 },
//                                                 child: controller.showPassword
//                                                     ? Icon(Icons.remove_red_eye_rounded,
//                                                             color: contentTheme
//                                                                 .k181818)
//                                                         .paddingOnly(
//                                                             right: 20.w)
//                                                     : Icon(Icons.remove_red_eye_outlined,
//                                                             color: contentTheme
//                                                                 .k181818)
//                                                         .paddingOnly(
//                                                             right: 20.w)),
//                                             filled: true,
//                                             obSecureText:
//                                                 controller.showPassword,
//                                             hintText: "**********",
//                                           ),
//                                         ),
//                                         25.verticalSpace,
//                                         Obx(() =>
//                                             controller.isAcceptLoading.value
//                                                 ? SizedBox(
//                                                     height: 50.h,
//                                                     child: Center(
//                                                       child:
//                                                           CircularProgressIndicator(),
//                                                     ),
//                                                   )
//                                                 : SizedBox(
//                                                     width: MySpacing.fullWidth(
//                                                             context) *
//                                                         0.20,
//                                                     child: AppButton(
//                                                         title:
//                                                             "Complete Onboarding",
//                                                         onTap: () async {
//                                                           if (controller.formKey
//                                                               .currentState!
//                                                               .validate()) {
//                                                             controller
//                                                                 .isAcceptLoading(
//                                                                     true);
//                                                             try {
//                                                               await controller
//                                                                   .acceptInvite();
//                                                             } catch (e) {
//                                                               Get.snackbar(
//                                                                 "Login Failed",
//                                                                 e.toString(),
//                                                               );
//                                                             } finally {
//                                                               controller
//                                                                   .isAcceptLoading(
//                                                                       false);
//                                                             }
//                                                           }
//                                                         }),
//                                                   )),
//                                       ]),
//                                 ),
//                               ),
//                               Spacer(),
//                               Image.asset(
//                                 Images.elephant,
//                                 fit: BoxFit.cover,
//                                 height: MySpacing.fullWidth(context) * 0.20,
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 }),
//       ),
//     );
//   }
// }
