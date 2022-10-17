import 'package:app4/themes/themes.dart';
import 'package:app4/widgets/widgets.dart';
import 'package:flutter/material.dart';

import 'screens.dart';

class OnboardingScreen2 extends StatelessWidget {
  static String pageRoute = 'onboardingScrens2';
  const OnboardingScreen2({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final Size sizeScreen = MediaQuery.of(context).size;
    const textStyle1 =  TextStyle(height: 1.5, fontSize: 18, color: AppTheme.darkBlue, fontWeight: FontWeight.w400) ;
    return Scaffold(
          body: Stack(
            children: [
              OnboardingBackground(
                callbackBack: () {
                  
                },
                callbackForward: () {
                  Navigator.pushReplacementNamed(context, OnboardingScreen3.pageRoute);
                },
                percent: 0.66,
                saltarColor: AppTheme.primaryAqua,
                childText: const Text4Omboarding(
                  title: '¡Tú eliges!',
                  listInline: [
                    TextSpan(text: 'Puedes monitorear la calidad del aire que vas respirando o buscar un destino específico y obtener recomendaciones sobre la ruta más limpia que puedes seguir.', style: textStyle1),
                  ],
                ),               
                child: Image.asset(
                  'assets/onboardingPics/onboardingBG2.png',
                  width: double.infinity,
                  // height: sizeScreen.height*0.5,
                  fit: BoxFit.cover,
                  ), 
              )
            ],
          ),
        );
  }
}
