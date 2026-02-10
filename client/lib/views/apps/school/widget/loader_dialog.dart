import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoaderDialog extends StatelessWidget {
  final String title;
  final Future<void> terminatingFuture;
  final VoidCallback? onSuccess;

  const LoaderDialog({
    super.key,
    required this.title,
    required this.terminatingFuture,
    this.onSuccess
  });

  @override
  Widget build(BuildContext context) {
    terminatingFuture.then((_) {
      Navigator.of(context).pop();
      if (onSuccess != null) onSuccess!();
    }).catchError((_) {
      Navigator.of(context).pop();
    });

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      content: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.staggeredDotsWave(
              color: const Color(0xff004AAD),
              size: 50,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
