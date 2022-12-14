import 'package:app4/blocs/blocs.dart';
import 'package:app4/themes/themes.dart';
import 'package:app4/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationModeSheet extends StatelessWidget {
  final Size areaScreen;

  const NavigationModeSheet({Key? key, required this.areaScreen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationBloc = BlocProvider.of<NavigationBloc>(context);
    final mapBloc = BlocProvider.of<MapBloc>(context);
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        // return state.navigationState != 0 && state.isOnArea? 
        return state.navigationState != 0? 
        const SizedBox() 
        : 
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          color: Colors.white70,
          height: areaScreen.height,
          width: areaScreen.width,
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                        Text(
                          
                              '¬°Empecemos!',
                         
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 32, color: AppTheme.primaryBlue),
                        ), 
                    
                    
                   
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
               
                
                Column(
          
                  children: [
                    CardModeSelector(
                      picName: 'assets/generalPics/ruteoImg.png',
                      title: 'Tengo un destino',
                      btnColor: state.navLoading ? AppTheme.gray50 : AppTheme.primaryAqua ,
                      subTitle: 'Coloca un punto de llegada y te recomendaremos la ruta con mejor calidad del aire.',
                      callback: state.navLoading ? null : () 
                      // async{
                      //   await navigationBloc.getNavigationPreferences().then((value){
                      //     print('preferences----> getNavigationPreferences $value');
                      //   });
                      //   await navigationBloc.getFavoriteDestinations().then((value){
                      //     print('preferences----> getFavoriteDestinations $value');
                      //   });
                      // }
                  
                      {
                        final int locationState = mapBloc.isOnAreaFastQuestion();
                        if(locationState == 1) {
                            mapBloc.add(WillStartFollowingUser());
                            navigationBloc.add(RuteoNavigationModeEvent());
                        } else if (locationState == 2){
                          navigationBloc.isOnTheArea().then((isOnArea) {
                            if (isOnArea) {
                              mapBloc.add(WillStartFollowingUser());
                              navigationBloc.add(RuteoNavigationModeEvent());
                              print('OUT OF AREAAAAAAAA GAAAAAA');
                              // navigationBloc.add(RuteoNavigationModeEvent());
                            } else {
                              showDialog(context: context, builder: _buildPopupDialog);
                            }
                          });
                        } else{
                          showDialog(context: context, builder: _buildPopupDialog);
                        }        
                        },





                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    
                    CardModeSelector(
                      picName: 'assets/generalPics/monitoreoImg.png',
                      title: 'Saldr√© sin un destino fijo',
                      btnColor: state.navLoading ? AppTheme.gray50 : AppTheme.primaryAqua ,
                      subTitle: 'No es necesario que definas un punto de llegada, solo define tu perfil y monitorea la calidad del aire del camino.',
                      callback: state.navLoading ? null : ()  {


                        final int locationState = mapBloc.isOnAreaFastQuestion();
                        if(locationState == 1) {
                            mapBloc.add(WillStartFollowingUser());
                            navigationBloc.add(MonitoreoNavigationModeEvent());
                        } else if (locationState == 2){
                          navigationBloc.isOnTheArea().then((isOnArea) {
                            if (isOnArea) {
                              mapBloc.add(WillStartFollowingUser());
                              navigationBloc.add(MonitoreoNavigationModeEvent());
                              // navigationBloc.add(RuteoNavigationModeEvent());
                            } else {
                              showDialog(context: context, builder: _buildPopupDialog);
                            }
                          });
                        }  else{
                          showDialog(context: context, builder: _buildPopupDialog);
                        } 
                          },
                      ),
                
                
                  
                 
                    
                  ],
                ),         
              ],
            ),
          ),
        );
      },
    );
  }
}

class CardModeSelector extends StatelessWidget {
  const CardModeSelector({
    Key? key,
    required this.title, required this.subTitle, required this.callback, required this.picName, required this.btnColor
  }) : super(key: key);
  final String title;
  final String subTitle;
  final String picName;
  final VoidCallback? callback;
  final Color btnColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            fit: BoxFit.cover,
            picName,
            width: double.infinity,
           height: 235,
           ),
        ),
        Container(
          width: double.infinity,
          height: 235,
          decoration: BoxDecoration(
            color: Color.fromRGBO(26, 74, 138, 0.8),
            borderRadius: BorderRadius.circular(20)
            ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 2,
                  child: SizedBox(height: 20,)),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.w500,
                    fontSize: 20
                    ),
                  ),
                const Expanded(
                  flex: 1,
                  child: SizedBox(height: 10,)),
                Text(
                  subTitle,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.w300,
                    fontSize: 14
                  ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    BtnAllConfirmations(
                      btnWidth: 100,
                        btnColor: btnColor,
                        text: 'Empezar',
                        icon: Icons.arrow_forward_ios_rounded,
                        onPressed: callback
                      ),
                  ],
                ),
              ],
            ),
          ),
          ),
      ],
    );
  }
}


Widget _buildPopupDialog(BuildContext context) {
  final locationBloc = BlocProvider.of<LocationBloc>(context);
  final navigationBloc = BlocProvider.of<NavigationBloc>(context);
  return  AlertDialog(
    title: const Text('Fuera de zona'),
    content:  Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const  <Widget>[
        Text('Tienes la opci√≥n de explorar la zona de estudio. Te ubicaremos en un punto c√©ntrico que te permitir√° desplazarte a los alrededores.'),
      ],
    ),
    actions: <Widget>[
      TextButton(
        onPressed:() {
          Navigator.of(context).pop();
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
          locationBloc.add(WillModifyForTesting());
          Navigator.of(context).pop();
          navigationBloc.add(MonitoreoNavigationModeEvent());
          
          // Navigator.pop(context);
          // final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
          // authBloc.add(HasAccountEvent());
          // Navigator.pushReplacementNamed(context, LoadingScreen.pageRoute);
        }, 
        child: const Text(
          'Vamos',
          style: TextStyle(color: AppTheme.darkBlue),
          )),

    ],
  );
}