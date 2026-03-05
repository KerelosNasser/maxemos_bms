import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pdf_reader_event.dart';
import '../pdf_reader_state.dart';

mixin PdfPreferencesMixin on Bloc<PdfReaderEvent, PdfReaderState> {
  static const String _keySepia = 'pref_pdf_sepia_mode';
  static const String _keySepiaWeight = 'pref_pdf_sepia_weight';
  static const String _keyNavZones = 'pref_pdf_nav_zones';
  static const String _keyNavZonesWidth = 'pref_pdf_nav_zones_width';

  Future<void> onLoadPreferences(
    LoadPreferencesEvent event,
    Emitter<PdfReaderState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final sepia = prefs.getBool(_keySepia) ?? false;
    final sepiaWeight = prefs.getDouble(_keySepiaWeight) ?? 1.0;
    final navZones = prefs.getBool(_keyNavZones) ?? false;
    final navZonesWidth = prefs.getDouble(_keyNavZonesWidth) ?? 0.15;

    emit(
      state.copyWith(
        isSepiaModeEnabled: sepia,
        sepiaWeight: sepiaWeight,
        isNavigationZonesEnabled: navZones,
        navigationZonesWidth: navZonesWidth,
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

  Future<void> onUpdateSepiaWeight(
    UpdateSepiaWeightEvent event,
    Emitter<PdfReaderState> emit,
  ) async {
    emit(state.copyWith(sepiaWeight: event.weight));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keySepiaWeight, event.weight);
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

  Future<void> onUpdateNavigationZonesWidth(
    UpdateNavigationZonesWidthEvent event,
    Emitter<PdfReaderState> emit,
  ) async {
    emit(state.copyWith(navigationZonesWidth: event.width));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyNavZonesWidth, event.width);
  }
}
