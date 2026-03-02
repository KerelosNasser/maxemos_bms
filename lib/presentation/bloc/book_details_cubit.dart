import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/notification_service.dart';
import '../../data/models/book.dart';
import 'book_bloc.dart';
import 'book_event.dart';

class BookDetailsCubit extends Cubit<bool> {
  final BookBloc bookBloc;

  BookDetailsCubit(this.bookBloc) : super(false);

  Future<void> generateCategories(Book book, BuildContext context) async {
    if (state) return; // Prevent multiple requests
    emit(true);

    try {
      final data = await GeminiService.generateMetadata(book.title);
      final categories = List<String>.from(data['categories'] ?? []);
      final summary = data['summary'] ?? '';

      bookBloc.add(
        UpdateBookEvent(
          fileId: book.id,
          categories: categories,
          summary: summary,
        ),
      );

      NotificationService.showNotification(
        id: 4,
        title: 'تمت العملية',
        body: 'تم توليد الملخص وفرزه',
      );

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      NotificationService.showNotification(
        id: 5,
        title: 'فشلت العملية',
        body: e.toString(),
      );
    } finally {
      emit(false);
    }
  }
}
