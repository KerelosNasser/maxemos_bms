import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/vintage_theme.dart';
import 'data/services/drive_api_service.dart';
import 'presentation/bloc/book_bloc.dart';
import 'presentation/bloc/book_event.dart';
import 'presentation/screens/dashboard_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await NotificationService.initialize();
  runApp(const MaxemosBMSApp());
}

class MaxemosBMSApp extends StatelessWidget {
  const MaxemosBMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BookBloc>(
          create: (context) =>
              BookBloc(driveApiService: DriveApiService())
                ..add(LoadBooksEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'Maxemos BMS',
        debugShowCheckedModeBanner: false,
        theme: VintageTheme.darkTheme,
        home: const DashboardScreen(),
      ),
    );
  }
}
