import 'package:equatable/equatable.dart';
import '../../models/katalog_model.dart';

abstract class KatalogState extends Equatable {
  const KatalogState();
  
  @override
  List<Object> get props => [];
}

class KatalogInitial extends KatalogState {}
class KatalogLoading extends KatalogState {}

class KatalogLoaded extends KatalogState {
  final List<KatalogModel> katalogList;
  const KatalogLoaded(this.katalogList);

  @override
  List<Object> get props => [katalogList];
}

class KatalogError extends KatalogState {
  final String message;
  const KatalogError(this.message);

  @override
  List<Object> get props => [message];
}