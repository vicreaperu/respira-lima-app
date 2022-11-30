import 'package:app4/db/principal_db.dart';
import 'package:app4/delegates/delegates.dart';
import 'package:app4/implementation/implementation.dart';
import 'package:app4/models/models.dart';
import 'package:app4/providers/providers.dart';
import 'package:app4/screens_alerts/screens_alerts.dart';
import 'package:app4/share_preferences/internal_validations.dart';
import 'package:app4/themes/themes.dart';
import 'package:app4/blocs/blocs.dart';
import 'package:app4/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const FavoritesScreen({Key? key, this.scaffoldKey}) : super(key: key);
  static String pageRoute = 'Favorites';
  static final debouncer = Debouncer(milliseconds: 1000);
  Future<bool> searchActions(BuildContext context, SearchResult result)async{
    final searchBloc = BlocProvider.of<SearchBloc>(context, listen: false);
    final mapBloc = BlocProvider.of<MapBloc>(context, listen: false);
    final navigationBloc = BlocProvider.of<NavigationBloc>(context, listen: false);
    bool response = false;
    if(result.manual == true)
    {
      if(result.coordinates != null && result.streetName!= null){
         mapBloc.updateForSearchData3(coordinates: result.coordinates!, streetName: result.streetName!);
        searchBloc.add(OnActivateManualMarkerEvent());
        navigationBloc.add(OnFavoritiesSpecialEvent());
        response = true;
      }
      else{
        await mapBloc.updateForSearchData();
        searchBloc.add(OnActivateManualMarkerEvent());
        navigationBloc.add(OnFavoritiesSpecialEvent());
        response = true;
      }
    } 
    else{
      if(result.coordinates != null && result.streetName!= null){
         mapBloc.updateForSearchData2(coordinates: result.coordinates!, streetName: result.streetName!);
        navigationBloc.add(OnSelectingRoute(result.coordinates!));  
        response = true;
      }
    }
    return response;
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
    final mapBloc = BlocProvider.of<MapBloc>(context, listen: false);
    final navigationBloc = BlocProvider.of<NavigationBloc>(context, listen: false);
    final favoritiesForm = Provider.of<FavoritiesFormProvider>(context);
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppTheme.white,
          appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: true,
            title: const Text(
              'Mis lugares favoritos',
              style: TextStyle(
                  color: AppTheme.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w700),
            ),
          ),
          body: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: SizedBox(
              // padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: AppTheme.gray30,
                    height: 1,
                    width: size.width,
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  const Padding(
                    padding:  EdgeInsets.only(left:25.0),
                    child:  Text(
                      'Mis lugares favoritos',
                      style: TextStyle(
                          color: AppTheme.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  
            
                  
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child:authBloc.state.isAGuest ? 
                        const SizedBox(
                          child: Text(
                            'Regístrate para porder ingresar a tus lugares favoritos',
                          style: TextStyle(
                            color: AppTheme.gray80,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                          ),
                        )           
                      : 
                    state.loading ? const SpinKitRing(
                      size: 70,
                      color: Colors.black87,
                     ) : 
                    SizedBox(
                      height: size.height - 220,
                      child: SingleChildScrollView(
                          child: 
                          Column(
                            children: [
                              const Text(
                                'Guarda los destinos que visitas con más frecuencia y accede rápidamente a estas rutas.',
                              style: TextStyle(
                                color: AppTheme.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w300),
                              ),
                              const SizedBox(height: 40,),
                              TextFormField(
                                readOnly: true,
                                onChanged:(value){
                                 
                                },
                              onTap: () async {
                                await showSearch(context: context, delegate: SearchDestinationDelegate(isFavorite: true)).then((result) async{
                                  mapBloc.add(WillStopFollowingUser());
                                  if (result != null){
                                    searchActions(context, result).then((value) {
                                      if(value){
                                        if(scaffoldKey != null){
                                          if(scaffoldKey!.currentState!.isDrawerOpen){
                                            scaffoldKey!.currentState!.closeDrawer();
                                          }
                                        }
                                        Navigator.pop(context);
                                      }

                                    });
                                  }
                                });
                              },
                                autocorrect: false,
                                keyboardType: TextInputType.streetAddress,
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecotations.favoritiesInputDecoration(
                                    hintText: state.isFavoriteRouteSelected ? mapBloc.state.forSearchStreetName : 'Añadir un destino favorito',
                                    // hintText: 'Plaza de armas',
                                    sufixIcon: Icons.search),
                              ),
                              
                              const SizedBox(height: 35,),
                              Container(
                                color: AppTheme.gray30,
                                height: 1,
                                width: size.width,
                              ),
                              const SizedBox(height: 40,),
                              state.isFavoriteRouteSelected ?
                               Form(
                                key: favoritiesForm.formKeyFavorities,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                 child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('¿Con qué nombre guardarás esta dirección?', style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600),),
                                    const SizedBox(height: 20,),
                                    TextFormField(
                                      onChanged:(value){
                                        favoritiesForm.tag = value;
                                      },
                                      validator: (value) {
                                        return InternalValidations.nameValidator(value) ? null : 'Nombre inválido';
                                        
                                      },
                                                           
                                      autocorrect: false,
                                      keyboardType: TextInputType.emailAddress,
                                      style: const TextStyle(color: Colors.black),
                                      decoration: InputDecotations.favoritiesInputDecoration(
                                          hintText: 'Ejm: Casa, Trabajo, Universidad, etc',
                                          // hintText: 'Plaza de armas',
                                          // sufixIcon: Icons.search
                                          ),
                                    ),
                                    SizedBox(
                                      child: GestureDetector(
                                        onTap: state.loading ? null : () async {
                                          if(favoritiesForm.isValidForm()){
                                            print('Favorities---> valid ${favoritiesForm.tag}');
                                            final double lat = mapBloc.state.forSearchLatLng.latitude;
                                            final double lng = mapBloc.state.forSearchLatLng.longitude;
                                            final String streetName = mapBloc.state.forSearchStreetName;
                                            navigationBloc.add(OnLoadingEvent());
                                            await navigationBloc.postFavoriteDestinations(tag: favoritiesForm.tag, streetName: streetName, coordinates: LatLng(lat, lng)).then((value) async {
                                              print('Preferences------------>>>>>  $value');
                                              await PrincipalDB.insertFavoritePlace(FavoritePlacesModel(
                                                streetName: streetName, 
                                                lat: lat, 
                                                lng: lng, 
                                                tag: favoritiesForm.tag,
                                                idF: value,
                                                )
                                              ).then((value) async {
                                                await PrincipalDB.getAllFavoritePlace().then((value) {
                                                  navigationBloc.add(AddUpdateFavoritePlacesDataEvent(value));
                                                  navigationBloc.add(OffSelectingFavoriteRoute());
                                                });
                                              });
                                            });

                                            navigationBloc.add(OffLoadingEvent());

                                            
                                            

                                          } else{
                                            print('Favorities---> NO valid ${favoritiesForm.tag}');
                                          }
                                      },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: const[
                                          Text('Guardar', style: TextStyle(color: AppTheme.aqua),),
                                          Icon(Icons.check_circle, color: AppTheme.aqua,)
                                        ],),),
                                    ),
                                    const SizedBox(height: 30,),
                                    SizedBox(
                                      child: GestureDetector(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: const[
                                          Text('Cancelar', style: TextStyle(color: AppTheme.lightRed),),
                                          Icon(Icons.cancel, color: AppTheme.lightRed,)
                                        ],),
                                        onTap: () async {
                                          navigationBloc.add(OffSelectingFavoriteRoute());
                                      },),
                                    )
                                  ],
                                 ),
                               )
                               : 
                               state.favoritePlacesData.isNotEmpty ?

                               Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Destinos guardados', style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700),),
                                  const SizedBox(height: 15,),
                                  for(int i = state.favoritePlacesData.length - 1; i >= 0; i--)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(children: [
                                      Container(
                                        alignment: Alignment.center,
                                        height: 35,
                                        width: 35,
                                        decoration:  const BoxDecoration(
                                          color: AppTheme.gray30,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(7)
                                          )),
                                        // padding: const EdgeInsets.only(right: 15),
                                        child: const Icon(Icons.favorite, color: AppTheme.blue, size: 18,),
                                      ),
                                      const SizedBox(width: 13,),
                                      SizedBox(
                                        width: 140,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(state.favoritePlacesData[i].tag, style: const TextStyle(fontWeight: FontWeight.w700),),
                                            Text(state.favoritePlacesData[i].streetName, style: const TextStyle(color: AppTheme.gray60, fontSize: 12),)
                                          ],
                                        ),
                                      ),
                                      const Expanded(flex: 1, child: SizedBox(width: 20,)),
                                      GestureDetector(
                                        onTap: () {
                                          print('DELETE----');
                                          showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (context) => AlertFavoritePlaceScreen(favPlace: state.favoritePlacesData[i])
                                              );
                                          
                                        },
                                      child: const Icon(Icons.delete, color: AppTheme.blue, size: 15,),),
                                      const SizedBox(width: 44,),
                                      GestureDetector(
                                        onTap: () {
                                          final LatLng destination = LatLng(state.favoritePlacesData[i].lat, state.favoritePlacesData[i].lng);
                                          mapBloc.updateForSearchData2(coordinates: destination, streetName: state.favoritePlacesData[i].streetName);
                                          navigationBloc.add(RuteoNavigationModeEvent());
                                          navigationBloc.add(OnSelectingRoute(destination));
                                          mapBloc.drawMyDestination(destination);
                                          mapBloc.moveCamera(destination, 0, null);
                                          mapBloc.add(WillStopFollowingUser());
                                          print('Favorities---> ${state.favoritePlacesData[i].tag}');
                                          print('Favorities---> ${state.favoritePlacesData[i].streetName}');
                                          if(scaffoldKey != null){
                                          if(scaffoldKey!.currentState!.isDrawerOpen){
                                            scaffoldKey!.currentState!.closeDrawer();
                                          }
                                        }
                                          Navigator.pop(context);
                                        },
                                        child: Row(
                                        children: const [
                                          Text('Ir', style: TextStyle(color: AppTheme.blue, fontWeight: FontWeight.w600),),
                                          // SizedBox(width: 15,),
                                          Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.blue, size: 15,),
                                          ],
                                      ),),
                                    ],),
                                  )
                                ],
                               )
                               : 
                               Column(
                                children: [
                                  const SizedBox(height: 40,),
                                  Image.asset(
                                    fit: BoxFit.cover,
                                    'assets/icons/favoritiesPlaces.png',
                                    width: 130,  
                                  height: 130,
                                  ),
                                  const SizedBox(height: 35,),
                                  const Text(
                                    'Aún no tienes lugares favoritos guardados',
                                  style: TextStyle(
                                    color: AppTheme.gray60,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ),
                    )
                    
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
