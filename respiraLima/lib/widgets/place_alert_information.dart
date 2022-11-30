import 'package:app4/blocs/blocs.dart';
import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PlaceAlertInformation extends StatelessWidget {
  final Size screenSize;
  const PlaceAlertInformation({Key? key, required this.screenSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationBloc = BlocProvider.of<NavigationBloc>(context);
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return !state.placeAlertShowDetails ? Container() : Container(
          height: screenSize.height,
          width: screenSize.width,
          color: Colors.white,
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Container(
              // color: Colors.white,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              width: screenSize.width,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    SizedBox(
                      width: screenSize.width,
                      child: Stack(
                        children: [
                          Container(
                            width: screenSize.width,
                            alignment: Alignment.center,
                            child: state.placeAlerData.isNotEmpty ?
                                  Image.network( state.placeAlerData.first.imgUrl) : 
                                  const Icon(Icons.image_not_supported_outlined, size: 150,),
                          ),
                          
                          Column(
                            children: [
                              const SizedBox(height: 30,),
                              IconButton(onPressed:() {
                                navigationBloc.add(OffPlaceAlertShowDetailsEvent());
                                if(navigationBloc.state.locationScored){
                                  navigationBloc.postPlacePreferencesLikeScore();
                                }
                                },
                                iconSize: 50,
                                icon: const CircleAvatar(
                                  radius: 90,
                                  backgroundColor: Colors.white, 
                                  child: Icon(Icons.arrow_back, color: AppTheme.gray60, size: 23,),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: screenSize.width,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    state.placeAlerData.isNotEmpty ? state.placeAlerData.first.name : 'Lugar desconocido',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.blue,
                                        fontSize: 20,
                                        decorationColor: Colors.white),
                                  ),
                                ),
                                RatingBar.builder(
                                  allowHalfRating: false,
                                  itemCount: 1,
                                  initialRating: navigationBloc.state.locationLiked ? 1 : 0,
                                  itemBuilder: (context, _) =>
                                      const Icon(Icons.favorite, color: Colors.green),
                                      // const CircleAvatar(backgroundColor: AppTheme.gray10,child: Icon(EvaIcons.heart, color: Colors.green),),
                                  glowColor: Colors.green,
                                  unratedColor: AppTheme.gray30,
                                  onRatingUpdate: (value) {
                                    if(value == 1){
                                      navigationBloc.add(LikedEvent());
                                    } else{
                                      navigationBloc.add(UnLikedEvent());
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              RatingBar.builder(
                                allowHalfRating: true,
                                itemBuilder: (context, _) =>
                                    const Icon(Icons.star, color: Colors.amber,),
                                glowColor: Colors.amber,
                                unratedColor: AppTheme.gray30,
                                itemSize: 25,
                                initialRating: navigationBloc.state.locationStars,
                                onRatingUpdate: (value) {
                                  navigationBloc.add(SetStartsEvent(value));
                                  
                                }, 
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              state.loading ?
                              const SpinKitRing(
                                  size: 20,
                                  lineWidth: 3,
                                  color: Colors.black87,
                                ) :
                              Text('${navigationBloc.state.locationStars} (${navigationBloc.state.totalStars} votos)', style: TextStyle(color: AppTheme.darkBlue, fontSize: 15),)
                            ],
                          ),
                          const SizedBox(
                            height: 35,
                          ),
                          Text(
                            'Información del ${state.placeAlerData.isNotEmpty ? state.placeAlerData.first.type : 'lugar'}:',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppTheme.darkBlue,
                                fontSize: 16),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          
                        
                          Text(
                            state.placeAlerData.isNotEmpty ? state.placeAlerData.first.description : 'Descripción no disponible',
                            style: const TextStyle(
                                fontWeight: FontWeight.w300,
                                color: AppTheme.darkBlue,
                                fontSize: 15,
                                decorationColor: Colors.white),
                          ),
                          
                      ],),
                    ),
                    
                    
                  ]
                  ),
            ),
          ),
        );
      },
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
