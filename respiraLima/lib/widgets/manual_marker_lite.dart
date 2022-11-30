import 'package:animate_do/animate_do.dart';
import 'package:app4/blocs/blocs.dart';
import 'package:app4/screens/screens.dart';
import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManualMarkerLite extends StatelessWidget {
  const ManualMarkerLite({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(builder: ((context, state) {
      return state.displayManualMarker
          ? const _ManualMarkerLiteBody()
          : const SizedBox();
    }));
  }
}

class _ManualMarkerLiteBody extends StatelessWidget {
  const _ManualMarkerLiteBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationBloc = BlocProvider.of<NavigationBloc>(context, listen: false);
    final searchBloc = BlocProvider.of<SearchBloc>(context, listen: false);
    // final locationBloc = BlocProvider.of<LocationBloc>(context);
    final mapBloc = BlocProvider.of<MapBloc>(context, listen: false);
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          return Stack(
            children: [
              const Positioned(
                top: 70,
                left: 20,
                child: _BtnBack(),
              ),

              Center(
                child: Transform.translate(
                  offset:  Offset(0, size.height/2-53),
                  child: BounceInDown(
                      from: 150,
                      child: Column(
                        children: [
                          Container(
                              color: Colors.white70,
                              child: Text(
                                state.forSearchStreetName,
                                style: const TextStyle(
                                    fontSize: 15, color: AppTheme.darkBlue),
                              )),
                          const Icon(
                            Icons.location_on_rounded,
                            size: 40,
                            color: AppTheme.darkBlue,
                          ),
                        ],
                      )),
                ),
              ),

              state.isFollowingUser ? const SizedBox() : Positioned(
                top: 122,
                left: 15,
                child: IconButton(
                  onPressed: () {
                    mapBloc.add(WillStartFollowingUser());
                    // draggableScrollableController.reset();
                    // draggableScrollableController.jumpTo(0.11);
                    // draggableScrollableController.jumpTo(0.15);
                  },
                  icon: const CircleAvatar(
                    backgroundColor: AppTheme.gray50,
                    radius: 35,
                    child: Icon(
                      Icons.gps_fixed,
                      size: 15,
                      color: AppTheme.white,
                    ),
                  ),
                  color: AppTheme.darkBlue,
                  iconSize: 40,
                ),
              ),

              // CONFIMR BUTTOM
              Positioned(
                bottom: 38,
                right: 40,
                child: FadeInUp(
                  child: MaterialButton(
                      elevation: 0,
                      shape: const StadiumBorder(),
                      color: AppTheme.darkBlue,
                      minWidth: size.width - 100,
                      height: 45,
                      child: const Text(
                        'Confirmar destino',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w300),
                      ),
                      onPressed: () {
                        
                        searchBloc.add(OnDeactivateManualMarkerEvent());
                        print('Favorite----> navState ${navigationBloc.state.navigationState}');
                        if(navigationBloc.state.navigationState >= 100){
                          navigationBloc.add(OnSelectingFavoriteRoute(
                            mapBloc.state.cameraPosition.target));
                          navigationBloc.add(OffFavoritiesSpecialEvent());
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FavoritesScreen()),
                          );
                        } else{
                          mapBloc.drawMyDestination(mapBloc.state.cameraPosition.target);
                          navigationBloc.add(OnSelectingRoute(
                            mapBloc.state.cameraPosition.target));
                        }
                      }
                      //   async{
                      //     final start = locationBloc.state.lastKnownLocation;
                      //     if (start == null) return;
                      //     final end = mapBloc.cameraPosition?.target;
                      //     if(end == null) return;
                      //     final routeService = Provider.of<RouteService>(context, listen: false);
                      //     final token = await PrincipalDB.getFirebaseToken();
                      //     final routeWithPrediction =  await routeService.getRouteWithPrediction(
                      //       initCoor: start,
                      //       lastCoor: end,
                      //       profile: 'walking',
                      //       idToken: token,
                      //       ); // TODO: add the mode 'walking' on the bloc

                      //     print('Routing destiny is: $routeWithPrediction');
                      //     print('Routing destiny is points: ${routeWithPrediction["points"]}');

                      //     final latLngList = routeWithPrediction['points'].map((coors) => LatLng(coors[1], coors[0])).toList();
                      //     final List<LatLng> points = latLngList.cast<LatLng>();
                      //     print('Routing destiny is points: ${points.length}');

                      //     // final destination =  await searchBloc.getCoorsStartToEnd(start, end, 'walking'); // TODO: add the mode 'walking' on the bloc
                      //    final destination = RouteDestination(
                      //       points: points,
                      //       duration: 10,
                      //       distance: 14
                      //       );
                      //     mapBloc.drawRoutePolyline(destination);
                      //   // TODO: LOADING
                      // },

                      ),
                ),
              ),
      
  
            ],
          );
        },
      ),
    );
     
  }
}

class _BtnBack extends StatelessWidget {
  const _BtnBack({
    Key? key,
  }) : super(key: key);
  void closeManualMarkerLite(BuildContext context) {
    final searchBloc = BlocProvider.of<SearchBloc>(context);
    searchBloc.add(OnDeactivateManualMarkerEvent());
  }

  @override
  Widget build(BuildContext context) {
    final navigationBloc = BlocProvider.of<NavigationBloc>(context, listen: false);
    return FadeInLeft(
      // duration: const Duration(microseconds: 500),
      child: CircleAvatar(
        maxRadius: 22,
        backgroundColor: AppTheme.darkBlue,
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () {
            // TODO:
            // CANCELAR EL MARCADOR MANUAL
            closeManualMarkerLite(context);
            if(navigationBloc.state.navigationState >= 100){
              navigationBloc.add(OffFavoritiesSpecialEvent());
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FavoritesScreen()),
              );

            }
          },
        ),
      ),
    );
  }
}
