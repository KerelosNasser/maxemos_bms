import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/vintage_theme.dart';
import '../../data/models/highlight.dart';
import '../bloc/pdf_reader_bloc.dart';
import '../bloc/pdf_reader_event.dart';
import 'sermon_folder_selection_sheet.dart';

/// The inner content of the floating "Save Highlight" button.
/// Returns SizedBox.shrink() when no text is selected.
/// Parent is responsible for Positioned wrapping inside a Stack.
class HighlightActionButton extends StatelessWidget {
  final String bookId;

  const HighlightActionButton({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PdfReaderBloc>();
    final state = context.watch<PdfReaderBloc>().state;

    if (state.selectedText == null || state.selectedText!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: VintageTheme.inkDark.withOpacity(0.95),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => SermonFolderSelectionSheet(
              bookId: bookId,
              pageNumber: state.selectedPageNumber ?? 1,
              selectedText: state.selectedText!,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: VintageTheme.vintageGold.withOpacity(0.5),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_add_rounded,
                color: VintageTheme.vintageGold,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'حفظ علامة',
                style: TextStyle(
                  color: VintageTheme.vintageGold,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
