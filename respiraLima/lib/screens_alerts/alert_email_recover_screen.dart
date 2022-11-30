import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';

class AlertEmailRecoverScreen extends StatelessWidget {
   
  const AlertEmailRecoverScreen({Key? key}) : super(key: key);
  
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
                    'Si la cuenta es válida, te enviaremos un link al correo registrado.',
                    style: TextStyle(fontWeight: FontWeight.w300, color: Colors.black, fontSize: 13, decorationColor: Colors.white),
                    ),
                  const SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed:() {
                          Navigator.pop(context);
                          // final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
                          // authBloc.add(HasAccountEvent());
                          // Navigator.pushReplacementNamed(context, LoadingScreen.pageRoute);
                          // Navigator.pushReplacementNamed(context, LoginScreen.pageRoute);
                          Navigator.pop(context);
                          // Navigator.popUntil(context,ModalRoute.withName('/'));
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