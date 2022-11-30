import 'package:app4/blocs/blocs.dart';
import 'package:app4/models/models.dart';
import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class SearchDestinationDelegate extends SearchDelegate<SearchResult> {
  final bool isFavorite;
  String searchText = '';
  // SearchDestinationDelegate() : super(searchFieldLabel: 'Buscar y "Enter"');
  SearchDestinationDelegate({this.isFavorite = false}) : super(searchFieldLabel: 'Buscar y confirmar destino');
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
    final navigationBloc = BlocProvider.of<NavigationBloc>(context);
    return IconButton(
        onPressed: () {
          final result = SearchResult(cancel: true);
          if(navigationBloc.state.isFavoriteRouteSelected){
            print('Favorite----> CANCEL ARROW');
            navigationBloc.add(OffFavoritiesSpecialEvent());
          }
          close(context, result);
        },
        icon: const Icon(Icons.arrow_back));
        
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
                final result = SearchResult(streetName: place.placeName, cancel: false, manual: true, coordinates: LatLng(place.geometry.coordinates[1], place.geometry.coordinates[0]));
                // final result = SearchResult(streetName: place.placeName, cancel: false, manual: false, coordinates: LatLng(place.geometry.coordinates[1], place.geometry.coordinates[0]));
                
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
    final navigationBloc = BlocProvider.of<NavigationBloc>(context);
    print('Preferences----->>> ${navigationBloc.state.navigationState}');
    return ListView(children: isFavorite ? [
      manualOption(context),

    ] : [
      manualOption(context),
      // (navigationBloc.state.navigationState < 5) ? 

      // const SizedBox() :
      // const SizedBox() ,
      for(int i = navigationBloc.state.favoritePlacesData.length - 1; i >= 0; i--)
        ListTile(
        leading: const Icon(
          Icons.location_on_outlined,
          color: AppTheme.black,
        ),
        title: Text(
          navigationBloc.state.favoritePlacesData[i].tag,
        ),
        subtitle: Text(
          navigationBloc.state.favoritePlacesData[i].streetName,
        ),
        onTap: () {
          // final result = SearchResult(cancel: false, manual: true);
          final result = SearchResult(streetName: navigationBloc.state.favoritePlacesData[i].streetName, cancel: false, manual: true, coordinates: 
            LatLng(navigationBloc.state.favoritePlacesData[i].lat, navigationBloc.state.favoritePlacesData[i].lng));
          close(context, result);
          //TODO: RETURN SOMETHING
        },
      ) ,

      
    ]);
  }

  ListTile manualOption(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.location_searching,
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
    );
  }
}


