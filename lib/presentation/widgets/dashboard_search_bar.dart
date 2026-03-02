import 'package:flutter/material.dart';
import '../../core/theme/vintage_theme.dart';

class DashboardSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const DashboardSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 21),
        decoration: InputDecoration(
          hintText: 'بحث في المكتبة...',
          hintStyle: const TextStyle(color: Colors.white70, fontSize: 21),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          filled: true,
          fillColor: VintageTheme.inkFaded,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: VintageTheme.deeperParchment,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: VintageTheme.deeperParchment,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: VintageTheme.vintageGold,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
