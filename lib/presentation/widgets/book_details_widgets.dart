import 'package:flutter/material.dart';
import '../../core/theme/vintage_theme.dart';

class BookDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const BookDetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: VintageTheme.inkFaded,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class BookCategoriesWrap extends StatelessWidget {
  final List<String> categories;

  const BookCategoriesWrap({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Text(
        'Uncategorized',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
          color: Colors.black54,
        ),
      );
    }
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      textDirection: TextDirection.rtl,
      children: categories.map((cat) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: VintageTheme.inkDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: VintageTheme.vintageGold, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            cat,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class BookSummaryCard extends StatelessWidget {
  final String summary;

  const BookSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      // Use a dark ink background for high contrast with white text
      decoration: BoxDecoration(
        color: VintageTheme.inkDark,
        border: Border.all(color: VintageTheme.vintageGold, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Text(
        summary.isNotEmpty
            ? summary
            : 'لم يتم إنشاء الملخص حتى الآن.', // 'No summary available' in Arabic
        textDirection:
            TextDirection.rtl, // Ensure right-to-left alignment for Arabic
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.8,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
