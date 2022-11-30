import 'package:app4/blocs/navigation/navigation_bloc.dart';
import 'package:app4/share_preferences/preferences.dart';
import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationPreferencesScreen extends StatefulWidget {
   
  const NavigationPreferencesScreen({Key? key}) : super(key: key);
  static String pageRoute = 'navigatioPreferences';
  static bool peaton = false;
  static bool ciclista = false;

  @override
  State<NavigationPreferencesScreen> createState() => _NavigationPreferencesScreenState();
}

class _NavigationPreferencesScreenState extends State<NavigationPreferencesScreen> {
  
  bool peaton = Preferences.userCiclistPeaton == 1 ? true : false;
  bool ciclista = Preferences.userCiclistPeaton == 2 ? true : false;
  bool update = false;
  int navigationPreference = Preferences.userAirQualityPref;
  @override
  Widget build(BuildContext context) {
    final navigationBloc = BlocProvider.of<NavigationBloc>(context, listen: false);
    print('-----------------> ${Preferences.userCiclistPeaton}');
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
        'Preferencias de navegación',
        style: TextStyle(color: AppTheme.black),          
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
           child: Padding(
             padding: const EdgeInsets.symmetric(horizontal: 30),
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
               children:  [
                const SizedBox(height: 40,),
                const Text(
                  'Preferencias de navegación',
                  style: TextStyle(
                      color: AppTheme.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 30,),
                        
                const Text('¿Cón qué perfil te identificas más?', style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600),),
                const SizedBox(height: 15,),
                Card4NavigationPreference(picName: 'assets/generalPics/walkingPic.png', title: 'Peatón', child: 
                  Checkbox(
                    fillColor: MaterialStateProperty.all(AppTheme.blue),
                    value: peaton,
                    onChanged: (value) async{
                      print('ON Peaton $value');
                      setState(() {
                        peaton = value ?? false;
                        update = true;
                      });

                      if(peaton) {
                        ciclista = false;
                        await Preferences.setUserCiclistPeaton(1);
                        navigationBloc.add(WalkingNavigationProfileEvent());
                      } else{
                        await Preferences.setUserCiclistPeaton(0);
                      }
                     
                    })
                  ,),
                const SizedBox(height: 15,),
                Card4NavigationPreference(picName: 'assets/generalPics/ciclyngPic.png', title: 'Ciclista', child: 
                  Checkbox(
                    fillColor: MaterialStateProperty.all(AppTheme.blue),
                    value: ciclista,
                    onChanged: (value) async {
                      print('ON Ciclist $value');
                      setState(()  {
                        ciclista = value ?? false;
                        update = true;
                      });
                        if(ciclista){
                          peaton = false;
                          await Preferences.setUserCiclistPeaton(2);
                          navigationBloc.add(CyclingNavigationProfileEvent());
                        } else{
                          await Preferences.setUserCiclistPeaton(0);
                        }
                      // if (!registerForm.isLoading){
                      //   Preferences.areTermsAccepted =
                      //       value ?? false;
                      //   setState(() {});
                      // }
                    }),
                  ),
                const SizedBox(height: 40,),
                const Text('¿Qué ruta prefieres que te generemos?', style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600),),

                const SizedBox(height: 15,),
                Row(
                  children:  [
                    Expanded(child: BtnRoutePreference(
                      title: 'Baja contaminación', 
                      selected: navigationPreference == 1,  // Baja contaminacion = 1, menor distancias = 2
                      callback: () async {
                        setState(() {
                          navigationPreference = 1;
                          update = true;
                        });
                        await Preferences.setUserAirQualityPref(1);
                        navigationBloc.add(PollutantNavigationAirQualityPreferencesEvent());
                        
                    },)),
                    const SizedBox(width: 10,),
                    Expanded(child: BtnRoutePreference(
                      title: 'Menor distancia', 
                      selected: navigationPreference == 2 , // Baja contaminacion = 1, menor distancias = 2
                      callback: () async {
                        setState(() {
                          navigationPreference = 2;
                          update = true;
                        });
                        await Preferences.setUserAirQualityPref(2);
                        navigationBloc.add(TimeNavigationAirQualityPreferencesEvent());
                    },)),

                  ],
                 ),
                const SizedBox(height: 20,),
                 
               ],
             ),
           ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:  Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: MaterialButton(
              onPressed: !update? null : () async {
                setState(() {
                  update = false;
                });
                if(Preferences.userCiclistPeaton != 0 && Preferences.userAirQualityPref != 0){
                  await navigationBloc.putNavigationPreferences().then((value) {
                    print('Preferences-----> updated??? $value');
                  });
                }
              },
              color: !update ? AppTheme.gray30 : AppTheme.primaryAqua,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              child: Container(
                width: double.infinity,
                height: 40,
                alignment: Alignment.center,
                // padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                child: const Text(
                  'Guardar',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

class BtnRoutePreference extends StatelessWidget {
  final VoidCallback callback;
  final String title;
  final bool selected;
  const BtnRoutePreference({
    Key? key, required this.callback, required this.title, required this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: callback,
      
      color: selected ? AppTheme.blue : Colors.white,
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: AppTheme.gray30),
      ),
      child: Container(
        width: 150,
        height: 41,
        alignment: Alignment.center,
        
        child:  Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class Card4NavigationPreference extends StatelessWidget {
  final String picName;
  final String title;
  final Widget child;
  const Card4NavigationPreference({
    Key? key, required this.picName, required this.title, required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color:AppTheme.gray30, width: 2)

        ),
      child: Row(children: [
        ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
        child: Image.asset(
          fit: BoxFit.cover,
          picName,
          width: 80,  
         height: 80,
        ),
      ), 
      const SizedBox(width: 20,),
      Text(title, style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w600),),
      const Expanded(child: SizedBox(width: 50,)),
      child,
      ],
      ),
     );
  }
}