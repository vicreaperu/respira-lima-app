import 'package:app4/screens/screens.dart';
import 'package:app4/themes/themes.dart';
import 'package:app4/widgets/widgets.dart';
import 'package:flutter/material.dart';

class OnboardingScreen1 extends StatelessWidget {
  static String pageRoute = 'onboardingScrens1';
  const OnboardingScreen1({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final Size sizeScreen = MediaQuery.of(context).size;
     const textStyle1 =  TextStyle(height: 1.5, fontSize: 18, color: AppTheme.darkBlue, fontWeight: FontWeight.w400) ;
    const textStyle2 =  TextStyle(height: 1.5, fontSize: 18, color: AppTheme.darkBlue, fontWeight: FontWeight.w800) ;
    return Scaffold(
          body: Stack(
            children: [
              OnboardingBackground(
                callbackBack: () {
                  
                },
                callbackForward: () {
                  Navigator.pushReplacementNamed(context, OnboardingScreen2.pageRoute);
                },
                percent: 0.33,
                saltarColor: AppTheme.white,
                childText: const Text4Omboarding(
                  title: '¡Hola José!',
                listInline: [
                TextSpan(text: 'Con ', style: textStyle1),
                TextSpan(text: 'Respira Lima ', style: textStyle2 ),
                TextSpan(text: 'podrás conocer la ', style: textStyle1 ),
                TextSpan(text: 'calidad del aire ', style: textStyle2 ),
                TextSpan(text: 'que respiras en Lima Metropolitana.', style: textStyle1 ),
              ],),               
                child: Image.asset(
                  'assets/onboardingPics/onboardingBG1.png',
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

