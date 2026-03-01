import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/vintage_theme.dart';
import '../../data/models/book.dart';
import '../screens/book_details_screen.dart';
import '../bloc/book_bloc.dart';
import '../bloc/book_event.dart';

class BookCard extends StatelessWidget {
  final Book book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      color: VintageTheme.parchmentLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: VintageTheme.vintageGold.withOpacity(0.5)),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailsScreen(book: book),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Hero(
          tag: 'book_icon_${book.id}',
          child: Icon(
            Icons.menu_book,
            color: VintageTheme.crimsonRed.withOpacity(0.8),
            size: 40,
          ),
        ),
        title: Hero(
          tag: 'book_title_${book.id}',
          child: Material(
            type: MaterialType.transparency,
            child: Text(
              book.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Cinzel',
                fontSize: 18,
              ),
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (book.categories.isNotEmpty)
              Text(
                'Category: ${book.categories.join(', ')}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            const SizedBox(height: 4),
            Text(
              'Size: ${(book.size / 1024 / 1024).toStringAsFixed(2)} MB',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.black54),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete Tome?'),
                content: const Text(
                  'Are you sure you wish to remove this manuscript from the archives?',
                ),
                backgroundColor: VintageTheme.parchmentLight,
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
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
    );
  }
}
