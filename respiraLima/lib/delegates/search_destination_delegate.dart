import 'package:app4/blocs/blocs.dart';
import 'package:app4/models/models.dart';
import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class SearchDestinationDelegate extends SearchDelegate<SearchResult> {
  String searchText = '';
  // SearchDestinationDelegate() : super(searchFieldLabel: 'Buscar y "Enter"');
  SearchDestinationDelegate() : super(searchFieldLabel: 'Buscar y confirmar destino');
  @override
  List<Widget>? buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }


  @override
  Widget? buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
        onPressed: () {
          final result = SearchResult(cancel: true);
          close(context, result);
        },
        icon: Icon(Icons.arrow_back));
        
  }

  @override
  Widget buildResults(BuildContext context) {
    final searchBloc = BlocProvider.of<SearchBloc>(context);
    final mapBloc = BlocProvider.of<MapBloc>(context);
    // final navigationBloc = BlocProvider.of<NavigationBloc>(context);
    final proximity = BlocProvider.of<LocationBloc>(context).state.lastKnownLocation!;
    searchBloc.getPlacesByQuery(proximity, query );
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state)  {
        final places = state.places;
        return ListView.separated(
          itemCount: places.length,
          itemBuilder:(context, index) {
            final place = places[index];
            print('buscar..... is ${place.geometry.coordinates}');
            final int isOnArea = mapBloc.isOnAreaFastQuestionWithPoint(LatLng(place.geometry.coordinates[1], place.geometry.coordinates[0]));
            return ListTile(
              title: Text(place.text),
              subtitle: Text(isOnArea == 1 ? place.placeName : 'Fuera de área'),
              leading:  CircleAvatar(backgroundColor: isOnArea == 1 ? AppTheme.gray30 : AppTheme.red,child: Icon(Icons.place_sharp, color: isOnArea == 1 ? AppTheme.gray60 : AppTheme.white,),),
              onTap: () async {
                final result = SearchResult(streetName: place.placeName, cancel: false, manual: false, coordinates: LatLng(place.geometry.coordinates[1], place.geometry.coordinates[0]));
                
                // await mapBloc.updateForSearchData2(coordinates: result.coordinates!, streetName: result.streetName!);
                // navigationBloc.add(OnSelectingRoute(result.coordinates!));  
                
                // print('THE PLACE IS ${place.geometry.coordinates}');
                // print('THE PLACE IS ${place.placeName}');
                // print('THE PLACE IS result ${result.coordinates}');
                // print('THE PLACE IS result ${result.streetName}');
                close(context, result);
              },
            );
          },
          separatorBuilder: (context, index) => const Divider(),
        );
        // return Text('Aqui ${state.places.length}');
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    print('the place query: ${query}');
    return ListView(children: [
      ListTile(
        leading: const Icon(
          Icons.location_on_outlined,
          color: AppTheme.black,
        ),
        title: const Text(
          'Colocar la ubicacion manualmente',
        ),
        onTap: () {
          final result = SearchResult(cancel: false, manual: true);
          close(context, result);
          //TODO: RETURN SOMETHING
        },
      ),
    ]);
  }
}


