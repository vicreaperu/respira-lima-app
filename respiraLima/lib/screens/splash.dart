import 'package:app4/blocs/blocs.dart';
import 'package:app4/db/principal_db.dart';
import 'package:app4/screens/screens.dart';
import 'package:app4/services/auth_service.dart';
import 'package:app4/widgets/widgets.dart';
import 'package:app4/share_preferences/preferences.dart';
import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  static String pageRoute = 'splash';
  const SplashScreen({Key? key}) : super(key: key);

  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 1500), () {
    // if (!state.hasAccount) {
    if (!Preferences.isFirstTime) {
      print('To init splash ${Preferences.isFirstTime}');
      Navigator.pushReplacementNamed(context, LoadingInitialScreen.pageRoute);
    }

    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              WelcomeBackground(
                // child: Container(),
                child: !state.hasAccount
                    ? const _WelcomeButton()
                    : Container(),
              )
            ],
          ),
          // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          // floatingActionButton: Preferences.isFirstTime ? const _WelcomeButton() : Container(),
        );
      },
    );
  }
}

class _WelcomeButton extends StatelessWidget {
  const _WelcomeButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white54,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      alignment: Alignment.bottomCenter,
      child: Column(
        children: [
          MaterialButton(
            onPressed: () {
              Navigator.pushNamed(
                  context, LoadingInitialScreen.pageRoute);
            },
            color: AppTheme.primaryAqua,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Container(
              width: double.infinity,
              height: 41,
              alignment: Alignment.center,
              // padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
              child: const Text(
                'Iniciar sesión',
                style: TextStyle(
                  color: AppTheme.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5,),
          Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Container(
                  height: 1,
                  width: double.infinity,
                  color: AppTheme.gray60,
                  
                ),
              Container(
                alignment: Alignment.center,
                width: 100,
                color: Colors.white,
                child: const Text('o ingresar'),
                // child: const Text('o ingresa con'),
              )
            ],
          ),
          //// GOOGLE BUTTON ////
          //// GOOGLE BUTTON ////
          // const SizedBox(height: 10,),
          // MaterialButton(
          //   onPressed: () {
          //     // Navigator.pushReplacementNamed(context, LoadingInitialScreen.pageRoute);
          //   },
          //   color: AppTheme.white,

          //   shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(30),
          //       side: const BorderSide(color: AppTheme.aqua),
          //       ),
          //   child: Container(
          //     height: 41,
          //     width: double.infinity,
          //     alignment: Alignment.center,
              
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children:   [
          //         Image.asset(
          //           'assets/generalPics/g.png',
          //           height: 15,
          //           ),
          //         // const Icon(FontAwesomeIcons.google),
          //         const SizedBox(width: 10,),
          //         const Text(
          //           'Google',
          //           style: TextStyle(
          //             color: AppTheme.primaryAqua,
          //             fontWeight: FontWeight.w500,
          //             fontSize: 14,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          //// GOOGLE BUTTON ////
          //// GOOGLE BUTTON ////
          const SizedBox(height: 5,),
          
          MaterialButton(
            onPressed: () async {
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              await authService.askForTokenUpdating().then((isToken) async {
                print('HEREEEEEEEE!!!!!!!!!...0...!!!!!!!!!!!!!///////////');
                if(isToken){
                  print('HEREEEEEEEE!!!!!!!!!...UPDATED OK..!!!!!!!!!!!!!///////////');
                  Preferences.isAguest = true;
                  // final String token = 'asasa'; // TODO: REMOVE THIS
                  print('ISSSS A GUEST ON LOG IN SCREEN<<<<<<----');
                  final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
                  authBloc.add(HasAccountAsGuestEvent());
                  Navigator.pushReplacementNamed(context, OnboardingScreen.pageRoute);

                } else{
                  print('HEREEEEEEEE!!!!!!!!!...1...!!!!!!!!!!!!!///////////');
                  await authService.loginFirebaseAnonymous().then((token) async {
                    print('HEREEEEEEEE!!!!!!!!!...2...!!!!!!!!!!!!!///////////');
                    if (token != '') {
                      print('HEREEEEEEEE!!!!!!!!!...3...!!!!!!!!!!!!!///////////');
                      await PrincipalDB.firebaseToken(token).then((value) {
                        print('HEREEEEEEEE!!!!!!!!!...4...!!!!!!!!!!!!!///////////');
                        Preferences.isAguest = true;
                        // final String token = 'asasa'; // TODO: REMOVE THIS
                        print('ISSSS A GUEST ON LOG IN SCREEN<<<<<<----');
                        final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
                        authBloc.add(HasAccountAsGuestEvent());
                        Navigator.pushReplacementNamed(context, OnboardingScreen.pageRoute);

                      });
                      // Preferences.firebaseToken = token;
                    } else {
                      print('HERREE 222--------');
                      return;
                    }
                  });

                }
                // Navigator.pushReplacementNamed(context, LoadingInitialScreen.pageRoute);
                
              });
            },
            
            color: AppTheme.white,
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: AppTheme.aqua),
            ),
            child: Container(
              width: double.infinity,
              height: 41,
              alignment: Alignment.center,
              
              child: const Text(
                'Como invitado',
                style: TextStyle(
                  color: AppTheme.primaryAqua,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¿No tienes una cuenta?',
                style: TextStyle(color: AppTheme.gray60, fontSize: 15),
              ),
              TextButton(
                onPressed: () {
                  // Navigator.pushNamed(context, RegisterScreen.pageRoute);
                  Navigator.pushReplacementNamed(
                      context, RegisterScreen.pageRoute);
                },
                style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                        Colors.indigo.withOpacity(0.1))),
                child: const Text(
                  'Regístrate',
                  style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.darkBlue,
                      fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5,),
        ],
      ),
    );
  }
}
