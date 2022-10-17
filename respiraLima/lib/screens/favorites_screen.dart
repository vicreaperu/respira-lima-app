import 'package:app4/models/models.dart';
import 'package:app4/themes/themes.dart';
import 'package:app4/blocs/blocs.dart';
import 'package:app4/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);
  static String pageRoute = 'Favorites';
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppTheme.white,
          appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: true,
            title: const Text(
              'Mis lugares favoritos',
              style: TextStyle(
                  color: AppTheme.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w700),
            ),
          ),
          body: SizedBox(
            // padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: AppTheme.gray30,
                  height: 1,
                  width: size.width,
                ),
                const SizedBox(
                  height: 35,
                ),
                const Padding(
                  padding:  EdgeInsets.only(left:20.0),
                  child:  Text(
                    'Mis lugares favoritos',
                    style: TextStyle(
                        color: AppTheme.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                
          
                
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child:authBloc.state.isAGuest ? 
                      const SizedBox(
                        child: Text(
                          'Regístrate para porder ingresar a tus lugares favoritos',
                        style: TextStyle(
                          color: AppTheme.gray80,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                        ),
                      )           
                    : 
                  state.loading ? const SpinKitRing(
                    size: 70,
                    color: Colors.black87,
                   ) : 
                  SizedBox(
                    height: size.height - 220,
                    child: const SingleChildScrollView(
                        child: 
                        Text(
                          'Esta ventana está en desarrollo...',
                        style: TextStyle(
                          color: AppTheme.gray80,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                        ),
                    ),
                  )
                  
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
