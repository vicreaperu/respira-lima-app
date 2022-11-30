import 'package:animate_do/animate_do.dart';
import 'package:app4/delegates/delegates.dart';
import 'package:app4/models/models.dart';
import 'package:app4/share_preferences/preferences.dart';
import 'package:app4/themes/themes.dart';

import 'package:app4/blocs/blocs.dart';
import 'package:app4/ui/ui.dart';

import 'package:app4/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


/// TODO: POPUP WHEN NO INTERNET .......
///
///
///
class BottomModalSheet extends StatelessWidget {
  const BottomModalSheet({
    Key? key,
    required this.areaScreen,
    required this.callbackStart,
    required this.callbackEnd,
  }) : super(key: key);
  final VoidCallback callbackStart;
  final VoidCallback callbackEnd;
  final Size areaScreen;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        return state.displayManualMarker
            ? Container()
            : SizedBox(
                height: areaScreen.height,
                // child: _BottomModal(),
                child: _BottomModal(
                  callbackStart: callbackStart,
                  callbackEnd: callbackEnd,
                ));
      },
    );
  }
}

class _BottomModal extends StatelessWidget {
  final VoidCallback callbackStart;
  final VoidCallback callbackEnd;

  const _BottomModal(
      {super.key, required this.callbackStart, required this.callbackEnd});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.1,
          maxChildSize: 0.6,
          // maxChildSize: state.navigationMode == '' ? 0.1 : 0.6,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                  color: state.navigationState == 0
                      ? Colors.transparent
                      : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  )),
              child: SingleChildScrollView(
                controller: scrollController,
                child: SizedBox(
                  // height: 300,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: state.navigationMode == 'monitoreo' &&
                            state.navigationState >= 1
                        ? BottomModalMonitoreandoPrincipal(
                            callbackStart: callbackStart,
                            callbackEnd: callbackEnd,
                          )
                        : state.navigationMode == 'ruteo' &&
                                state.navigationState == 1
                            ? Container()
                            // ? const BottomModalRuteo()
                            : Container(),
                    // child: BottomModalRuteo(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class BottomModalMonitoreandoPrincipal extends StatelessWidget {
  const BottomModalMonitoreandoPrincipal({
    Key? key,
    required this.callbackStart,
    required this.callbackEnd,
  }) : super(key: key);
  final VoidCallback callbackStart;
  final VoidCallback callbackEnd;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return state.isNavigating
            ? BottomModalMonitoreando(
                callbackEnd: callbackEnd,
              )
            : BottomModalMonitoreo(
                callbackStart: callbackStart,
              );
      },
    );
  }
}

class BottomModalMonitoreando extends StatelessWidget {
  const BottomModalMonitoreando({
    Key? key,
    required this.callbackEnd,
  }) : super(key: key);
  final VoidCallback callbackEnd;
  @override
  Widget build(BuildContext context) {
    final navigationBloc = BlocProvider.of<NavigationBloc>(context);
    final mapBloc = BlocProvider.of<MapBloc>(context);
    // final navigationBloc = BlocProvider.of<NavigationBloc>(context);
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              // color: Colors.red,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      navigationBloc.add(DeactivateNavigationModeEvent());
                    },
                    icon: const Icon(Icons.arrow_drop_down),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: state.navigationDataToShowTracking.isEmpty
                      ? [
                          FadeOut(
                            child: Container(
                              width: 80,
                              height: 16,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  gradient: LinearGradient(
                                      colors: [Colors.grey, Colors.white])),
                            ),
                          ),
                          const SizedBox(height: 5),
                          FadeOut(
                            child: Container(
                              width: 100,
                              height: 16,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  gradient: LinearGradient(
                                      colors: [Colors.grey, Colors.white])),
                            ),
                          ),
                          const SizedBox(height: 5),
                          FadeOut(
                            child: Container(
                              width: 80,
                              height: 16,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  gradient: LinearGradient(
                                      colors: [Colors.grey, Colors.white])),
                            ),
                          ),
                        ]
                      : [
                          BounceInLeft(
                            child: Text(
                              state.isOnArea ? 'Actualmente estas en:' : '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w300, fontSize: 12),
                            ),
                          ),
                          BounceInLeft(
                            child: Text(
                              state.isOnArea
                                  ? (state.navigationDataToShowTracking
                                          .isNotEmpty
                                      ? state.navigationDataToShowTracking.last
                                          .streetName
                                      : '')
                                  : 'Estás fuera de área',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: state.isOnArea
                                      ? AppTheme.darkBlue
                                      : AppTheme.red,
                                  fontSize: 16),
                            ),
                          ),
                          BounceInLeft(
                            child: !state.isOnArea
                                ? const Text('')
                                : Row(
                                    children: [
                                      Text(
                                        // TODO: ASK WHAT TIME TO SHOWN
                                        state.navigationDataToShowTracking
                                                .isNotEmpty
                                            ? DateTime.now()
                                                .difference(DateTime.parse(state
                                                    .navigationDataToShowTracking
                                                    .first
                                                    .timestamp))
                                                .inMinutes
                                                .toString()
                                            : '',

                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.gray80,
                                            fontSize: 15),
                                      ),
                                      Text(
                                        // TODO: ASK WHAT DISTANCE TO SHOWN
                                        state.navigationDataToShowTracking
                                                .isNotEmpty
                                            ? 'min (${state.navigationDataToShowTracking.first.distance.toString()}km)'
                                            : '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.gray80,
                                            fontSize: 10),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                ),
                const Expanded(
                  child: SizedBox(
                    width: 20,
                  ),
                ),
                BtnEndNavigation(
                  text: ' Finalizar',
                  btnColor: AppTheme.primaryOrange,
                  icon: Icons.near_me_rounded ,
                  onPressed: () async {
                    mapBloc.add(OnStartLoading());
                    callbackEnd();
                    await navigationBloc.postTrackingPositionMikel();
                    // navigationBloc.add(StopNavigationEvent());
                    await navigationBloc.stopNavigation();
                    
                    mapBloc.add(OnStopLoading());
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            state.navigationDataToShowTracking.length > 1
                ? BounceInRight(
                    child: ProfileAndModeAvatar(
                        profile: state.navigationProfile == 'walking'
                            ? 'Peatón'
                            : 'Ciclista',
                        profileIcon: state.navigationProfile == 'walking'
                            ? Icons.directions_run
                            : Icons.directions_bike_outlined ,
                        mode: state.navigationMode == 'monitoreo'
                            ? 'Acompañamiento'
                            : 'Ruteo',
                        modeIcon: Icons.pin_drop_rounded),
                  )
                : const SizedBox(),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 1,
              width: double.infinity,
              color: AppTheme.gray30,
            ),
            const SizedBox(
              height: 20,
            ),
            state.navigationDataToShowTracking.length > 1
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        // ignore: unnecessary_null_comparison
                        for (int i =
                                state.navigationDataToShowTracking.length - 1;
                            i >= 0;
                            i--)
                          FadeInUp(
                            child: HistoryTrackingPerPoint(
                              isHoleBoll: i ==
                                      state.navigationDataToShowTracking
                                              .length -
                                          1
                                  ? true
                                  : false,
                              areLines: i == 0 ? false : true,
                              titleHeader: i == 0 ? "Partida: " : "",
                              title: state
                                  .navigationDataToShowTracking[i].streetName,
                              time: DateTime.now()
                                  .difference(DateTime.parse(state
                                      .navigationDataToShowTracking[i]
                                      .timestamp))
                                  .inMinutes
                                  .toString(),
                              distance: state
                                  .navigationDataToShowTracking[i].distance
                                  .toString(),
                              exposure: state
                                  .navigationDataToShowTracking[i].exposure
                                  .toString(),
                              airQuality: state
                                  .navigationDataToShowTracking[i].airQuality,
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox(),
            const SizedBox(
              height: 20,
            ),
            const BrandingLima(width: 200),
            const SizedBox(
              height: 20,
            ),
          ],
        );
      },
    );
  }
}

class BottomModalMonitoreo extends StatelessWidget {
  const BottomModalMonitoreo({
    Key? key,
    required this.callbackStart,
  }) : super(key: key);
  final VoidCallback callbackStart;

  @override
  Widget build(BuildContext context) {
    final navigationBloc = BlocProvider.of<NavigationBloc>(context);
    final mapBloc = BlocProvider.of<MapBloc>(context);
    // final navigationBloc = BlocProvider.of<NavigationBloc>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 20,
        ),
        Container(
          // color: Colors.red,
          width: double.infinity,
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  navigationBloc.add(DeactivateNavigationModeEvent());
                },
                icon: const Icon(Icons.arrow_back),
              ),
              const Expanded(child: SizedBox()),
              const Text(
                'Configurar acompañamiento',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          height: 1,
          color: AppTheme.gray30,
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.person,
              size: 40,
            ),
            const SizedBox(
              width: 20,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Preferences.userName == ''
                      ? 'Hola'
                      : 'Hola ${Preferences.userName.split(' ')[0]}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 18),
                ), // TODO: QUITAR ESTO, solo colocar el nomre
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          'No es necesario que tengas un destino definido, te acompañaremos en el camino y te iremos mostrando la calidad de aire y exposición a contaminación que tengas durante tu recorrido.',
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        const SizedBox(
          height: 25,
        ),
        const Text(
          'Elige un perfil para este viaje',
          style:
              TextStyle(fontWeight: FontWeight.w700, color: AppTheme.darkBlue),
        ),
        const SizedBox(
          height: 20,
        ),
        BlocBuilder<NavigationBloc, NavigationState>(
          builder: (context, state) {
            return Row(
              children: [
                Expanded(
                  child: BtnNavigationMode(
                    name: 'Peatón',
                    icon: Icons.directions_run,
                    isFocus: state.navigationProfile == 'walking',
                    callback: () {
                      navigationBloc.add(WalkingNavigationProfileEvent());
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: BtnNavigationMode(
                    name: 'Ciclista',
                    icon: Icons.directions_bike_outlined ,
                    isFocus: state.navigationProfile == 'cycling',
                    callback: () {
                      navigationBloc.add(CyclingNavigationProfileEvent());
                    },
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(
          height: 60,
        ),
        
        const BrandingLima(width: 100),
        const SizedBox(
          height: 60,
        ),
        BtnAllConfirmations(
          btnWidth: double.infinity,
          btnColor: AppTheme.primaryAqua,
          text: ' Iniciar',
          icon: Icons.near_me_rounded ,
          onPressed: () async {
            // mapBloc.add(OnStartLoading());

            // final bool willstart = await navigationBloc.postTrackingStart();
            // mapBloc.add(OnStopLoading());
            // if (willstart) {
              
            //   callbackStart();
            //   await navigationBloc.postTrackingPositionMikel();
            // }
          },
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}

class BtnEndNavigation extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color btnColor;
  const BtnEndNavigation({
    Key? key,
    required this.text,
    required this.btnColor,
    this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      // onPressed: !registerForm.isValidRegister()
      onPressed: onPressed,
      disabledColor: AppTheme.gray50,
      elevation: 0,
      color: btnColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        height: 40,
        width: 104,
        // width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              width: 8,
            ),
            Icon(
              icon ?? null,
              color: Colors.white,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}

class BottomModalRuteando extends StatelessWidget {
  const BottomModalRuteando({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationBloc = BlocProvider.of<NavigationBloc>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 1,
          color: AppTheme.gray30,
        ),
        const SizedBox(
          height: 25,
        ),
        const Text(
          'ruteando',
          style:
              TextStyle(fontWeight: FontWeight.w500, color: AppTheme.darkBlue),
        ),
        const SearchBar(),
      ],
    );
  }
}

class BottomModalRuteo extends StatelessWidget {
  final  DraggableScrollableController draggableScrollableController;
  const BottomModalRuteo({
    Key? key, required this.draggableScrollableController,
  }) : super(key: key);
  void searchActions(BuildContext context, SearchResult result)async{
    final searchBloc = BlocProvider.of<SearchBloc>(context, listen: false);
    final mapBloc = BlocProvider.of<MapBloc>(context, listen: false);
    final navigationBloc = BlocProvider.of<NavigationBloc>(context, listen: false);
    if(result.manual == true)
    {
      if(result.coordinates != null && result.streetName!= null){
         mapBloc.updateForSearchData3(coordinates: result.coordinates!, streetName: result.streetName!);
        searchBloc.add(OnActivateManualMarkerEvent());
        return;
      }
      else{
        await mapBloc.updateForSearchData();
        searchBloc.add(OnActivateManualMarkerEvent());
        return;
      }
    } 
    else{
      if(result.coordinates != null && result.streetName!= null){
         mapBloc.updateForSearchData2(coordinates: result.coordinates!, streetName: result.streetName!);
        navigationBloc.add(OnSelectingRoute(result.coordinates!));  
        return;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final navigationBloc = BlocProvider.of<NavigationBloc>(context);
    final locationBloc = BlocProvider.of<LocationBloc>(context);
    final mapBloc = BlocProvider.of<MapBloc>(context);
    // final locationBloc = BlocProvider.of<LocationBloc>(context);
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const SizedBox(
              height: 5,
            ),

            
            ToFollowWidget(
                mapBloc: mapBloc,
                draggableScrollableController: draggableScrollableController,
                child: const HeaderAcompanhando()
            ),


            // const SizedBox(
            //   height: 20,
            // ),
            state.navLoading ? const SizedBox() : SizedBox(
              // color: Colors.red,
              width: double.infinity,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      navigationBloc.add(DeactivateNavigationModeEvent());
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Expanded(child: SizedBox()),
                  const Text(
                    'Configurar ruteo',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              height: 1,
              color: AppTheme.gray30,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person,
                  size: 40,
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Preferences.userName == ''
                          ? 'Hola'
                          : 'Hola ${Preferences.userName.split(' ')[0]}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 18),
                    ), // TODO: QUITAR ESTO, solo colocar el nomre
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              'Elige un destino y te mostraremos una ruta con buena calidad de aire.',
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              'Elige un perfil para este viaje',
              style: TextStyle(
                  fontWeight: FontWeight.w900, color: AppTheme.darkBlue),
            ),
            const SizedBox(
              height: 25,
            ),
            BlocBuilder<NavigationBloc, NavigationState>(
              builder: (context, state) {
                return Row(
                  children: [
                    Expanded(
                      child: BtnNavigationMode(
                        name: 'Peatón',
                        icon: Icons.directions_run,
                        isFocus: state.navigationProfile == 'walking',
                        callback: () {
                          navigationBloc.add(WalkingNavigationProfileEvent());
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: BtnNavigationMode(
                        name: 'Ciclista',
                        icon: Icons.directions_bike_outlined ,
                        isFocus: state.navigationProfile == 'cycling',
                        callback: () {
                          navigationBloc.add(CyclingNavigationProfileEvent());
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(
              height: 25,
            ),
            const Text(
              'Ingresa un destino',
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: AppTheme.darkBlue),
            ),
            // const SearchBar(),
            const SizedBox(
              height: 25,
            ),
            SizedBox(
        // margin: const EdgeInsets.only(top: 10),
        // padding: const EdgeInsets.only(left: 60),
      
              width: double.infinity,
              child: 
              
              TextFormField(
                readOnly: true,
                onTap: () async {
                  await showSearch(context: context, delegate: SearchDestinationDelegate()).then((result) {
                    mapBloc.add(WillStopFollowingUser());
                    if (result != null){
                      searchActions(context, result);
                    }
                    

                  });
                },
                autocorrect: false,
                keyboardType:
                    TextInputType.emailAddress,
                style: const TextStyle(
                    color: Colors.black),
                decoration: InputDecotations
                    .searchInputDecoration(
          
                  // hintText: state.isRouteSelected ? mapBloc.state.forSearchStreetName : 'Donde quieres ir? x',
                  hintText: state.isRouteSelected ? mapBloc.state.forSearchStreetName : '¿A dónde quieres ir?',
                  // prefixIcon: Icons.alternate_email_outlined
                ),
                
              ),
              
        
            ),
          const SizedBox(
            height: 60,
          ),
          const BrandingLima(width: 200),
          const SizedBox(
              height: 25,
            ),
          !state.isRouteSelected ? const SizedBox() : BtnAllConfirmations(
            btnWidth: double.infinity,
            btnColor:
            state.navLoading 
            // state.navLoading || locationBloc.state.modifyForTesting 
            ? AppTheme.gray50 : AppTheme.primaryAqua,
            text: ' Iniciar',
            icon: Icons.near_me_rounded ,
            onPressed: 
            state.navLoading 
            // state.navLoading || locationBloc.state.modifyForTesting
                ? null
                : () 
                async{
                  mapBloc.add(OnStartLoading());
                  // final start = locationBloc.state.lastKnownLocation;
                  // if (start == null) return;
                  // final end = mapBloc.cameraPosition?.target;
                  // if(end == null) return;
                  
                final bool isARoute = await navigationBloc.setRouteWithPrediction();
                  // await navigationBloc.setRouteWithPrediction(start: start, end: end);
                

                  
                // TODO: LOADING
                if(isARoute){
                  if(state.isRouteSelected){
                      
                      final bool willstart =
                          await navigationBloc.postTrackingStartMikel();
                    
                      if (willstart) {
                        print('navigation will xstart');
                        await navigationBloc.postTrackingPositionMikel();
                      }
                  }

                } else{
                  //TODO: ERROR MESSAGE
                }
                mapBloc.add(OnStopLoading());

            },
                
                
                // async {
                //     mapBloc.add(OnStartLoading());
                //     final bool willstart =
                //         await navigationBloc.postTrackingStartMikel();
                //     mapBloc.add(OnStopLoading());
                //     if (willstart) {
                //       print('navigation will xstart');
                //       await navigationBloc.postTrackingPositionMikel();
                //     }
                //   },
          ),
          const SizedBox(
              height: 25,
            ),
          ],
        );
      },
    );
  }
}
