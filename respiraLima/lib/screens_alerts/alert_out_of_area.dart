// import 'package:app4/blocs/blocs.dart';
// import 'package:app4/screens/screens.dart';
import 'package:app4/blocs/blocs.dart';
import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlertOutOfArea extends StatelessWidget {
  const AlertOutOfArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationBloc = BlocProvider.of<NavigationBloc>(context);
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return !state.outOffAreaAlert ? const  SizedBox() :Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 50.0, right: 50, top: 40),
              child: Container(
                // color: Colors.white,
                decoration: const BoxDecoration(
                  color: AppTheme.red,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const Expanded(child: SizedBox(width: 1,)),
                    const Padding(
                        padding: EdgeInsets.only(top: 8, left: 8),
                        child: Icon(
                          Icons.place_rounded,
                          color: Colors.white,
                          size: 30,
                        )),
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
                          children: const [
                             Text(
                              '¡Fuera de área!',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontSize: 14,
                                  decorationColor: Colors.white),
                            ),
                             SizedBox(
                              height: 8,
                            ),
                             Text(
                              'Se encuentra fuera del área de estudio, no podemos determinar el nivel de contaminación de su actual posición',
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                  fontSize: 11,
                                  decorationColor: Colors.white),
                            ),
                              SizedBox(
                              height: 20,
                            ),
                            // TextButton(
                            //     onPressed: () {
                            //       // Navigator.pushReplacementNamed(context, OnboardingScreen.pageRoute);
                            //     },
                            //     child: const Text(
                            //       'Ver dedalle',
                            //       style: TextStyle(
                            //           fontSize: 11,
                            //           color: AppTheme.white,
                            //           decoration: TextDecoration.underline),
                            //     )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 5,),
                    // IconButton(
                    //     onPressed: () {
                    //       navigationBloc.add(OffPollutionAlertEvent()); 
                    //     },
                    //     // alignment: Alignment.topCenter,
                    //     icon: const Icon(
                    //       Icons.close,
                    //       color: Colors.white,
                    //     ),
                    //   ),
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
