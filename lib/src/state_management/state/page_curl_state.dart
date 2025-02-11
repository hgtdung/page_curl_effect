import 'package:equatable/equatable.dart';

sealed class PageCurlState extends Equatable {}

/// The state that page is fully sketch
class SketchState extends PageCurlState {
  @override
  List<Object?> get props => [];
}

/// The state in which the page turns normally from right to left or with a slight twist
class CurlNormalState extends PageCurlState {
  CurlNormalState();
  @override
  List<Object?> get props => [];
}

/// The state in which a book page turns in a twisted manner and reach its limit
class CurlEdgeState extends PageCurlState {
  CurlEdgeState();

  @override
  List<Object?> get props => [];
}

/// The state in which the page can no longer be turned and is frozen.
class CurlFreezeState extends PageCurlState {
  @override
  List<Object?> get props => [];
}
