import 'package:equatable/equatable.dart';

abstract class KatalogEvent extends Equatable {
  const KatalogEvent();

  @override
  List<Object> get props => [];
}

// Event untuk meminta data dari backend
class FetchKatalog extends KatalogEvent {}