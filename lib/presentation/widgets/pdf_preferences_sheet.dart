import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/vintage_theme.dart';
import '../bloc/pdf_reader_bloc.dart';
import '../bloc/pdf_reader_event.dart';
import '../bloc/pdf_reader_state.dart';

class PdfPreferencesSheet extends StatelessWidget {
  final PdfReaderBloc bloc;

  const PdfPreferencesSheet({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PdfReaderBloc, PdfReaderState>(
      bloc: bloc,
      builder: (context, state) {
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
                    icon: const Icon(
                      Icons.close,
                      color: VintageTheme.vintageGold,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sepia Toggle
              SwitchListTile(
                activeThumbColor: VintageTheme.vintageGold,
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

              if (state.isSepiaModeEnabled) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'درجة اللون:',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Expanded(
                      child: Slider(
                        value: state.sepiaWeight,
                        min: 0.1,
                        max: 1.0,
                        activeColor: VintageTheme.vintageGold,
                        inactiveColor: Colors.white24,
                        onChanged: (val) =>
                            bloc.add(UpdateSepiaWeightEvent(val)),
                      ),
                    ),
                  ],
                ),
              ],

              const Divider(color: VintageTheme.inkFaded),

              // Edge Navigation Toggle
              SwitchListTile(
                activeThumbColor: VintageTheme.vintageGold,
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

              if (state.isNavigationZonesEnabled) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'مساحة الأزرار:',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Expanded(
                      child: Slider(
                        value: state.navigationZonesWidth,
                        min: 0.05,
                        max: 0.4,
                        activeColor: VintageTheme.vintageGold,
                        inactiveColor: Colors.white24,
                        onChanged: (val) =>
                            bloc.add(UpdateNavigationZonesWidthEvent(val)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
