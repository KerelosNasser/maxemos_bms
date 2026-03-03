import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/vintage_theme.dart';
import '../../data/models/highlight.dart';
import '../../data/services/highlight_service.dart';
import '../bloc/pdf_reader_bloc.dart';
import '../bloc/pdf_reader_event.dart';

class SermonFolderSelectionSheet extends StatefulWidget {
  final String bookId;
  final int pageNumber;
  final String selectedText;

  const SermonFolderSelectionSheet({
    super.key,
    required this.bookId,
    required this.pageNumber,
    required this.selectedText,
  });

  @override
  State<SermonFolderSelectionSheet> createState() =>
      _SermonFolderSelectionSheetState();
}

class _SermonFolderSelectionSheetState
    extends State<SermonFolderSelectionSheet> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _folderController = TextEditingController();

  List<String> _existingFolders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingFolders();
  }

  Future<void> _loadExistingFolders() async {
    final folders = await HighlightService.getSermonFolders();
    if (mounted) {
      setState(() {
        _existingFolders = folders;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _folderController.dispose();
    super.dispose();
  }

  void _saveHighlight() {
    final folderName = _folderController.text.trim();
    final note = _noteController.text.trim();

    final highlight = Highlight(
      pageNumber: widget.pageNumber,
      text: widget.selectedText,
      folderId: folderName.isNotEmpty ? folderName : null,
      note: note.isNotEmpty ? note : null,
    );

    context.read<PdfReaderBloc>().add(
      AddHighlightEvent(bookId: widget.bookId, highlight: highlight),
    );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم حفظ العلامة',
          textDirection: TextDirection.rtl,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: VintageTheme.inkFaded,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: VintageTheme.vintageGold),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: VintageTheme.parchmentLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: VintageTheme.vintageGold.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'حفظ في مجلد العظات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: VintageTheme.inkDark,
            ),
          ),
          const SizedBox(height: 24),

          // Folder Autocomplete
          Directionality(
            textDirection: TextDirection.rtl,
            child: RawAutocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return _existingFolders;
                }
                return _existingFolders.where((folder) {
                  return folder.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
                });
              },
              textEditingController: _folderController,
              fieldViewBuilder:
                  (
                    BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    return TextField(
                      controller: fieldTextEditingController,
                      focusNode: fieldFocusNode,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        color: VintageTheme.inkDark,
                      ),
                      decoration: InputDecoration(
                        labelText: 'اسم المجلد (مثال: عظة الأحد)',
                        labelStyle: TextStyle(
                          fontFamily: 'Amiri',
                          color: VintageTheme.inkDark.withOpacity(0.6),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: VintageTheme.vintageGold,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: VintageTheme.crimsonRed,
                            width: 2,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.folder_special,
                          color: VintageTheme.vintageGold,
                        ),
                      ),
                    );
                  },
              optionsViewBuilder:
                  (
                    BuildContext context,
                    AutocompleteOnSelected<String> onSelected,
                    Iterable<String> options,
                  ) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        color: VintageTheme.parchmentLight,
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 200.0,
                          width: MediaQuery.of(context).size.width - 48,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final String option = options.elementAt(index);
                              return InkWell(
                                onTap: () {
                                  onSelected(option);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    option,
                                    style: const TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 18,
                                      color: VintageTheme.inkDark,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
            ),
          ),

          const SizedBox(height: 16),

          // Optional Note
          Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              controller: _noteController,
              maxLines: 3,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
                color: VintageTheme.inkDark,
              ),
              decoration: InputDecoration(
                labelText: 'ملاحظة شخصية (اختياري)',
                labelStyle: TextStyle(
                  fontFamily: 'Amiri',
                  color: VintageTheme.inkDark.withOpacity(0.6),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: VintageTheme.vintageGold),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: VintageTheme.crimsonRed,
                    width: 2,
                  ),
                ),
                alignLabelWithHint: true,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Save Button
          ElevatedButton(
            onPressed: () => _saveHighlight(),
            style: ElevatedButton.styleFrom(
              backgroundColor: VintageTheme.crimsonRed,
              foregroundColor: VintageTheme.parchmentLight,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: const Text(
              'حفظ العلامة',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
