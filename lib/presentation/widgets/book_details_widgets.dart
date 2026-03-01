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
      children: categories.map((cat) {
        return Chip(
          label: Text(cat, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: VintageTheme.deeperParchment,
          side: const BorderSide(color: VintageTheme.vintageGold),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VintageTheme.parchmentDark.withOpacity(0.5),
        border: Border.all(color: VintageTheme.vintageGold.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        summary.isNotEmpty
            ? summary
            : 'No summary available. AI categorization pending.',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
      ),
    );
  }
}
