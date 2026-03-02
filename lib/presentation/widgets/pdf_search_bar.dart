import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/vintage_theme.dart';
import '../bloc/pdf_reader_bloc.dart';
import '../bloc/pdf_reader_event.dart';
import '../bloc/pdf_reader_state.dart';

class PdfSearchBar extends StatelessWidget {
  const PdfSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PdfReaderBloc>();
    return BlocBuilder<PdfReaderBloc, PdfReaderState>(
      buildWhen: (prev, curr) =>
          prev.searchMatchCount != curr.searchMatchCount ||
          prev.searchCurrentIndex != curr.searchCurrentIndex ||
          prev.isCaseSensitive != curr.isCaseSensitive,
      builder: (context, state) {
        final hasQuery = bloc.searchController.text.isNotEmpty;
        final matchText = hasQuery && state.searchMatchCount > 0
            ? '${state.searchCurrentIndex + 1} / ${state.searchMatchCount}'
            : hasQuery && state.searchMatchCount == 0
            ? 'لا توجد نتائج'
            : '';

        return Material(
          elevation: 12,
          borderRadius: BorderRadius.circular(14),
          color: VintageTheme.inkDark.withOpacity(0.97),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: VintageTheme.vintageGold.withOpacity(0.3),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Search icon
                    const Icon(
                      Icons.search,
                      color: VintageTheme.vintageGold,
                      size: 20,
                    ),
                    const SizedBox(width: 8),

                    // Search field
                    Expanded(
                      child: TextField(
                        controller: bloc.searchController,
                        autofocus: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'البحث في الكتاب...',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        onChanged: (query) {
                          bloc.add(SearchQueryChangedEvent(query));
                        },
                      ),
                    ),

                    // Match counter
                    if (matchText.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: state.searchMatchCount > 0
                              ? VintageTheme.vintageGold.withOpacity(0.15)
                              : VintageTheme.crimsonRed.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          matchText,
                          style: TextStyle(
                            color: state.searchMatchCount > 0
                                ? VintageTheme.vintageGold
                                : VintageTheme.crimsonRed,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),

                    // Case sensitivity toggle
                    _ActionButton(
                      icon: 'Aa',
                      isActive: state.isCaseSensitive,
                      tooltip: 'حساسية الحروف',
                      onTap: () => bloc.add(ToggleCaseSensitivityEvent()),
                    ),

                    // Divider
                    Container(
                      width: 1,
                      height: 20,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: Colors.white12,
                    ),

                    // Prev match
                    _IconActionButton(
                      icon: Icons.keyboard_arrow_up_rounded,
                      tooltip: 'النتيجة السابقة',
                      enabled: state.searchMatchCount > 0,
                      onTap: () => bloc.add(SearchPrevMatchEvent()),
                    ),

                    // Next match
                    _IconActionButton(
                      icon: Icons.keyboard_arrow_down_rounded,
                      tooltip: 'النتيجة التالية',
                      enabled: state.searchMatchCount > 0,
                      onTap: () => bloc.add(SearchNextMatchEvent()),
                    ),

                    // Divider
                    Container(
                      width: 1,
                      height: 20,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: Colors.white12,
                    ),

                    // Close
                    _IconActionButton(
                      icon: Icons.close_rounded,
                      tooltip: 'إغلاق',
                      enabled: true,
                      onTap: () => bloc.add(ToggleSearchEvent()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String icon;
  final bool isActive;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.isActive,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? VintageTheme.vintageGold.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isActive
                  ? VintageTheme.vintageGold.withOpacity(0.5)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            icon,
            style: TextStyle(
              color: isActive ? VintageTheme.vintageGold : Colors.white54,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  const _IconActionButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            color: enabled ? Colors.white : Colors.white24,
            size: 22,
          ),
        ),
      ),
    );
  }
}
