import 'package:flutter/material.dart';
import '../../core/theme/vintage_theme.dart';
import '../../data/models/highlight.dart';

/// Bottom sheet displaying saved highlights with navigation and delete.
class HighlightPanel extends StatelessWidget {
  final List<Highlight> highlights;
  final ValueChanged<Highlight> onGoToHighlight;
  final ValueChanged<String> onRemoveHighlight;
  final VoidCallback onClose;

  const HighlightPanel({
    super.key,
    required this.highlights,
    required this.onGoToHighlight,
    required this.onRemoveHighlight,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      color: VintageTheme.inkDark,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.45,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: VintageTheme.vintageGold.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: VintageTheme.vintageGold.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white54,
                    ),
                    onPressed: onClose,
                    iconSize: 20,
                  ),
                  const Spacer(),
                  Text(
                    'العلامات المحفوظة (${highlights.length})',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: VintageTheme.vintageGold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.bookmark_rounded,
                    color: VintageTheme.vintageGold,
                    size: 22,
                  ),
                ],
              ),
            ),

            const Divider(color: VintageTheme.inkFaded, height: 1),

            // List
            if (highlights.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'لا توجد علامات بعد.\nحدد نصاً في الكتاب لإضافة علامة.',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 15),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: highlights.length,
                  separatorBuilder: (_, _) => const Divider(
                    color: VintageTheme.inkFaded,
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final highlight = highlights[index];
                    return Dismissible(
                      key: Key(highlight.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        color: VintageTheme.crimsonRed.withOpacity(0.8),
                        child: const Icon(
                          Icons.delete_rounded,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (_) => onRemoveHighlight(highlight.id),
                      child: ListTile(
                        onTap: () => onGoToHighlight(highlight),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(highlight.colorValue).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(
                                highlight.colorValue,
                              ).withOpacity(0.5),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${highlight.pageNumber}',
                              style: TextStyle(
                                color: Color(highlight.colorValue),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          highlight.text,
                          textDirection: TextDirection.rtl,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          _formatDate(highlight.createdAt),
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white24,
                          size: 14,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
