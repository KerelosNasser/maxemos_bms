import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfrx/pdfrx.dart';

import '../pdf_reader_event.dart';
import '../pdf_reader_state.dart';

mixin PdfZoomMixin on Bloc<PdfReaderEvent, PdfReaderState> {
  PdfViewerController get pdfController;

  void onZoomIn(ZoomInEvent event, Emitter<PdfReaderState> emit) {
    pdfController.zoomUp();
    emit(state.copyWith(zoomLevel: pdfController.currentZoom));
  }

  void onZoomOut(ZoomOutEvent event, Emitter<PdfReaderState> emit) {
    pdfController.zoomDown();
    emit(state.copyWith(zoomLevel: pdfController.currentZoom));
  }

  void onZoomReset(ZoomResetEvent event, Emitter<PdfReaderState> emit) {
    pdfController.setZoom(pdfController.centerPosition, 1.0);
    emit(state.copyWith(zoomLevel: 1.0));
  }

  void onUpdateZoomLevel(
    UpdateZoomLevelEvent event,
    Emitter<PdfReaderState> emit,
  ) {
    emit(state.copyWith(zoomLevel: event.zoom));
  }
}
