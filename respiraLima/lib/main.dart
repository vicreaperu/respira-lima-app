import 'package:app4/blocs/blocs.dart';
import 'package:app4/db/principal_db.dart';
import 'package:app4/helpers/helpers.dart';
import 'package:app4/implementation/implementation.dart';
import 'package:app4/native_code/native_code.dart';
import 'package:app4/providers/providers.dart';
import 'package:app4/screens/welcome_screen.dart';
import 'package:app4/services/services.dart';
import 'package:app4/share_preferences/share_preferences.dart';
import 'package:app4/themes/themes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:app4/screens/screens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';


void main() async {
 

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Preferences.init();
  await PrincipalDB.init();
  Location locationPlugin = Location();
  
  runApp(isIOS ? Phoenix(
    child: _MainWidget(locationPlugin: locationPlugin),
  ) : _MainWidget(locationPlugin: locationPlugin),
  );
}

class _MainWidget extends StatelessWidget {
  const _MainWidget({
    Key? key,
    required this.locationPlugin,
  }) : super(key: key);

  final Location locationPlugin;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(create: ((context) => GpsBloc(locationPlugin: locationPlugin))),
      BlocProvider(create: ((context) => UserAppDataBloc(userAppInformationService: UserAppInformationService()))),
      BlocProvider(create: ((context) => AppDataBloc( predictionsGridService: PredictionsGridService(), appDataService: AppDataService() ))),
      BlocProvider(create: ((context) => LocationBloc(
        location: locationPlugin,
        backgroundLocationRepository: BackgroundLocationRepositoryImpl(BackgroundLocation(),
        )
        ))),
      BlocProvider(
        create:(context) => 
          AuthBloc(authService: AuthService(), initTime: DateTime.now())),
      BlocProvider(
        create: ((context) =>
          SearchBloc(traficService: TraficService(), navigationService: NavigationService()))),
      BlocProvider(
        create: ((context) => 
          NavigationBloc(
            locationPlugin: locationPlugin,
            // backgroundLocationRepository: BackgroundLocationRepositoryImpl(BackgroundLocation()),
            appDataBloc: BlocProvider.of<AppDataBloc>(context), 
            locationBloc: BlocProvider.of<LocationBloc>(context), 
            navigationService: NavigationService(),
            placesPreferencesService: PlacesPreferencesService(),
            routeService: RouteService(),
            authService: AuthService(),
            ))),
      BlocProvider(
          create: ((context) =>
              MapBloc(
                locationBloc: BlocProvider.of<LocationBloc>(context), 
                navigationBloc: BlocProvider.of<NavigationBloc>(context), 
                mapService: MapService(),
                // socketService: SocketService()
                ))),
    ], 
  
    child: const MapsApp()
  
    
    );
  }
}

class MapsApp extends StatelessWidget {
  const MapsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppDataService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => AuthFormProvider()),
        ChangeNotifierProvider(create: (_) => FavoritiesFormProvider()),
        ChangeNotifierProvider(create: (_) => MapService()),
        ChangeNotifierProvider(create: (_) => PredictionsGridService()),
        ChangeNotifierProvider(create: (_) => NavigationService()),
        ChangeNotifierProvider(create: (_) => RouteService()),
        ChangeNotifierProvider(create: (_) => SocketService()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => PlacesPreferencesService()),
        ChangeNotifierProvider(create: (_) => UserAppInformationService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Maps App',
        // initialRoute: OnboardingScreen.pageRoute,
        initialRoute: SplashScreen.pageRoute,

        routes: {
          WelcomeScreen.pageRoute:(context) => const WelcomeScreen(),
          LoadingScreen.pageRoute: (context) => const LoadingScreen(),
          LoadingInitialScreen.pageRoute: (context) => const LoadingInitialScreen(),
          LoginScreen.pageRoute: (context) => const LoginScreen(),
          RegisterScreen.pageRoute: (context) => const RegisterScreen(),
          SettingsScreen.pageRoute:(context) => const SettingsScreen(),
          RestorePasswordScreen.pageRoute: (context) => const RestorePasswordScreen(),
          SplashScreen.pageRoute:(context) => const SplashScreen(),
          TileBuilderPage.pageRoute:(context) => const TileBuilderPage(),
          OnboardingScreen.pageRoute:(context) => const OnboardingScreen(),
          OnboardingScreen1.pageRoute:(context) => const OnboardingScreen1(),
          OnboardingScreen2.pageRoute:(context) => const OnboardingScreen2(),
          OnboardingScreen3.pageRoute:(context) => const OnboardingScreen3(),
          HistoryScreen.pageRoute:(context) => const HistoryScreen(),
          FavoritesScreen.pageRoute:(context) => const FavoritesScreen(),
          PoliticsScreen.pageRoute:(context) => const PoliticsScreen(),
          HelpScreen.pageRoute:(context) => const HelpScreen(),
          MapScreen.pageRoute:(context) => const MapScreen(),
          MapScreenAndroid.pageRoute:(context) => const MapScreenAndroid(),
          MapScreeniOS.pageRoute:(context) => const MapScreeniOS(),
          NavigationPreferencesScreen.pageRoute:(context) => const NavigationPreferencesScreen(),



          BackgroundScreen.pageRoute:(context) => const BackgroundScreen(),
          BackgroundScreen2.pageRoute:(context) => const BackgroundScreen2(),


          ResumeRoutePage.pageRoute:(context) => const ResumeRoutePage(), // DELETE THIS
        },
        theme: AppTheme.lightThem,
      ),
      
    );
  }
}
