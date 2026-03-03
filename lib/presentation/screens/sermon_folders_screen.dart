import 'package:flutter/material.dart';
import '../../core/theme/vintage_theme.dart';
import '../../data/models/highlight.dart';
import '../../data/services/highlight_service.dart';

class SermonFoldersScreen extends StatefulWidget {
  const SermonFoldersScreen({super.key});

  @override
  State<SermonFoldersScreen> createState() => _SermonFoldersScreenState();
}

class _SermonFoldersScreenState extends State<SermonFoldersScreen> {
  bool _isLoading = true;
  List<String> _folders = [];
  Map<String, List<Highlight>> _folderHighlights = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final allHighlights = await HighlightService.getAllHighlights();
    final Map<String, List<Highlight>> grouped = {};
    final Set<String> folderNames = {};

    for (var h in allHighlights) {
      if (h.folderId != null && h.folderId!.trim().isNotEmpty) {
        final folderName = h.folderId!.trim();
        folderNames.add(folderName);
        if (!grouped.containsKey(folderName)) {
          grouped[folderName] = [];
        }
        grouped[folderName]!.add(h);
      }
    }

    if (mounted) {
      setState(() {
        _folders = folderNames.toList()..sort();
        _folderHighlights = grouped;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VintageTheme.inkDark,
      appBar: AppBar(
        title: const Text(
          'مجلدات العظات',
          style: TextStyle(fontFamily: 'Amiri'),
        ),
        backgroundColor: VintageTheme.inkDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://www.transparenttextures.com/patterns/old-wall.png',
            ),
            repeat: ImageRepeat.repeat,
            colorFilter: ColorFilter.mode(Colors.white10, BlendMode.dstATop),
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: VintageTheme.vintageGold,
                ),
              )
            : _folders.isEmpty
            ? const Center(
                child: Text(
                  'لم يتم إنشاء أي مجلدات بعد.\nقم بتحديد نص في أي كتاب ثم اضغط على "حفظ في مجلد العظات".',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 20,
                    color: VintageTheme.parchmentLight,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              )
            : RefreshIndicator(
                color: VintageTheme.crimsonRed,
                onRefresh: _loadData,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _folders.length,
                  itemBuilder: (context, index) {
                    final folder = _folders[index];
                    final count = _folderHighlights[folder]?.length ?? 0;

                    return Card(
                      color: VintageTheme.parchmentLight,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: VintageTheme.vintageGold.withOpacity(0.5),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(
                          Icons.folder_special,
                          color: VintageTheme.vintageGold,
                          size: 40,
                        ),
                        title: Text(
                          folder,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: VintageTheme.inkDark,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        subtitle: Text(
                          '$count اقتباسات',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 16,
                            color: VintageTheme.inkDark.withOpacity(0.7),
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: VintageTheme.inkDark,
                        ),
                        onTap: () {
                          // TODO: Navigate to specific folder details
                        },
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
