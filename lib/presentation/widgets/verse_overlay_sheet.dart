import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/vintage_theme.dart';
import '../../core/utils/scriptural_regex_engine.dart';
import '../../data/repositories/bible_repository.dart';
import '../bloc/verse_overlay_cubit.dart';
import '../bloc/verse_overlay_state.dart';

class VerseOverlaySheet extends StatelessWidget {
  final BibleReference reference;

  const VerseOverlaySheet({super.key, required this.reference});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VerseOverlayCubit(BibleRepository())..loadVerse(reference),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          decoration: const BoxDecoration(
            color: VintageTheme.parchmentLight,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          // Use a constrained box to ensure it acts as a readable panel
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.45,
            minHeight: 200,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    reference.toString(),
                    style: const TextStyle(
                      fontFamily: 'Amiri', // Authentic scholarly Arabic font
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: VintageTheme.inkDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: VintageTheme.inkDark),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'إغلاق',
                  ),
                ],
              ),
              const Divider(color: VintageTheme.vintageGold, thickness: 1.2),
              const SizedBox(height: 16),

              // Content Body from SQLite
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: BlocBuilder<VerseOverlayCubit, VerseOverlayState>(
                    builder: (context, state) {
                      if (state is VerseOverlayLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              VintageTheme.vintageGold,
                            ),
                          ),
                        );
                      } else if (state is VerseOverlayLoaded) {
                        return Text(
                          state.text,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontFamily: 'Amiri', // Re-enforce Arabic typography
                            fontSize: 24,
                            height: 1.6,
                            color: VintageTheme.inkDark,
                          ),
                        );
                      } else if (state is VerseOverlayError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 40,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 18,
                                  color: VintageTheme.inkDark,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
