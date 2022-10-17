part of 'search_bloc.dart';

class SearchState extends Equatable {
  final bool displayManualMarker;
  final List<Feature> places;
  const SearchState( 
    {
      this.places = const [],
      this.displayManualMarker = false,
    });
  
  SearchState copyWith({
    bool? displayManualMarker,
    List<Feature>? places,
    }) => SearchState(
      displayManualMarker : displayManualMarker ?? this.displayManualMarker,
      places: places ?? this.places,
    );

  @override
  List<Object> get props => [
    displayManualMarker, 
    places,
    ];
}
