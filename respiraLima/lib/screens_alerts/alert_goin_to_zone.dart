import 'package:app4/blocs/blocs.dart';
import 'package:app4/screens/screens.dart';
import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlertGoingToZone extends StatelessWidget {
  const AlertGoingToZone({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final Size areaScreen = MediaQuery.of(context).size;
    return _alertToSimulateZone(areaScreen);
  }

  Widget _alertToSimulateZone(Size areaScreen) {
    return Container(
    alignment: Alignment.center,
    color: Color.fromARGB(204, 191, 190, 190),
    height: areaScreen.height,
    width: areaScreen.width,
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
              'Fuera de zona',
              style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize:14, decorationColor: Colors.white),
              ),
            const SizedBox(height: 15,),
            const Text(
              'Tienes la opción de explorar la zona de estudio. Te ubicaremos en un punto céntrico que te permitirá desplazarte a los alrededores.',
              style: TextStyle(fontWeight: FontWeight.w300, color: Colors.black, fontSize: 13, decorationColor: Colors.white),
              ),
            const SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed:() {
                    // Navigator.pop(context);
                    // final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
                    // authBloc.add(HasAccountEvent());
                    // Navigator.pushReplacementNamed(context, LoadingScreen.pageRoute);
                  }, 
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppTheme.darkBlue),
                    )),
                TextButton(
                  onPressed:() {
                    // Navigator.pop(context);
                    // final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
                    // authBloc.add(HasAccountEvent());
                    // Navigator.pushReplacementNamed(context, LoadingScreen.pageRoute);
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