import 'dart:io';

import 'package:app4/blocs/blocs.dart';
import 'package:app4/db/db.dart';
import 'package:app4/helpers/helpers.dart';
import 'package:app4/screens/screens.dart';
import 'package:app4/share_preferences/preferences.dart';
import 'package:app4/themes/themes.dart';
import 'package:app4/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:restart_app/restart_app.dart';
import 'package:url_launcher/url_launcher.dart';

class SideMenu extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const SideMenu({Key? key, required this.scaffoldKey}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
    final navigationBloc =
        BlocProvider.of<NavigationBloc>(context, listen: false);
    final userAppDataBloc =
        BlocProvider.of<UserAppDataBloc>(context, listen: false);
    final size = MediaQuery.of(context).size;
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: BlocBuilder<UserAppDataBloc, UserAppDataState>(
            builder: (context, state) {
              return BlocBuilder<NavigationBloc, NavigationState>(
                builder: (context, navState) {
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      SizedBox(
                        height: size.height * 0.2,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person,
                              size: 40,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Preferences.userName == ''
                                      ? 'Invitado'
                                      : Preferences.userName,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18),
                                ), // TODO: QUITAR ESTO, solo colocar el nomre
                                Text(Preferences.userEmail),
                              ],
                            ),
                          ],
                        ),
                      ),

                      _TitleFormat(
                        text: 'Historial',
                        icon: Icons.history,
                        callback: () async {
                          if (!authBloc.state.isAGuest) {
                            navigationBloc
                                .getTrackingHistory()
                                .then((value) {});
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HistoryScreen()),
                          );
                          // if(!authBloc.state.isAGuest) {
                          //   await navigationBloc.getTrackingHistory().then((value) {
                          //     Navigator.pushNamed(context, HistoryScreen.pageRoute);
                          //   });
                          // }
                        },
                      ),
                      _TitleFormat(
                        text: 'Favoritos',
                        icon: Icons.favorite,
                        color: navState.isNavigating ? AppTheme.gray50 : AppTheme.black,
                        callback: navState.isNavigating ? null : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FavoritesScreen(
                                      scaffoldKey: scaffoldKey,
                                    )),
                          );
                        },
                      ),
                      _TitleFormat(
                        text: 'Configurar perfil',
                        icon: Icons.person,
                        callback: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SettingsScreen()),
                          );
                          // if(!authBloc.state.isAGuest) Navigator.pushNamed(context, SettingsScreen.pageRoute);
                        },
                      ),
                      _TitleFormat(
                        text: 'Preferencias de navegación',
                        icon: Icons.alt_route_outlined,
                        color: navState.isNavigating ? AppTheme.gray50 : AppTheme.black,
                        callback: navState.isNavigating ? null : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const NavigationPreferencesScreen()),
                          );
                          // if(!authBloc.state.isAGuest) Navigator.pushNamed(context, SettingsScreen.pageRoute);
                        },
                      ),

                      _TitleFormat4Links(
                        text: 'Conoce más',
                        icon: Icons.article,
                        isUp: state.showListConoceMas,
                        callback: () async {
                          if (!state.showListConoceMas) {
                            userAppDataBloc.add(ShowListConoceMasEvent());
                            if (!userAppDataBloc.state.arePoliticsData ||
                                !userAppDataBloc.state.areQuestions) {
                              await userAppDataBloc
                                  .getPoliticsAndQuestions()
                                  .then((hasData) {
                                if (hasData) {
                                  print('appData---> HAS DATA UUUUUUU ');
                                } else {
                                  print('appData---> HAS DATA UUUUUUU ');
                                }
                              });
                            }
                          } else {
                            userAppDataBloc.add(HideListConoceMasEvent());
                          }
                          // if(!authBloc.state.isAGuest) Navigator.pushNamed(context, SettingsScreen.pageRoute);
                        },
                        callback4Links: () async {
                          if (!state.showListConoceMas) {
                            userAppDataBloc.add(ShowListConoceMasEvent());
                            if (!userAppDataBloc.state.arePoliticsData ||
                                !userAppDataBloc.state.areQuestions) {
                              await userAppDataBloc
                                  .getPoliticsAndQuestions()
                                  .then((hasData) {
                                if (hasData) {
                                  print('appData---> HAS DATA UUUUUUU ');
                                } else {
                                  print('appData---> HAS DATA UUUUUUU ');
                                }
                              });
                            }
                          } else {
                            userAppDataBloc.add(HideListConoceMasEvent());
                          }
                        },
                      ),
                      !state.showListConoceMas
                          ? const SizedBox()
                          : state.loadingUserAppData
                              ? const SpinKitRing(
                                  size: 20,
                                  lineWidth: 2,
                                  color: Colors.black87,
                                )
                              : Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(left: 25.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (int i = state.conoceMas.length - 1;
                                          i >= 0;
                                          i--)
                                        TextButton(
                                          onPressed: (() async {
                                            final Uri _url = Uri.parse(
                                                state.conoceMas[i].linkUrl);
                                            if (!await launchUrl(_url)) {
                                              throw 'Could not launch $_url';
                                            }
                                          }),
                                          style: ButtonStyle(
                                              overlayColor:
                                                  MaterialStateProperty.all(
                                                      Colors.indigo
                                                          .withOpacity(0.1))),
                                          child: Text(
                                            state.conoceMas[i].linkName,
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: AppTheme.blue,
                                                fontWeight: FontWeight.w900,
                                                decoration:
                                                    TextDecoration.underline),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                      _TitleFormat4Links(
                        text: 'Enlaces de interés',
                        icon: Icons.open_in_new,
                        isUp: state.showListEnlacesDeInteres,
                        callback: () async {
                          if (!state.showListEnlacesDeInteres) {
                            userAppDataBloc
                                .add(ShowListEnlacesDeInteresEvent());
                            if (!userAppDataBloc.state.arePoliticsData ||
                                !userAppDataBloc.state.areQuestions) {
                              await userAppDataBloc
                                  .getPoliticsAndQuestions()
                                  .then((hasData) {
                                if (hasData) {
                                  print('appData---> HAS DATA UUUUUUU ');
                                } else {
                                  print('appData---> HAS DATA UUUUUUU ');
                                }
                              });
                            }
                          } else {
                            userAppDataBloc
                                .add(HideListEnlacesDeInteresEvent());
                          }
                          // if(!authBloc.state.isAGuest) Navigator.pushNamed(context, SettingsScreen.pageRoute);
                        },
                        callback4Links: () async {
                          if (!state.showListEnlacesDeInteres) {
                            userAppDataBloc
                                .add(ShowListEnlacesDeInteresEvent());
                            if (!userAppDataBloc.state.arePoliticsData ||
                                !userAppDataBloc.state.areQuestions) {
                              await userAppDataBloc
                                  .getPoliticsAndQuestions()
                                  .then((hasData) {
                                if (hasData) {
                                  print('appData---> HAS DATA UUUUUUU ');
                                } else {
                                  print('appData---> HAS DATA UUUUUUU ');
                                }
                              });
                            }
                          } else {
                            userAppDataBloc
                                .add(HideListEnlacesDeInteresEvent());
                          }
                        },
                      ),
                      !state.showListEnlacesDeInteres
                          ? const SizedBox()
                          : state.loadingUserAppData
                              ? const SpinKitRing(
                                  size: 20,
                                  lineWidth: 2,
                                  color: Colors.black87,
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(left: 25.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (int i =
                                              state.enlacesDeInteres.length - 1;
                                          i >= 0;
                                          i--)
                                        TextButton(
                                          onPressed: (() async {
                                            final Uri _url = Uri.parse(state
                                                .enlacesDeInteres[i].linkUrl);
                                            if (!await launchUrl(_url)) {
                                              throw 'Could not launch ';
                                            }
                                          }),
                                          style: ButtonStyle(
                                              overlayColor:
                                                  MaterialStateProperty.all(
                                                      Colors.indigo
                                                          .withOpacity(0.1))),
                                          child: Text(
                                            state.enlacesDeInteres[i].linkName,
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: AppTheme.blue,
                                                fontWeight: FontWeight.w900,
                                                decoration:
                                                    TextDecoration.underline),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 2,
                        width: size.width,
                        color: AppTheme.gray30,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      _TitleFormat(
                        text: 'Ayuda',
                        icon: Icons.help_center,
                        callback: () async {
                          print(
                              'appData---> .   ${userAppDataBloc.state.areQuestions}');
                          if (!userAppDataBloc.state.areQuestions) {
                            userAppDataBloc
                                .getPoliticsAndQuestions()
                                .then((hasData) {
                              if (hasData) {
                                print('appData---> HAS DATA UUUUUUU ');
                              } else {
                                print('appData---> HAS DATA UUUUUUU ');
                              }
                            });
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HelpScreen()),
                          );
                          // Navigator.pop(context);
                          // Navigator.pushNamed(context, HelpScreen.pageRoute);
                        },
                      ),

                      _TitleFormat(
                        text: 'Políticas de privacidad',
                        icon: Icons.security_sharp,
                        callback: () {
                          print(
                              'appData---> .   ${userAppDataBloc.state.arePoliticsData}');
                          if (!userAppDataBloc.state.arePoliticsData) {
                            userAppDataBloc
                                .getPoliticsAndQuestions()
                                .then((hasData) {
                              if (hasData) {
                                print('appData---> HAS DATA UUUUUUU ');
                              } else {
                                print('appData---> HAS DATA UUUUUUU ');
                              }
                            });
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PoliticsScreen()),
                          );
                        },
                      ),

                      const SizedBox(
                        height: 50,
                      ),
                      // LOGO AND BUTTOM --------
                      const BrandingLima(
                        width: 350,
                        center: false,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // LOGO AND BUTTOM --------
                      const BrandingQaira(
                        width: 500,
                      ),

                      const SizedBox(
                        height: 50,
                      ),
                      navigationBloc.state.isNavigating
                          ? const SizedBox()
                          : Container(
                              width: double.infinity,
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () async {
                                  await Preferences.cleanLitePreferences();
                                  authBloc.add(NotHasAccountEvent());

                                  await PrincipalDB.clearUserInfo()
                                      .then((value) {
                                    if (value) {
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
                                    overlayColor: MaterialStateProperty.all(
                                        AppTheme.primaryOrange)),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.logout,
                                      color: AppTheme.red,
                                    ),
                                    SizedBox(
                                      width: 7,
                                    ),
                                    Text(
                                      'Cerrar sesión',
                                      style: TextStyle(
                                          fontSize: 13, color: AppTheme.red),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TitleFormat extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? callback;
  final Color color;
  const _TitleFormat({
    Key? key,
    required this.text,
    required this.icon,
    required this.callback, this.color = AppTheme.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(
        text,
        style:
            TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
      onTap: callback,
    );
  }
}

class _TitleFormat4Links extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback callback;
  final VoidCallback callback4Links;
  final bool isUp;
  const _TitleFormat4Links({
    Key? key,
    required this.text,
    required this.icon,
    required this.callback,
    required this.callback4Links,
    required this.isUp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.black,
      ),
      trailing: IconButton(
        onPressed: callback4Links,
        icon: Icon(
            isUp ? Icons.arrow_drop_up_sharp : Icons.arrow_drop_down_sharp),
        color: AppTheme.blue,
      ),
      title: Text(
        text,
        style:
            const TextStyle(color: AppTheme.black, fontWeight: FontWeight.w800),
      ),
      onTap: callback,
    );
  }
}
