import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/vintage_theme.dart';
import '../../data/models/book.dart';
import '../screens/book_details_screen.dart';
import '../bloc/book_bloc.dart';
import '../bloc/book_event.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final bool isCached;
  final bool isOffline;

  const BookCard({
    super.key,
    required this.book,
    this.isCached = false,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = !isOffline || isCached;

    return Opacity(
      opacity: isAvailable ? 1.0 : 0.5,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 4,
        color: VintageTheme.parchmentLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isCached
                ? Colors.green.withValues(alpha: 0.6)
                : VintageTheme.vintageGold.withValues(alpha: 0.5),
          ),
        ),
        child: ListTile(
          onTap: () {
            if (!isAvailable) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('هذا الكتاب غير متاح بدون إنترنت'),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookDetailsScreen(book: book),
              ),
            );
          },
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Hero(
            tag: 'book_icon_${book.id}',
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.menu_book,
                  color: VintageTheme.crimsonRed.withValues(alpha: 0.8),
                  size: 40,
                ),
                // Offline-available badge
                if (isCached)
                  const Positioned(
                    right: -4,
                    bottom: -4,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.download_done,
                        size: 12,
                        color: Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          title: Hero(
            tag: 'book_title_${book.id}',
            child: Material(
              type: MaterialType.transparency,
              child: Text(
                book.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cinzel',
                  fontSize: 18,
                ),
              ),
            ),
          ),
          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black54),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('تاكيد الحذف'),
                  content: const Text('هل انت متأكد من حذف هذا الكتاب؟'),
                  backgroundColor: VintageTheme.inkFaded,
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('الغاء'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.read<BookBloc>().add(DeleteBookEvent(book.id));
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
