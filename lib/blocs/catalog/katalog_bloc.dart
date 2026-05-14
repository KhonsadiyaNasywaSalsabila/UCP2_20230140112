import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/katalog_service.dart';
import 'katalog_event.dart';
import 'katalog_state.dart';

class KatalogBloc extends Bloc<KatalogEvent, KatalogState> {
  final KatalogService katalogService;

  KatalogBloc({required this.katalogService}) : super(KatalogInitial()) {
    
    // Handler saat event FetchKatalog dipanggil
    on<FetchKatalog>((event, emit) async {
      emit(KatalogLoading()); // Tampilkan loading
      try {
        final data = await katalogService.getAllKatalog();
        emit(KatalogLoaded(data)); // Berikan data ke UI
      } catch (e) {
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        emit(KatalogError(errorMessage)); // Tampilkan pesan error
      }
    });
  }
}