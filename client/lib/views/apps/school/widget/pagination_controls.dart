import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget with UIMixin {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  List<Widget> _buildPageButtons() {
    List<Widget> buttons = [];

    // Always show first page
    buttons.add(_pageButton(1));

    if (currentPage > 3) {
      buttons.add(const Text("..."));
    }

    // Show 2 pages before and after current page
    for (int i = currentPage - 1; i <= currentPage + 1; i++) {
      if (i > 1 && i < totalPages) {
        buttons.add(_pageButton(i));
      }
    }

    if (currentPage < totalPages - 2) {
      buttons.add(const Text("..."));
    }

    // Always show last page
    if (totalPages > 1) {
      buttons.add(_pageButton(totalPages));
    }

    return buttons;
  }

  Widget _pageButton(int page) {
    bool isActive = page == currentPage;
    return GestureDetector(
      onTap: () => onPageChanged(page),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? contentTheme.onPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          "$page",
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      {required String label,
      required IconData icon,
      required VoidCallback onTap,
      required bool active}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          if(label == "Prev")
            Icon(
              icon,
              color: active ? Colors.black : Colors.grey,
              size: 15,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: MyText(
              label,
              color: active ? Colors.black : Colors.grey,
            ),
          ),
          if(label == "Next")
            Icon(
              icon,
              color: active ? Colors.black : Colors.grey,
              size: 15,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(
          label: "Prev",
          icon: Icons.arrow_back,
          onTap: currentPage > 1 ? () => onPageChanged(currentPage - 1) : () {},
          active: currentPage > 1, // active only if clickable
        ),
        const SizedBox(width: 5),
        ..._buildPageButtons(), // we’ll also make these use _buildButton
        const SizedBox(width: 5),
        _buildButton(
          label: "Next",
          icon: Icons.arrow_forward,
          onTap: currentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : () {},
          active: currentPage < totalPages,
        ),
      ],
    );
  }
}
