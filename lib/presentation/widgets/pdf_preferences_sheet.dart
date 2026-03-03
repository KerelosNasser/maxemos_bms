import 'package:flutter/material.dart';
import '../../core/theme/vintage_theme.dart';
import '../bloc/pdf_reader_bloc.dart';
import '../bloc/pdf_reader_event.dart';
import '../bloc/pdf_reader_state.dart';

class PdfPreferencesSheet extends StatelessWidget {
  final PdfReaderBloc bloc;
  final PdfReaderState state;

  const PdfPreferencesSheet({
    super.key,
    required this.bloc,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: VintageTheme.inkDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'خيارات القراءة',
                style: TextStyle(
                  color: VintageTheme.vintageGold,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: VintageTheme.vintageGold),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sepia Toggle
          SwitchListTile(
            activeColor: VintageTheme.vintageGold,
            activeTrackColor: VintageTheme.vintageGold.withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            title: const Text(
              'وضع راحة العين (اللون الدافئ)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'تغيير لون الصفحات لتقليل إجهاد العين.',
              style: TextStyle(color: Colors.white70),
            ),
            value: state.isSepiaModeEnabled,
            onChanged: (_) => bloc.add(ToggleSepiaModeEvent()),
            contentPadding: EdgeInsets.zero,
          ),

          const Divider(color: VintageTheme.inkFaded),

          // Edge Navigation Toggle
          SwitchListTile(
            activeColor: VintageTheme.vintageGold,
            activeTrackColor: VintageTheme.vintageGold.withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            title: const Text(
              'أزرار التنقل الجانبية',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'تفعيل مناطق خفية على جانبي الشاشة للانتقال السريع.',
              style: TextStyle(color: Colors.white70),
            ),
            value: state.isNavigationZonesEnabled,
            onChanged: (_) => bloc.add(ToggleNavigationZonesEvent()),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
