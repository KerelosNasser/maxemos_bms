import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/scriptural_regex_engine.dart';
import '../../data/repositories/bible_repository.dart';
import 'verse_overlay_state.dart';

class VerseOverlayCubit extends Cubit<VerseOverlayState> {
  final BibleRepository _bibleRepository;

  VerseOverlayCubit(this._bibleRepository) : super(VerseOverlayInitial());

  /// Fetches the raw unadulterated verse from the offline SQLite database.
  Future<void> loadVerse(BibleReference reference) async {
    emit(VerseOverlayLoading(reference));

    try {
      final text = await _bibleRepository.getVerseText(reference);

      if (text != null && text.isNotEmpty) {
        emit(VerseOverlayLoaded(reference, text));
      } else {
        // Fallback with deeply respectful language per the scholarly roadmap.
        emit(
          VerseOverlayError(
            reference,
            'عذراً، لم يتم العثور على الشاهد الكتابي في النسخة الحالية.',
          ),
        );
      }
    } catch (e) {
      emit(
        VerseOverlayError(
          reference,
          'حدث خطأ أثناء استرجاع النص المقدس. الرجاء التأكد من ملف قاعدة البيانات.',
        ),
      );
    }
  }
}
