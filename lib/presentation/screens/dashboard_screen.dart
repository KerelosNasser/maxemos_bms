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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _extractCategories(List<Book> books) {
    Set<String> categorySet = {};
    for (var book in books) {
      if (book.categories.isNotEmpty) {
        categorySet.addAll(
          book.categories.map((e) => e.trim()).where((e) => e.isNotEmpty),
        );
      } else {
        categorySet.add('Uncategorized');
      }
    }
    List<String> categories = ['All'];
    var sortedCategories = categorySet.toList()..sort();
    categories.addAll(sortedCategories);
    return categories;
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

          final categories = _extractCategories(state.books);

          return DefaultTabController(
            length: categories.length,
            child: _buildScaffold(
              context,
              TabBarView(
                children: categories.map((category) {
                  List<Book> filteredBooks = state.books.where((book) {
                    // Global Search Filter
                    if (_searchQuery.isNotEmpty) {
                      final matchTitle = book.title.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      );
                      if (!matchTitle) return false;
                    }

                    // Category Filter
                    if (category == 'All') return true;
                    if (category == 'Uncategorized') {
                      return book.categories.isEmpty;
                    }
                    return book.categories.contains(category);
                  }).toList();

                  if (filteredBooks.isEmpty) {
                    return const Center(
                      child: Text('No tomes in this category.'),
                    );
                  }

                  return RefreshIndicator(
                    color: VintageTheme.crimsonRed,
                    onRefresh: () async {
                      context.read<BookBloc>().add(LoadBooksEvent());
                      // Wait for the state to stop loading
                      await context.read<BookBloc>().stream.firstWhere(
                        (state) => state is! BookLoading,
                      );
                    },
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth >= 600) {
                          int crossAxisCount = (constraints.maxWidth / 400)
                              .ceil();
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
                              return BookCard(book: filteredBooks[index]);
                            },
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filteredBooks.length,
                          itemBuilder: (context, index) {
                            return BookCard(book: filteredBooks[index]);
                          },
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
              categories,
              state,
            ),
          );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maxemos BMS'),
        actions: [
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
                child: TabBar(
                  isScrollable: true,
                  indicatorColor: VintageTheme.crimsonRed,
                  labelColor: VintageTheme.crimsonRed,
                  unselectedLabelColor: Colors.black54,
                  tabs: categories.map((cat) => Tab(text: cat)).toList(),
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
            DashboardSearchBar(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
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
