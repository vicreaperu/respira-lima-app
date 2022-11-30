import 'package:app4/blocs/blocs.dart';
import 'package:app4/themes/themes.dart';
import 'package:app4/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingAlert extends StatelessWidget {
  final Size screenSize;
  const RatingAlert({Key? key, required this.screenSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationBloc = BlocProvider.of<NavigationBloc>(context);
    double rate = 10 ;
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return state.navigationState !=3 ? Container() : Container(
          height: screenSize.height,
          width: screenSize.width,
          color: const Color.fromRGBO(8, 20, 34, 0.8),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Container(
              // color: Colors.white,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              width: 300,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(onPressed:() {
                            print('not postTrackingScore - CLOSE BTN');
                            navigationBloc.add(NoRatingEvent());
                          },
                          icon: const Icon(Icons.close)),
                        ],
                      ),
                      
                      const Text(
                        'Recorrido finalizado',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            fontSize: 14,
                            decorationColor: Colors.white),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            alignment: Alignment.bottomCenter,
                            height: 16,
                            child: Text(
                              state.navigationDataToShowEnding.isNotEmpty ? state.navigationDataToShowEnding["total_time"].toString() : '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.gray80,
                                  fontSize: 15),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Container(
                            alignment: Alignment.bottomCenter,
                            height: 16,
                            child: Text(
                              'min (${state.navigationDataToShowEnding.isNotEmpty ? state.navigationDataToShowEnding["distance"] : ""}km)',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.gray80,
                                  fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ProfileAndModeAvatar(
                          profile: state.navigationProfile == 'walking' ? 'Peatón' : 'Ciclista',
                          profileIcon: state.navigationProfile == 'walking' ? Icons.directions_run : Icons.directions_bike_outlined ,
                          mode: state.navigationMode == 'monitoreo' ? 'Acompañamiento' : 'Ruteo',
                          modeIcon: Icons.pin_drop_rounded),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          _CustomColumWithIcon(
                            title: 'Exposición PM2.5',
                            textToShow: '${state.navigationDataToShowEnding["exposure"]}µg/m³',
                            boxColor: AppTheme.gray10,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          _CustomColumWithIcon(
                            title: 'Calidad del aire',
                            textToShow: state.navigationDataToShowEnding['air_quality'],
                            boxColor: Color(int.parse(state.navigationDataToShowEnding['color'])) ,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        'Califica el recorrido',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontSize: 12,
                            decorationColor: Colors.white),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RatingBar.builder(
                            allowHalfRating: true,
                            itemBuilder: (context, _) =>
                                const Icon(Icons.star, color: Colors.amber),
                            glowColor: Colors.amber,
                            unratedColor: AppTheme.gray30,
                            onRatingUpdate: (value) {
                              rate = value;
                              print('The rating value is: $value');
                            },
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BtnSendRatingNavigation(
                            text: 'Enviar',
                            onPressed: () {
                              if(rate != 10){
                                print('postTrackingScore');
                                navigationBloc.add(EndNavigationEvent(rate));
                              } 
                              
                              else{
                                print('not postTrackingScore');
                                navigationBloc.add(NoRatingEvent());
                              }
                            },
                          )
                        ],
                      ),
                      const SizedBox(
                            height: 25,
                          ),
                    ]
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CustomColumWithIcon extends StatelessWidget {
  const _CustomColumWithIcon({
    Key? key,
    required this.textToShow,
    required this.title,
    required this.boxColor,
  }) : super(key: key);

  final String textToShow;
  final String title;
  final Color boxColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),),
        const SizedBox(
          height: 6,
        ),
        Container(
          decoration: BoxDecoration(
              color: boxColor,
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          height: 50,
          width: 117,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              title == 'Exposición PM2.5'
                  ? const SizedBox()
                  : Icon(textToShow == 'Buena'
                          ? Icons.sentiment_satisfied_alt_outlined
                          : textToShow == 'Moderada'
                              ? Icons.sentiment_neutral_outlined
                              : textToShow == 'Mala'
                                  ? Icons.sentiment_very_dissatisfied
                                  : Icons.sentiment_very_dissatisfied_outlined // MUY MALA
                      ),
              const SizedBox(
                width: 2,
              ),
              Text(
                textToShow,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BtnSendRatingNavigation extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const BtnSendRatingNavigation({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      // onPressed: !registerForm.isValidRegister()
      onPressed: onPressed,
      disabledColor: AppTheme.gray50,
      elevation: 0,
      color: AppTheme.aqua,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        height: 40,
        // width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
