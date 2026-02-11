import 'package:vantanceCA/images.dart';
import 'package:vantanceCA/views/apps/school/integrations/platforms.dart';

class LmsData {
  static final List<Map<String, String?>> platformsData = [
    {
      "title": Platforms.canvas,
      "platform": Platforms.canvas,
      "image": Images.canvas,
      "description": "Canvas -  Sync with Canvas to organize your classes, teachers, and students in one dashboard"
    },
    {
      "title": Platforms.schoology,
      "platform": Platforms.schoology,
      "image": Images.schoology,
      "description": "Schoology - Sync with Schoology to streamline your class, teacher, and student workflows"
    },
    {
      "title": Platforms.bulkUpload,
      "platform": "Excel",
      "image": Images.excel,
      "description": "Easily upload and manage records in bulk using CSV or Excel files"
    },
    {
      "title": "Blackboard",
      "platform": "Blackboard",
      "image": null,
      "description": "Coming Soon..."
    },
    {
      "title": "Moodle",
      "platform": "Moodle",
      "image": null,
      "description": "Coming Soon..."
    },
    {
      "title": "Brightspace",
      "platform": "Brightspace",
      "image": null,
      "description": "Coming Soon..."
    },
  ];
}