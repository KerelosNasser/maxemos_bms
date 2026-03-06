import 'package:flutter/material.dart';
import '../../core/theme/vintage_theme.dart';
import 'sermon_folders_screen.dart';
import '../widgets/ai_chats_library_view.dart';

class UserLibraryScreen extends StatelessWidget {
  const UserLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: VintageTheme.inkDark,
        appBar: AppBar(
          title: const Text(
            'مكتبة المستخدم',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: VintageTheme.inkDark,
          elevation: 0,
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: VintageTheme.crimsonRed,
            labelColor: VintageTheme.vintageGold,
            unselectedLabelColor: Colors.white60,
            labelStyle: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(text: 'العلامات المرجعية', icon: Icon(Icons.bookmarks)),
              Tab(text: 'محادثات الذكاء الاصطناعي', icon: Icon(Icons.forum)),
            ],
          ),
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
          child: const TabBarView(
            physics:
                NeverScrollableScrollPhysics(), // Disable swipe to avoid gesture conflicts with collapsible sidebar
            children: [
              // Inside TabBarView, we don't want another Scaffold with AppBar if we can avoid it.
              // However, SermonFoldersScreen currently returns a Scaffold with an AppBar.
              // Let's wrap it and ignore its internal AppBar if possible, or just let it nest.
              // Nesting Scaffolds is okay, but it might look doubled. Let's see.
              SermonFoldersScreen(hideAppBar: true),
              AiChatsLibraryView(),
            ],
          ),
        ),
      ),
    );
  }
}
