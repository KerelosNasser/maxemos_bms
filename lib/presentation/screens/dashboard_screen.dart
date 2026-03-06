import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../../core/theme/vintage_theme.dart';
import '../bloc/book_bloc.dart';
import '../bloc/book_event.dart';
import '../bloc/book_state.dart';
import '../../data/models/book.dart';
import '../../core/services/notification_service.dart';
import '../widgets/dashboard_search_bar.dart';
import '../widgets/book_card.dart';
import '../bloc/dashboard_cubit.dart';
import 'user_library_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedCategory = 'الكل';

  List<String> _extractCategories(List<Book> books) {
    Map<String, int> categoryCounts = {};
    for (var book in books) {
      if (book.categories.isNotEmpty) {
        for (var cat in book.categories) {
          final c = cat.trim();
          if (c.isNotEmpty) {
            categoryCounts[c] = (categoryCounts[c] ?? 0) + 1;
          }
        }
      } else {
        categoryCounts['غير مصنف'] = (categoryCounts['غير مصنف'] ?? 0) + 1;
      }
    }

    // Sort by count descending, then alphabetically
    var sortedCategories = categoryCounts.keys.toList()
      ..sort((a, b) {
        int cmp = categoryCounts[b]!.compareTo(categoryCounts[a]!);
        if (cmp == 0) return a.compareTo(b);
        return cmp;
      });

    sortedCategories.remove('غير مصنف');

    List<String> categories = ['الكل'];
    if (categoryCounts.containsKey('غير مصنف')) {
      categories.add('غير مصنف');
    }
    categories.addAll(sortedCategories);
    return categories;
  }

  List<String> _getVisibleCategories(List<String> allCategories) {
    List<String> visible = ['الكل'];
    if (allCategories.contains('غير مصنف')) {
      visible.add('غير مصنف');
    }

    // Ensure selected is visible
    if (!visible.contains(_selectedCategory) &&
        allCategories.contains(_selectedCategory)) {
      visible.add(_selectedCategory);
    }

    // Fill up to 5 categories using the frequency-sorted list
    for (var cat in allCategories) {
      if (visible.length >= 5) break;
      if (!visible.contains(cat)) {
        visible.add(cat);
      }
    }
    return visible;
  }

  void _showAllCategoriesSheet(List<String> allCategories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: VintageTheme.parchmentLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: VintageTheme.inkFaded.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'كل التصنيفات',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: VintageTheme.inkDark,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      textDirection: TextDirection.rtl,
                      children: allCategories.map((cat) {
                        final isSelected = cat == _selectedCategory;
                        return ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              color: isSelected
                                  ? VintageTheme.parchmentLight
                                  : VintageTheme.inkDark,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: VintageTheme.crimsonRed,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected
                                ? VintageTheme.crimsonRed
                                : VintageTheme.vintageGold,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategory = cat);
                              Navigator.pop(context);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickAndUploadPDF(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      List<int> fileBytes = await file.readAsBytes();
      String base64String = base64Encode(fileBytes);
      String fileName = result.files.single.name;

      if (context.mounted) {
        context.read<BookBloc>().add(
          UploadBookEvent(
            base64File: base64String,
            fileName: fileName,
            mimeType: 'application/pdf',
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookBloc, BookState>(
      listener: (context, state) {
        if (state is BookUploadSuccess) {
          NotificationService.showUploadComplete(
            id: 1,
            title: 'Upload Complete',
            body: 'Book uploaded successfully!',
          );
        } else if (state is BookUploadFailure) {
          NotificationService.showUploadComplete(
            id: 1,
            title: 'Upload Failed',
            body: state.message,
          );
        } else if (state is BookError) {
          NotificationService.showUploadComplete(
            id: 2,
            title: 'Error',
            body: state.message,
          );
        } else if (state is BookUploading) {
          NotificationService.showUploadProgress(
            id: 1,
            title: 'Uploading Manuscript',
            body: 'Archiving ${(state.progress * 100).toInt()}%...',
            progress: (state.progress * 100).toInt(),
            maxProgress: 100,
          );
        }
      },
      buildWhen: (previous, current) =>
          current is BookLoading || current is BookLoaded,
      builder: (context, state) {
        if (state is BookLoading) {
          return _buildScaffold(
            context,
            const Center(
              child: CircularProgressIndicator(color: VintageTheme.crimsonRed),
            ),
            [],
            state,
          );
        } else if (state is BookLoaded) {
          if (state.books.isEmpty) {
            return _buildScaffold(
              context,
              Center(
                child: Text(
                  'The archives are empty.\nUpload a tome to begin.',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              [],
              state,
            );
          }

          final cachedIds = state.cachedBookIds;
          final isOffline = state.isOffline;
          final categories = _extractCategories(state.books);

          // Reset to All if category essentially got deleted from DB sync
          if (!categories.contains(_selectedCategory)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _selectedCategory = 'الكل');
            });
          }

          final bodyContent = BlocBuilder<DashboardCubit, String>(
            builder: (context, searchQuery) {
              List<Book> filteredBooks = state.books.where((book) {
                // Global Search Filter
                if (searchQuery.isNotEmpty) {
                  final matchTitle = book.title.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  );
                  if (!matchTitle) return false;
                }

                // Category Filter
                if (_selectedCategory == 'الكل') return true;
                if (_selectedCategory == 'غير مصنف') {
                  return book.categories.isEmpty;
                }
                return book.categories.contains(_selectedCategory);
              }).toList();

              if (filteredBooks.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد كتب في هذا التصنيف.',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                );
              }

              return RefreshIndicator(
                color: VintageTheme.crimsonRed,
                onRefresh: () async {
                  context.read<BookBloc>().add(LoadBooksEvent());
                  await context.read<BookBloc>().stream.firstWhere(
                    (state) => state is! BookLoading,
                  );
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 600) {
                      int crossAxisCount = (constraints.maxWidth / 400).ceil();
                      return GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisExtent:
                              130, // Fixed height to allow dynamic elements inside ListTile
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                        ),
                        itemCount: filteredBooks.length,
                        itemBuilder: (context, index) {
                          return BookCard(
                            book: filteredBooks[index],
                            isCached: cachedIds.contains(
                              filteredBooks[index].id,
                            ),
                            isOffline: isOffline,
                          );
                        },
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredBooks.length,
                      itemBuilder: (context, index) {
                        return BookCard(
                          book: filteredBooks[index],
                          isCached: cachedIds.contains(filteredBooks[index].id),
                          isOffline: isOffline,
                        );
                      },
                    );
                  },
                ),
              );
            },
          );

          return _buildScaffold(context, bodyContent, categories, state);
        }
        return _buildScaffold(
          context,
          const Center(child: Text('Initialize Sync')),
          [],
          state,
        );
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    Widget bodyContent,
    List<String> categories,
    BookState state,
  ) {
    final visibleCats = _getVisibleCategories(categories);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مدرسة الروح القدس'),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_library),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserLibraryScreen()),
              );
            },
            tooltip: 'مكتبة المستخدم',
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              context.read<BookBloc>().add(LoadBooksEvent());
            },
            tooltip: 'Sync with Drive',
          ),
        ],
        bottom: categories.isEmpty
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: Container(
                  height: kToolbarHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: visibleCats.length,
                            separatorBuilder: (context, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final cat = visibleCats[index];
                              final isSelected = cat == _selectedCategory;
                              return Center(
                                child: ChoiceChip(
                                  label: Text(
                                    cat,
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      color: isSelected
                                          ? VintageTheme.parchmentLight
                                          : VintageTheme.inkDark,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: VintageTheme.crimsonRed,
                                  backgroundColor: VintageTheme.parchmentLight
                                      .withOpacity(0.9),
                                  side: BorderSide(
                                    color: isSelected
                                        ? VintageTheme.crimsonRed
                                        : VintageTheme.vintageGold.withOpacity(
                                            0.5,
                                          ),
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() => _selectedCategory = cat);
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: VintageTheme.parchmentLight.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.more_horiz,
                            color: VintageTheme.vintageGold,
                          ),
                          onPressed: () => _showAllCategoriesSheet(categories),
                          tooltip: 'عرض كل التصنيفات',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: VintageTheme.inkDark,
          image: const DecorationImage(
            image: NetworkImage(
              'https://www.transparenttextures.com/patterns/old-wall.png',
            ),
            repeat: ImageRepeat.repeat,
            colorFilter: ColorFilter.mode(Colors.white10, BlendMode.dstATop),
          ),
        ),
        child: Column(
          children: [
            // Offline banner
            if (state is BookLoaded && state.isOffline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                color: Colors.orange.shade800,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'وضع عدم الاتصال — يتم عرض الكتب المحفوظة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
            const DashboardSearchBar(),
            Expanded(child: bodyContent),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _pickAndUploadPDF(context),
        backgroundColor: VintageTheme.crimsonRed,
        icon: const Icon(Icons.file_upload, color: VintageTheme.parchmentLight),
        label: Text(
          'Archive PDF',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: VintageTheme.parchmentLight,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
