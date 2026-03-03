import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/vintage_theme.dart';
import '../bloc/pdf_reader_bloc.dart';
import '../bloc/pdf_reader_event.dart';
import 'pdf_preferences_sheet.dart';


class PdfReaderAppBarContent extends StatelessWidget {
  final String bookId;
  final String bookTitle;

  const PdfReaderAppBarContent({
    super.key,
    required this.bookId,
    required this.bookTitle,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PdfReaderBloc>();
    final state = context.watch<PdfReaderBloc>().state;
    final topPadding = MediaQuery.of(context).padding.top;

    return Material(
      elevation: 4,
      color: VintageTheme.inkDark,
      child: Container(
        height: kToolbarHeight + topPadding,
        padding: EdgeInsets.only(top: topPadding),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Hero(
                tag: 'book_title_$bookId',
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    bookTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.tune, color: Colors.white),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (_) => PdfPreferencesSheet(bloc: bloc, state: state),
                );
              },
              tooltip: 'خيارات القراءة',
            ),
            IconButton(
              icon: Icon(
                Icons.bookmark_rounded,
                color: state.isHighlightPanelOpen
                    ? VintageTheme.vintageGold
                    : Colors.white,
              ),
              onPressed: () => bloc.add(ToggleHighlightPanelEvent()),
              tooltip: 'العلامات',
            ),
            IconButton(
              icon: Icon(
                state.isSearching ? Icons.search_off : Icons.search,
                color: Colors.white,
              ),
              onPressed: () => bloc.add(ToggleSearchEvent()),
              tooltip: 'بحث',
            ),
          ],
        ),
      ),
    );
  }
}
