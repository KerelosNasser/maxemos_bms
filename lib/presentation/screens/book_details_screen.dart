import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/vintage_theme.dart';
import '../../data/models/book.dart';
import '../../core/services/notification_service.dart';
import '../bloc/book_bloc.dart';
import '../bloc/book_details_cubit.dart';
import 'pdf_reader_screen.dart';
import '../widgets/book_details_widgets.dart';

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  const BookDetailsScreen({super.key, required this.book});

  Future<void> _launchUrl(BuildContext context) async {
    if (book.url.isNotEmpty) {
      final Uri url = Uri.parse(book.url);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          NotificationService.showNotification(
            id: 3,
            title: 'Action Failed',
            body: 'Could not open the manuscript URL.',
          );
        }
      }
    } else {
      NotificationService.showNotification(
        id: 3,
        title: 'No URL',
        body: 'No URL available for this manuscript.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BookDetailsCubit>(
      create: (context) => BookDetailsCubit(context.read<BookBloc>()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('تفاصيل المخطوطة')),
            body: Container(
              decoration: BoxDecoration(
                color: VintageTheme.parchmentLight,
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://www.transparenttextures.com/patterns/old-wall.png',
                  ),
                  repeat: ImageRepeat.repeat,
                  colorFilter: ColorFilter.mode(
                    Colors.white24,
                    BlendMode.dstATop,
                  ),
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Icon(
                            Icons.menu_book,
                            size: 100,
                            color: VintageTheme.crimsonRed.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          book.title,
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                fontSize: 28,
                                height: 1.2,
                                color: Colors.black,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Divider(
                          color: VintageTheme.vintageGold,
                          thickness: 1.5,
                        ),
                        const SizedBox(height: 16),

                        BookDetailRow(label: 'الكاتب', value: book.author),
                        BookDetailRow(
                          label: 'الحجم',
                          value:
                              '${(book.size / 1024 / 1024).toStringAsFixed(2)} MB',
                        ),
                        BookDetailRow(
                          label: 'تاريخ الإضافة',
                          value:
                              '${book.dateCreated.year}-${book.dateCreated.month.toString().padLeft(2, '0')}-${book.dateCreated.day.toString().padLeft(2, '0')}',
                        ),

                        const SizedBox(height: 16),
                        const Divider(
                          color: VintageTheme.vintageGold,
                          thickness: 1.5,
                        ),
                        const SizedBox(height: 24),

                        Text(
                          'التصنيفات',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        BookCategoriesWrap(categories: book.categories),

                        const SizedBox(height: 32),
                        Text(
                          'ملخص وتحليلات',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        BookSummaryCard(summary: book.summary),

                        const SizedBox(height: 48),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                             MaterialPageRoute(
                                builder: (context) =>
                                    PdfReaderScreen(book: book),
                              ),
                            );
                          },
                          icon: const Icon(Icons.menu_book),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              'قراءة المخطوطة',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => _launchUrl(context),
                          icon: const Icon(Icons.open_in_new),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              'فتح في Drive',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<BookDetailsCubit, bool>(
                          builder: (context, isGenerating) {
                            return OutlinedButton.icon(
                              onPressed: isGenerating
                                  ? null
                                  : () => context
                                        .read<BookDetailsCubit>()
                                        .generateCategories(book, context),
                              icon: isGenerating
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: VintageTheme.inkDark,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.auto_awesome,
                                      color: VintageTheme.inkDark,
                                    ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: VintageTheme.inkDark,
                                side: const BorderSide(
                                  color: VintageTheme.inkDark,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                              ),
                              label: Text(
                                isGenerating
                                    ? 'انتظر قليلا....'
                                    : 'توليد ملخص و تصنيف المخطوطة',
                                style: const TextStyle(fontSize: 18),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
