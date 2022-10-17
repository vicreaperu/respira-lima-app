// import 'package:app4/blocs/blocs.dart';
// import 'package:app4/screens/screens.dart';
import 'package:app4/blocs/blocs.dart';
import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlertScreenOn extends StatelessWidget {
  const AlertScreenOn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationBloc = BlocProvider.of<NavigationBloc>(context);
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return !state.alertScreenON ? const  SizedBox() :Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30, top: 170),
              child: Container(
                // color: Colors.white,
                decoration: const BoxDecoration(
                  color: AppTheme.yellow,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const Expanded(child: SizedBox(width: 1,)),
                    const Padding(
                        padding: EdgeInsets.only(top: 8, left: 3),
                        child: Icon(
                          Icons.mobile_screen_share_outlined,
                          color: Colors.white,
                          size: 30,
                        )),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      flex: 9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                             Text(
                              '¡MANTENGA SU PANTALLA ACTIVA!',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.white,
                                  fontSize: 17,
                                  decorationColor: AppTheme.darkBlue),
                            ),
                             SizedBox(
                              height: 8,
                            ),
                             Text(
                              'Para poder realizar un correcto monitoreo, es necesario tener ACTIVA la pantalla de su celular.',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.darkBlue,
                                  fontSize: 16,
                                  decorationColor: AppTheme.darkBlue),
                            ),
                            // TextButton(
                            //     onPressed: () {
                            //       // Navigator.pushReplacementNamed(context, OnboardingScreen.pageRoute);
                            //     },
                            //     child: const Text(
                            //       'Ver dedalle',
                            //       style: TextStyle(
                            //           fontSize: 11,
                            //           color: AppTheme.darkBlue,
                            //           decoration: TextDecoration.underline),
                            //     ),
                            //   ),
                            
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          navigationBloc.add(OffAlertScreenOnEvent()); 
                        },
                        // alignment: Alignment.topCenter,
                        icon: const Icon(
                          Icons.close,
                          color: AppTheme.white,
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
