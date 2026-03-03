import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/vintage_theme.dart';
import 'data/services/drive_api_service.dart';
import 'presentation/bloc/book_bloc.dart';
import 'presentation/bloc/book_event.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/bloc/dashboard_cubit.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/notification_service.dart';

import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Safe environment loading -- prevents boot crash
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    logger.e("Failed to load .env file during boot: $e");
  }

  // Safe notification initialization -- prevents boot crash
  try {
    await NotificationService.initialize();
  } catch (e) {
    logger.e("Failed to initialize NotificationService during boot: $e");
  }

  // Guarantees the UI renders no matter what auxiliary services fail
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
        BlocProvider<DashboardCubit>(create: (context) => DashboardCubit()),
      ],
      child: MaterialApp(
        title: 'مدرسة الروح القدس',
        debugShowCheckedModeBanner: false,
        theme: VintageTheme.darkTheme,
        home: const DashboardScreen(),
      ),
    );
  }
}
