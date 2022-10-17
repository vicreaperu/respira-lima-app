import 'dart:io';

import 'package:app4/blocs/blocs.dart';
import 'package:app4/db/db.dart';
import 'package:app4/screens/screens.dart';
import 'package:app4/share_preferences/preferences.dart';
import 'package:app4/themes/themes.dart';
import 'package:app4/widgets/widgets.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:restart_app/restart_app.dart';

class SideMenu extends StatelessWidget {
   
  const SideMenu({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
    final navigationBloc = BlocProvider.of<NavigationBloc>(context, listen: false);
    final size = MediaQuery.of(context).size;
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: size.height*0.2,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
             
                    const Icon(
                      Icons.person,
                      size: 40,
                    ),
                    const SizedBox(width: 20,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Preferences.userName == '' ? 'Invitado' : Preferences.userName,
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                        ), // TODO: QUITAR ESTO, solo colocar el nomre
                        Text(Preferences.userEmail),
                      ],
                    ),
                  ],
                ),
              ),
             
              _TitleFormat(text: 'Historial', icon: Icons.history, callback: () async {
              
                if(!authBloc.state.isAGuest) {
                  navigationBloc.getTrackingHistory().then((value) {
                  });
                }
                Navigator.pushNamed(context, HistoryScreen.pageRoute);
                // if(!authBloc.state.isAGuest) {
                //   await navigationBloc.getTrackingHistory().then((value) {
                //     Navigator.pushNamed(context, HistoryScreen.pageRoute);
                //   });
                // }
              },
              ),
              _TitleFormat(text: 'Favoritos', icon: EvaIcons.heart, callback: () {
                Navigator.pushNamed(context, FavoritesScreen.pageRoute);
              },
              ),
              _TitleFormat(text: 'Configurar perfil', icon: Icons.person, callback: () {
                
                Navigator.pushNamed(context, SettingsScreen.pageRoute);
                // if(!authBloc.state.isAGuest) Navigator.pushNamed(context, SettingsScreen.pageRoute);
              },
              ),
              const SizedBox(height: 10,),
              Container(
                height: 2,
                width: size.width,
                color: AppTheme.gray30,
                ),
              const SizedBox(height: 10,),
              _TitleFormat(text: 'Ayuda', icon: Icons.help_outline_sharp, callback: () {
                Navigator.pushNamed(context, HelpScreen.pageRoute);
              },
              ),
              
              _TitleFormat(text: 'Políticas de privacidad', icon: Icons.policy, callback: () {
                Navigator.pushNamed(context, PoliticsScreen.pageRoute);
              },
              ),

              const SizedBox( height: 50,),
              // LOGO AND BUTTOM --------
              const BrandingLima(width: 350, center: false,),
              const SizedBox(height: 20,),
              // LOGO AND BUTTOM --------
              const BrandingQaira(width: 500,),

              const SizedBox(height: 50,),
              navigationBloc.state.isNavigating ? const SizedBox() : Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed:  () async {
                    Preferences.cleanPreferences();
                    authBloc.add(NotHasAccountEvent());
                    
                      await PrincipalDB.clearUserInfo().then((value) {
                        if(value){
                          // Navigator.pushReplacementNamed(context, SplashScreen.pageRoute);
                          if (Platform.isAndroid) {
                            Restart.restartApp();
                          } else {
                            Phoenix.rebirth(context); 
                          }
                        }
                      });
                    


                    // Navigator.pushNamed(context, SplashScreen.pageRoute);
                    // Navigator.pushReplacementNamed(context, SplashScreen.pageRoute);
                    
                    
                  }, 
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(AppTheme.primaryOrange)
                  ),
                  child: Row(
                    children: const  [
                      Icon(Icons.logout, color: AppTheme.red,),
                      SizedBox(width: 7,),
                      Text('Cerrar sesion', 
                      style: TextStyle(fontSize: 13, color: AppTheme.red),),
                    ],
                  ),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleFormat extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback callback;
  const _TitleFormat({
    Key? key, required this.text, required this.icon, required this.callback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.black,),
      title: Text(text, style: const TextStyle(color: AppTheme.black, fontWeight: FontWeight.w800),),
      onTap: callback,
    );
  }
}
