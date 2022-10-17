import 'package:animate_do/animate_do.dart';
import 'package:app4/blocs/blocs.dart';
import 'package:app4/db/db.dart';
import 'package:app4/models/models.dart';
import 'package:app4/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';


class ManualMarker extends StatelessWidget {
  const ManualMarker({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: ((context, state) {
        return state.displayManualMarker ? const _ManualMarkerBody() : const SizedBox();
    } )
    );
  }
}



class _ManualMarkerBody extends StatelessWidget {
   
  const _ManualMarkerBody({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final navigationBloc   = BlocProvider.of<NavigationBloc>(context);
    final searchBloc = BlocProvider.of<SearchBloc>(context);
    // final locationBloc = BlocProvider.of<LocationBloc>(context);
    final mapBloc      = BlocProvider.of<MapBloc>(context);
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [

          const Positioned(
            top: 70,
            left: 20,
            child: _BtnBack(),
            ),

          Center(
            
            child: Transform.translate(
              offset: const Offset(0, 350),
              child: BounceInDown(
                from: 150,
                child: BlocBuilder<MapBloc, MapState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        Container(
                          color: Colors.white70,
                          child: Text(state.forSearchStreetName, style: const TextStyle(fontSize: 15),)),
                        const Icon(Icons.location_on_rounded, size: 40,),
                      ],
                    );
                  },
                ),
                ),
            ),
          ),
          // CONFIMR BUTTOM
          Positioned(
            bottom: 10,
            right: 40,
            child: FadeInUp(
              child: MaterialButton(
                elevation: 0,
                shape: const StadiumBorder(),
                color: Colors.black,
                minWidth: size.width - 120,
                child: const  Text(
                  'Confirmar destino',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300 ),
                ),
                onPressed: () 
                {
                  navigationBloc.add(OnSelectingRoute(mapBloc.cameraPosition!.target));               
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
        ],
      ),
    );
  }
}

class _BtnBack extends StatelessWidget {
  const _BtnBack({
    Key? key,
  }) : super(key: key);
  void closeManualMarker(BuildContext context){
    final searchBloc = BlocProvider.of<SearchBloc>(context);
    searchBloc.add(OnDeactivateManualMarkerEvent());
  }
  @override
  Widget build(BuildContext context) {
    return  FadeInLeft(
      // duration: const Duration(microseconds: 500),
      child: CircleAvatar(
        maxRadius: 30,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black,),
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

