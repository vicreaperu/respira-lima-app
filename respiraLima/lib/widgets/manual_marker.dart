import 'package:animate_do/animate_do.dart';
import 'package:app4/blocs/blocs.dart';
import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManualMarker extends StatelessWidget {
  const ManualMarker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(builder: ((context, state) {
      return state.displayManualMarker
          ? const _ManualMarkerBody()
          : const SizedBox();
    }));
  }
}

class _ManualMarkerBody extends StatelessWidget {
  const _ManualMarkerBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationBloc = BlocProvider.of<NavigationBloc>(context);
    final searchBloc = BlocProvider.of<SearchBloc>(context);
    // final locationBloc = BlocProvider.of<LocationBloc>(context);
    final mapBloc = BlocProvider.of<MapBloc>(context);
    final size = MediaQuery.of(context).size;
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, stateNav) {
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
                      // offset: const Offset(0, 350),
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
                            navigationBloc.add(OnSelectingRoute(
                                mapBloc.state.cameraPosition.target));
                            searchBloc.add(OnDeactivateManualMarkerEvent());
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
                  Positioned(
                    bottom: 100,
                    left: 20,
                    child: GestureDetector(
                      onTap: () {
                        print(
                            'CHANGE--->>>   estatenav is ${stateNav.navigationProfile}');
                        if (stateNav.navigationProfile == "cycling") {
                          navigationBloc.add(WalkingNavigationProfileEvent());
                          print('CHANGE--->>> ICON to walking');
                        } else {
                          navigationBloc.add(CyclingNavigationProfileEvent());
                          print('CHANGE--->>> ICON to cycling');
                        }
                        print('CHANGE--->>> ICON');
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                            color: AppTheme.gray50,
                            borderRadius:
                                BorderRadius.all(Radius.circular(100))),
                        child: Image.asset(
                          'assets/icons/${stateNav.navigationProfile == "cycling" ? "walking" : "cycling"}2.png',
                          height: 70,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 39,
                    left: 62,
                    child: Container(
                      height: 45,
                      width: 45,
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                          color: AppTheme.darkBlue,
                          borderRadius: BorderRadius.all(Radius.circular(100))),
                      child: Image.asset(
                        'assets/icons/${stateNav.navigationProfile}2.png',
                        height: 40,
                      ),
                    ),
                  ),

                  // Positioned(
                  //   bottom: 31,
                  //   left: 28,
                  //   // left: size.width/3.5,
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       GestureDetector(
                  //         onTap: () {
                  //           print('CHANGE--->>> ICON');
                  //         },
                  //         child: Container(
                  //           height: 50,
                  //           width: 50,
                  //           padding: const EdgeInsets.all(12),
                  //           decoration: const BoxDecoration(
                  //           color: AppTheme.gray50,
                  //           borderRadius: BorderRadius.all(
                  //              Radius.circular(100)
                  //           )),
                  //           child: Image.asset('assets/icons/cycling2.png', height: 70,),

                  //           ),
                  //       ),
                  //       const SizedBox(height: 30,),
                  //       Container(
                  //         height: 60,
                  //         width: 60,
                  //         padding: const EdgeInsets.all(15),
                  //         decoration: const BoxDecoration(
                  //         color: AppTheme.darkBlue,
                  //         borderRadius: BorderRadius.all(
                  //            Radius.circular(100)
                  //         )),
                  //         child: Image.asset('assets/icons/walking2.png', height: 40,),
                  //         ),
                  //     ],)
                  // ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _BtnBack extends StatelessWidget {
  const _BtnBack({
    Key? key,
  }) : super(key: key);
  void closeManualMarker(BuildContext context) {
    final searchBloc = BlocProvider.of<SearchBloc>(context);
    searchBloc.add(OnDeactivateManualMarkerEvent());
  }

  @override
  Widget build(BuildContext context) {
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
            closeManualMarker(context);
          },
        ),
      ),
    );
  }
}
