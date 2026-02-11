import 'package:flutter/material.dart';

import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/views/layouts/layout.dart';

class DocsSite extends StatefulWidget {
  const DocsSite({super.key});

  @override
  State<DocsSite> createState() => _DocsSiteState();
}

class _DocsSiteState extends State<DocsSite>
    with SingleTickerProviderStateMixin, UIMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Docs Site",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text("1. Student"),
          Text("2. Teacher"),
          Text("3. School Admin"),
          Text("4. Platform Admin"),
        ],
      ),
    );
  }
}
