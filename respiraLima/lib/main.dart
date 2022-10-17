import 'package:app4/blocs/blocs.dart';
import 'package:app4/db/principal_db.dart';
import 'package:app4/implementation/background_local_repository.dart';
import 'package:app4/native_code/backgroud_location.dart';
import 'package:app4/providers/providers.dart';
import 'package:app4/screens/login_screen.dart';
import 'package:app4/screens/welcome_screen.dart';
import 'package:app4/services/services.dart';
import 'package:app4/share_preferences/share_preferences.dart';
import 'package:app4/themes/themes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:app4/screens/screens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';


void main() async {
 

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Preferences.init();
  await PrincipalDB.init();
  Location locationPlugin = Location();
  
  runApp(MultiBlocProvider(providers: [
    BlocProvider(create: ((context) => GpsBloc(locationPlugin: locationPlugin))),
    BlocProvider(create: ((context) => AppDataBloc( predictionsGridService: PredictionsGridService(), appDataService: AppDataService() ))),
    BlocProvider(create: ((context) => LocationBloc(
      // backgroundLocationRepository: BackgroundLocationRepositoryImpl(BackgroundLocation())
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
  child: const MapsApp()));
  print('DB after instance');
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
        ChangeNotifierProvider(create: (_) => MapService()),
        ChangeNotifierProvider(create: (_) => PredictionsGridService()),
        ChangeNotifierProvider(create: (_) => NavigationService()),
        ChangeNotifierProvider(create: (_) => RouteService()),
        ChangeNotifierProvider(create: (_) => SocketService()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => PlacesPreferencesService()),
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
          MapScreen.pageRoute:(context) => const MapScreen(),
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
        },
        theme: AppTheme.lightThem,
      ),
      
    );
  }
}
