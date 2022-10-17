import 'package:app4/screens/screens.dart';
import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';

class AlertEmailValidationScreen extends StatelessWidget {
   
  const AlertEmailValidationScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
         child: SingleChildScrollView(
          child: Container(
            // color: Colors.white,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              
            ),
            width: 280,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/generalPics/dialogP1.png',
                        width: 100,
                        ),
                    ],
                  ),
                  const SizedBox(height: 15,),
                  const Text(
                    'Validación de correo electrónico',
                    style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize:14, decorationColor: Colors.white),
                    ),
                  const SizedBox(height: 15,),
                  const Text(
                    'Antes de continuar, revisa tu bandeja e ingresa al link que te hemos enviado para seguir configurando tu cuenta.',
                    style: TextStyle(fontWeight: FontWeight.w300, color: Colors.black, fontSize: 13, decorationColor: Colors.white),
                    ),
                  const SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed:() {
                          // Navigator.pop(context);
                          // final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
                          // authBloc.add(HasAccountEvent());
                          // Navigator.pushReplacementNamed(context, LoadingScreen.pageRoute);
                          Navigator.pushReplacementNamed(context, OnboardingScreen.pageRoute);
                        }, 
                        child: const Text(
                          'Entendido',
                          style: TextStyle(color: AppTheme.darkBlue),
                          )),
                    ],
                  )
                ]
              ),
            ),
          ),
         ),
      );
  }
}