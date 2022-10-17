import 'package:app4/screens/screens.dart';
import 'package:app4/themes/themes.dart';
import 'package:app4/widgets/widgets.dart';
import 'package:flutter/material.dart';

class OnboardingScreen3 extends StatelessWidget {
  static String pageRoute = 'onboardingScrens3';
  const OnboardingScreen3({Key? key}) : super(key: key);
  
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
                  Navigator.pushReplacementNamed(context, OnboardingScreen1.pageRoute);
                },
                percent: 1,
                saltarColor: AppTheme.primaryAqua,
                childText: const Text4Omboarding(
                  title: 'Te mantenemos informado',
                  listInline: [
                    TextSpan(text: 'Iremos enviando alertas durante tu recorrido para que te sientas seguro de estar en un lugar saludable.', style: textStyle1),
                  ],
                ),               
                child: Image.asset(
                  'assets/onboardingPics/onboardingBG3.png',
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
