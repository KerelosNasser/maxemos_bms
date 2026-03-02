import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardCubit extends Cubit<String> {
  DashboardCubit() : super('');

  void searchChanged(String query) {
    emit(query);
  }
}
