import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/lexicon_overlay_cubit.dart';
import '../bloc/lexicon_overlay_state.dart';

class LexiconOverlaySheet extends StatelessWidget {
  final String selectedText;

  const LexiconOverlaySheet({super.key, required this.selectedText});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LexiconOverlayCubit()..fetchDefinition(selectedText),
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: Color(0xFFFBF8F1), // Gentle parchment-like color
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.brown.withAlpha(50),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<LexiconOverlayCubit, LexiconOverlayState>(
                  builder: (context, state) {
                    if (state is LexiconOverlayLoading ||
                        state is LexiconOverlayInitial) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.brown),
                      );
                    } else if (state is LexiconOverlayError) {
                      return Center(
                        child: Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 22,
                            color: Colors.black54,
                            height: 1.8,
                          ),
                        ),
                      );
                    } else if (state is LexiconOverlayLoaded) {
                      final term = state.definitionData['term'] as String;
                      final definition =
                          state.definitionData['definition'] as String;
                      final root = state.definitionData['root'] as String?;
                      final language =
                          state.definitionData['language'] as String?;

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              term,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A3B32), // Deep Scholar Brown
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (root != null && language != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.brown.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "\$language: \$root",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.brown,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),
                            Text(
                              definition,
                              textAlign: TextAlign.justify,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 24,
                                height: 1.8,
                                color: Colors.black87,
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
            ],
          ),
        ),
      ),
    );
  }
}
