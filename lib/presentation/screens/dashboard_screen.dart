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
import 'book_details_screen.dart';
import '../../core/services/notification_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
                              return _buildBookCard(
                                context,
                                filteredBooks[index],
                              );
                            },
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filteredBooks.length,
                          itemBuilder: (context, index) {
                            return _buildBookCard(
                              context,
                              filteredBooks[index],
                            );
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
          color: VintageTheme.parchmentLight,
          image: const DecorationImage(
            image: NetworkImage(
              'https://www.transparenttextures.com/patterns/old-wall.png',
            ),
            repeat: ImageRepeat.repeat,
            colorFilter: ColorFilter.mode(Colors.white24, BlendMode.dstATop),
          ),
        ),
        child: bodyContent,
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

  Widget _buildBookCard(BuildContext context, Book book) {
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
