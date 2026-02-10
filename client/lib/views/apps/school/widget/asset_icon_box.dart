import 'package:flutter/material.dart';

class AssetIconBox extends StatelessWidget {
  final String iconPath;
  const AssetIconBox({super.key, required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xffF1F4FF),
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Image.asset(
          iconPath,
          height: 28,
          width: 28,
          color: Colors.black
        ),
      ),
    );
  }
}
