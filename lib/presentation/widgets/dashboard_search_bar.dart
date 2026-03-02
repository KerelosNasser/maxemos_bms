import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/vintage_theme.dart';
import '../bloc/dashboard_cubit.dart';

class DashboardSearchBar extends StatefulWidget {
  const DashboardSearchBar({super.key});

  @override
  State<DashboardSearchBar> createState() => _DashboardSearchBarState();
}

class _DashboardSearchBarState extends State<DashboardSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _controller,
        onChanged: (val) {
          context.read<DashboardCubit>().searchChanged(val);
        },
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
