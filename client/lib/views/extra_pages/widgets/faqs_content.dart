import 'package:vantanceCA/helpers/constant/app_constant.dart';
import 'package:vantanceCA/helpers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:vantanceCA/helpers/network/api_service.dart';

class FAQPageContent extends StatefulWidget {
  const FAQPageContent({super.key});

  @override
  State<FAQPageContent> createState() => _FAQPageContentState();
}

class _FAQPageContentState extends State<FAQPageContent> {
  Map<String, List<Map<String, String>>> categorizedFaqs = {};
  String? selectedCategory;
  int? expandedIndex;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchFaqs();
  }

  String toTitleCaseWithSpaces(String text) {
    return text.split('_').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  // Future<void> fetchFaqs() async {
  //   setState(() {
  //     loading = true;
  //   });

  //    final apiUrl = API.faqUrl;

  //   try {
  //     final userRole = RoleUtils.currentRole?.toLowerCase() ?? 'student';
  //     final dio = Dio();
  //     final response = await dio.post(apiUrl, data: {'user-type': userRole});
  //     if (response.statusCode == 200) {
  //       final jsonResponse = response.data;

  //       final Map<String, List<Map<String, String>>> newCategorizedFaqs = {};

  //       if (jsonResponse['set'] != null && jsonResponse['set'] is List) {
  //         for (var item in jsonResponse['set']) {
  //           final values = item['values'] as List<dynamic>? ?? [];

  //           final question = getValue(values, 'question');
  //           final solution = getValue(values, 'answer');
  //           final rawCategory = getValue(values, 'category');
  //           final category = rawCategory.isNotEmpty
  //               ? toTitleCaseWithSpaces(rawCategory)
  //               : 'Others';

  //           if (!newCategorizedFaqs.containsKey(category)) {
  //             newCategorizedFaqs[category] = [];
  //           }

  //           newCategorizedFaqs[category]!
  //               .add({'question': question, 'solution': solution});
  //         }
  //       }

  //       setState(() {
  //         categorizedFaqs = newCategorizedFaqs;
  //         final categories = categorizedFaqs.keys.toList();
  //         if (categories.isNotEmpty) {
  //           selectedCategory = categories[0];
  //         } else {
  //           selectedCategory = null;
  //         }
  //         expandedIndex = null;
  //         loading = false;
  //       });
  //     } else {
  //       setState(() {
  //         loading = false;
  //       });
  //       debugPrint('Error fetching FAQs: Status code ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     setState(() {
  //       loading = false;
  //     });
  //     debugPrint('Error fetching FAQs: $e');
  //   }
  // }

  Future<void> fetchFaqs() async {
    setState(() {
      loading = true;
    });

    // Base URL from env or API config
    final baseUrl = API.faqUrl;

    // Role mapper: "learner" → "student"
    String mapRoleForApi(String? role) {
      if (role == null) return "student";

      final lower = role.toLowerCase();

      // learner → student
      if (lower == "learner") return "student";

      // institute_admin → institute admin
      if (lower == "institute_admin") return "institute admin";

      return lower;
    }

    final userRole = mapRoleForApi(RoleUtils.currentRole);
    try {
      final response = await APIService.get(
        path: "/faq/get-faqs",
        params: {
          "user-type": userRole,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonResponse = response.data;

        final Map<String, List<Map<String, String>>> newCategorizedFaqs = {};

        if (jsonResponse['faqs'] != null && jsonResponse['faqs'] is List) {
          for (var item in jsonResponse['faqs']) {
            final question = item['question'] ?? '';
            final solution = item['answer'] ?? '';
            final rawCategory = item['category'] ?? 'Others';

            final category = rawCategory.isNotEmpty
                ? toTitleCaseWithSpaces(rawCategory)
                : 'Others';

            newCategorizedFaqs.putIfAbsent(category, () => []);

            newCategorizedFaqs[category]!.add({
              'question': question,
              'solution': solution,
            });
          }
        }
        if (!mounted) return;

        setState(() {
          categorizedFaqs = newCategorizedFaqs;
          final categories = categorizedFaqs.keys.toList();
          if (categories.isNotEmpty) {
            selectedCategory = categories[0];
          } else {
            selectedCategory = null;
          }
          expandedIndex = null;
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
        debugPrint('Error fetching FAQs: Status code ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      debugPrint('Error fetching FAQs: $e');
    }
  }

  // Extract value by name from values array
  String getValue(List<dynamic> values, String name) {
    final found = values.firstWhere(
      (v) => v['name'] == name,
      orElse: () => null,
    );
    if (found != null &&
        found is Map<String, dynamic> &&
        found['value'] != null) {
      return found['value'].toString();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final categories = categorizedFaqs.keys.toList();
    final faqs =
        selectedCategory != null ? categorizedFaqs[selectedCategory!]! : [];

    return Scaffold(
      body: SizedBox.expand(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(height: 20),
                // Main container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      // BoxShadow(
                      //   color: Color.fromARGB(40, 44, 62, 80),
                      //   blurRadius: 24,
                      //   spreadRadius: 1,
                      //   offset: Offset(0, 6),
                      // ),
                    ],
                  ),
                  child: loading
                      ? _buildLoader()
                      : Column(
                          children: [
                            // Category Tabs - Center aligned
                            Center(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 10,
                                runSpacing: 10,
                                children: categories.map((category) {
                                  final isSelected =
                                      category == selectedCategory;
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(30),
                                    onTap: () {
                                      setState(() {
                                        selectedCategory = category;
                                        expandedIndex = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        gradient: isSelected
                                            ? const LinearGradient(
                                                colors: [
                                                  Color(0xFFEEECFF),
                                                  Color(0xFFEEECFF),
                                                  Color(0xFFDBEBFF),
                                                ],
                                              )
                                            : null,
                                        color: isSelected
                                            ? null
                                            : Colors.transparent,
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.08),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Text(
                                        category,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 25),
                            // FAQs list
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: faqs.length,
                              itemBuilder: (context, index) {
                                final faq = faqs[index];
                                final isExpanded = index == expandedIndex;
                                return _buildFAQItem(faq, index, isExpanded);
                              },
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: Color.fromRGBO(159, 60, 187, 1),
            ),
          ),
          SizedBox(height: 10),
          Text('Loading FAQs...',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFAQItem(Map<String, String> faq, int index, bool isExpanded) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E1E1), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33484456),
            blurRadius: 30,
            spreadRadius: 0,
            offset: Offset(5, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              expandedIndex = isExpanded ? null : index;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: isExpanded
                      ? const BorderRadius.vertical(top: Radius.circular(12))
                      : BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        faq['question'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(159, 60, 187, 1),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color.fromRGBO(159, 60, 187, 1),
                    ),
                  ],
                ),
              ),
              if (isExpanded)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFEEECFF),
                        Color(0xFFEEECFF),
                        Color(0xFFDBEBFF),
                      ],
                      stops: [0.0302, 0.509, 0.9749],
                      begin: Alignment(-1, -0.3),
                      end: Alignment(1, 1),
                    ),
                  ),
                  child: Html(
                    data: faq['solution'] ?? '',
                    style: {
                      'p': Style(margin: Margins.only(bottom: 10)),
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
