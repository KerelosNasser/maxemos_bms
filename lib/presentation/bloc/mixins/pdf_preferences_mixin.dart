import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pdf_reader_event.dart';
import '../pdf_reader_state.dart';

mixin PdfPreferencesMixin on Bloc<PdfReaderEvent, PdfReaderState> {
  static const String _keySepia = 'pref_pdf_sepia_mode';
  static const String _keyNavZones = 'pref_pdf_nav_zones';

  Future<void> onLoadPreferences(
    LoadPreferencesEvent event,
    Emitter<PdfReaderState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final sepia = prefs.getBool(_keySepia) ?? false;
    final navZones = prefs.getBool(_keyNavZones) ?? false;

    emit(
      state.copyWith(
        isSepiaModeEnabled: sepia,
        isNavigationZonesEnabled: navZones,
      ),
    );
  }

  Future<void> onToggleSepiaMode(
    ToggleSepiaModeEvent event,
    Emitter<PdfReaderState> emit,
  ) async {
    final newValue = !state.isSepiaModeEnabled;
    emit(state.copyWith(isSepiaModeEnabled: newValue));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySepia, newValue);
  }

  Future<void> onToggleNavigationZones(
    ToggleNavigationZonesEvent event,
    Emitter<PdfReaderState> emit,
  ) async {
    final newValue = !state.isNavigationZonesEnabled;
    emit(state.copyWith(isNavigationZonesEnabled: newValue));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNavZones, newValue);
  }
}
