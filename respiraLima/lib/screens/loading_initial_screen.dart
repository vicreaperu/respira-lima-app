import 'package:app4/blocs/blocs.dart';
import 'package:app4/screens/login_screen.dart';
import 'package:app4/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoadingInitialScreen extends StatelessWidget {
  static const String pageRoute = 'InitialLoading';
  const LoadingInitialScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Scaffold(
            body: state.hasAccount
            // body: Preferences.firebaseToken != '' && Preferences.userEmail != ''
                ? const LoadingScreen()
                :
                // const SettingsScreen() :
                const LoginScreen());
      },
    );
  }
}
