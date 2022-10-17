// import 'package:app4/blocs/blocs.dart';
// import 'package:app4/screens/screens.dart';
import 'package:app4/blocs/blocs.dart';
import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlertPlaces extends StatelessWidget {
  const AlertPlaces({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationBloc = BlocProvider.of<NavigationBloc>(context);
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return !state.placesAlert ? Container()  : Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 50.0, right: 50, top: 40),
              child: Container(
                // color: Colors.white,
                decoration: const BoxDecoration(
                  color: AppTheme.green,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const Expanded(child: SizedBox(width: 1,)),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 8),
                      child: Image.asset(
                        'assets/icons/places_alert_icon.png',
                        width: 35,
                      ),
                    ),
                    const Expanded(
                        child: SizedBox(
                      width: 10,
                    )),
                    Expanded(
                      flex: 9,
                      child: Container(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // {place_alerts: [{lat: -12.040647, lon: -77.039575, name: Paseo del Canal de Monserrate, distance: 0.0324271596300611}]}
                            Text(
                              state.placeAlerData.first.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontSize: 14,
                                  decorationColor: Colors.white),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              'El lugar se encuentra a una distancia de ${(state.placeAlerData.first.distance * 1000).round()} metros' ,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                  fontSize: 11,
                                  decorationColor: Colors.white),
                            ),
                            TextButton(
                                onPressed: () async{
                                  navigationBloc.add(OnPlaceAlertShowDetailsEvent());
                                  navigationBloc.add(OnLoadingEvent());
                                  await navigationBloc.getPlacePreferencesLikeScore();
                                  navigationBloc.add(OffLoadingEvent());
                                  // Navigator.pushReplacementNamed(context, OnboardingScreen.pageRoute);
                                },
                                child: const Text(
                                  'Ver dedalle',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.white,
                                      decoration: TextDecoration.underline),
                                )),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          navigationBloc.add(OffPlacesAlertEvent());
                        },
                        // alignment: Alignment.topCenter,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        )),
                    // const Expanded(child: SizedBox(width: 1,)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
