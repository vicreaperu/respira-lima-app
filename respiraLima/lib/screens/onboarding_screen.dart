import 'package:app4/blocs/blocs.dart';
import 'package:app4/providers/providers.dart';
import 'package:app4/screens/screens.dart';
import 'package:app4/themes/themes.dart';
import 'package:app4/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatelessWidget {
  static String pageRoute = 'onboardingScrens';
  const OnboardingScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final Size sizeScreen = MediaQuery.of(context).size;
     const textStyle1 =  TextStyle(height: 1.5, fontSize: 18, color: AppTheme.darkBlue, fontWeight: FontWeight.w400) ;
    const textStyle2 =  TextStyle(height: 1.5, fontSize: 18, color: AppTheme.darkBlue, fontWeight: FontWeight.w800) ;
    final onboardingProvider = Provider.of<OnboardingProvider>(context);
    final List<String> titles = ['¡Hola 👋 !', '¡Tú eliges!', 'Te mantenemos informado'];
    final List<String> bg = ['assets/onboardingPics/onboardingBG1.png', 'assets/onboardingPics/onboardingBG2.png', 'assets/onboardingPics/onboardingBG3.png'];
    final List<double> percents = [0.33, 0.66, 1];
    final List<List<InlineSpan>> inlineSpan = [
      [
        const TextSpan(text: 'Con ', style: textStyle1),
        const TextSpan(text: 'Respira Lima ', style: textStyle2 ),
        const TextSpan(text: 'podrás conocer la ', style: textStyle1 ),
        const TextSpan(text: 'calidad del aire ', style: textStyle2 ),
        const TextSpan(text: 'que respiras en Lima Metropolitana.', style: textStyle1 ),
      ],
      [
        const TextSpan(text: 'Puedes monitorear la calidad del aire que vas respirando o buscar un destino específico y obtener recomendaciones sobre la ruta más limpia que puedes seguir.', style: textStyle1),
      ],
      [
        const TextSpan(text: 'Iremos enviando alertas durante tu recorrido para que te sientas seguro de estar en un lugar saludable.', style: textStyle1),
      ]
    ];
    return Scaffold(
          body: Stack(
            children: [
              OnboardingBackground(
                isColorBack: onboardingProvider.currentPage != 0,
                callbackBack: () {
                  
                  if (onboardingProvider.currentPage > 0){
                    onboardingProvider.currentPage --;
                  } 
                  // else{
                  //   onboardingProvider.currentPage = 2;
                  // }
                },
                callbackForward: () {
                  if (onboardingProvider.currentPage < 2){
                    onboardingProvider.currentPage ++;
                  } 
                  else{
                    final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
                    authBloc.add(HasAccountEvent());
                    Navigator.pushReplacementNamed(context, LoadingScreen.pageRoute);
                  }
                  // Navigator.pushReplacementNamed(context, OnboardingScreen2.pageRoute);
                },
                percent: percents[onboardingProvider.currentPage],
                saltarColor: onboardingProvider.currentPage == 0 ? AppTheme.white : AppTheme.primaryAqua,
                childText:  Text4Omboarding(
                title: titles[onboardingProvider.currentPage],
                listInline: inlineSpan[onboardingProvider.currentPage]
                ),               
                child: Image.asset(
                  bg[onboardingProvider.currentPage],
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

