import 'package:app4/blocs/map/map_bloc.dart';
import 'package:app4/blocs/navigation/navigation_bloc.dart';
import 'package:app4/models/favorite_places_model.dart';
import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlertFavoritePlaceScreen extends StatelessWidget {
  final FavoritePlacesModel favPlace;
  const AlertFavoritePlaceScreen({Key? key, required this.favPlace}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final navigationBloc = BlocProvider.of<NavigationBloc>(context,listen: false);
    return Center(
         child: SingleChildScrollView(
          child: Container(
            // color: Colors.white,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              
            ),
            width: 280,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/favoritiesPlaces.png',
                        width: 100,
                        ),
                    ],
                  ),
                  const SizedBox(height: 15,),
                  Text(
                    favPlace.tag,
                    style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize:14, decorationColor: Colors.white),
                    ),
                  const SizedBox(height: 15,),
                  Text(
                    favPlace.streetName,
                    style: const TextStyle(fontWeight: FontWeight.w300, color: Colors.black, fontSize: 13, decorationColor: Colors.white),
                    ),
                  const SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed:() {
                          Navigator.pop(context);
                        }, 
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: AppTheme.darkBlue),
                          )),
                      const Expanded(child: SizedBox(width: 1,)),
                      TextButton(
                        onPressed:() async {
                          Navigator.pop(context);
                          navigationBloc.add(OnLoadingEvent());
                          await navigationBloc.deleteFavoriteDestination(favoriteDestinyID: favPlace.idF);
                          navigationBloc.add(OffLoadingEvent());
                        }, 
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(color: AppTheme.darkBlue),
                          )),
                    ],
                  )
                ]
              ),
            ),
          ),
         ),
      );
  }
}