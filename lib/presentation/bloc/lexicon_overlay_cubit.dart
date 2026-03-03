import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/term_regex_engine.dart';
import '../../data/repositories/lexicon_repository.dart';
import 'lexicon_overlay_state.dart';

class LexiconOverlayCubit extends Cubit<LexiconOverlayState> {
  final LexiconRepository _repository;

  LexiconOverlayCubit({LexiconRepository? repository})
    : _repository = repository ?? LexiconRepository(),
      super(LexiconOverlayInitial());

  Future<void> fetchDefinition(String rawSelectedText) async {
    emit(LexiconOverlayLoading());

    try {
      final cleanedTerm = TermRegexEngine.extractCoreRoot(rawSelectedText);

      // Avoid querying single letters or completely mangled strings
      if (cleanedTerm.length < 3) {
        emit(
          const LexiconOverlayError(
            'عذراً، الكلمة المحددة قصيرة جداً أو غير صالحة للبحث في القاموس الكنسي.',
          ),
        );
        return;
      }

      final definitionData = await _repository.getDefinition(cleanedTerm);

      if (definitionData != null) {
        emit(LexiconOverlayLoaded(definitionData));
      } else {
        emit(
          const LexiconOverlayError(
            'عذراً، لم يتم العثور على تفسير لهذه الكلمة في قاموس المصطلحات الكنسية.',
          ),
        );
      }
    } catch (e) {
      emit(const LexiconOverlayError('حدث خطأ أثناء البحث في القاموس.'));
    }
  }
}
