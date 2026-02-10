import 'package:flutter/material.dart';

class AssetIcon extends StatelessWidget {
  final String icon;
  final Color? color;
  final double size;
  const AssetIcon({super.key, required this.icon, this.color = Colors.black, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      icon,
      height: size,
      width: size,
      color: color,
    );
  }
}
