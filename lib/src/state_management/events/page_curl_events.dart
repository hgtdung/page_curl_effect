import 'package:equatable/equatable.dart';
import 'package:page_curl_effect/src/model/coordinates/f_point.dart';

sealed class PageCurlEvent extends Equatable {}

/// The event in which the page turns normally from right to left or with a slight twist
class SketchEvent extends PageCurlEvent {
  @override
  List<Object?> get props => [];
}

/// The event in which a book page turns in a twisted manner and reach its limit
class CurlNormalEvent extends PageCurlEvent {
  CurlNormalEvent();

  @override
  List<Object?> get props => [];
}

/// The event in which a book page turns in a twisted manner and reach its limit
class CurlEdgeEvent extends PageCurlEvent {
  final double leftLimitationAngle;
  final FPoint newPivot;
  CurlEdgeEvent({required this.leftLimitationAngle,required this.newPivot});

  @override
  List<Object?> get props => [];

  copyWith(
      {double? leftLimitationAngle, FPoint? newPivot}) {
    return CurlEdgeEvent(
        leftLimitationAngle: leftLimitationAngle ?? this.leftLimitationAngle,
        newPivot: newPivot?? this.newPivot
    );
  }
}

/// The event in which the page can no longer be turned and is frozen.
class CurlFreezeEvent extends PageCurlEvent {
  @override
  List<Object?> get props => [];
}
