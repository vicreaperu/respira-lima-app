import 'package:app4/blocs/blocs.dart';
import 'package:app4/screens/screens.dart';
import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class OnboardingBackground extends StatelessWidget {
  final Widget childText;
  final Widget child;
  final VoidCallback callbackBack;
  final VoidCallback callbackForward;
  final double percent;
  final Color saltarColor;
  final bool isColorBack;
  const OnboardingBackground({
    Key? key, 
    this.isColorBack = false,
    required this.callbackForward,
    required this.callbackBack,
    required this.child, 
    required this.childText, required this.percent, required this.saltarColor
    }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final Size sizeScreen = MediaQuery.of(context).size;
    return  Scaffold(
      body: Stack(
        children: [
          
          Container(
            alignment: Alignment.bottomCenter,
            width: double.infinity,
            height: double.infinity,
            color: AppTheme.white,
            child: child,
          ),
      
          SingleChildScrollView(
            child: SizedBox(
              // color: Colors.white60,
              width: double.infinity,
              height: 450,
              child: Column(
                children: [
                  Expanded(child: Container(
                    height: 20,
                    // color: Colors.red,
                    )),
                 Expanded(
                  flex: 2,
                   child: Container(
                    // color: Colors.red,
                     child: Image.asset(
                        'assets/logos/logoLima.png',
                        width: 250,
                        // fit: BoxFit.fill,
                        // width: sizeScreen.width*0.7,
                        // height: width*0.05,
                      ),
                   ),
                 ),
                //  const Expanded(child: SizedBox(height: 30)),
                 Expanded(
                  flex: 4,
                  child: Container(
                    // color: Colors.blue,
                    child: childText)
                  ),
                
                ],
              ),
            ),
          ),
         Positioned(
          bottom: 70,
          right: 30,
           child: Column(
            // mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
             children: [
               Row(
                 children: [
                  CircleAvatar(
                       backgroundColor: isColorBack ? AppTheme.primaryAqua : Colors.transparent,
                       radius: 18,
                       child : IconButton(
                         icon: Icon(
                         Icons.arrow_back_ios_new_rounded,
                         size: 15,
                         color: isColorBack ? Colors.white : Colors.transparent,
                           ),
                         onPressed: callbackBack,
                       ),
                     ),
                  const SizedBox(width: 15,),
                   CircularPercentIndicator(
                      radius: 40.0,
                      lineWidth: 4.0,
                      percent: percent,
                      center:   CircleAvatar(
                        backgroundColor: AppTheme.primaryAqua,
                        radius: 29,
                        child : IconButton(
                          icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 20.0,
                          color: Colors.white,
                            ),
                          onPressed: callbackForward,
                        ),
                      ) ,
                      backgroundColor: AppTheme.gray10,
                      progressColor: AppTheme.primaryAqua,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                 ],
               ),
                TextButton(onPressed:() {
                  final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
                  print('.....NOT A GUEST 55');
                  authBloc.add(HasSimpleAccountEvent());
                  Navigator.pushReplacementNamed(context, LoadingScreen.pageRoute);
                }, child: Text(
                  'Saltar',
                  style: TextStyle(
                    color: saltarColor,
                    fontSize: 25,
                    fontWeight: FontWeight.w500
                  ),
                  ),
                  ),
             ],
           ),
         ),
        //  Positioned(
        //   bottom: 70,
        //   right: 30,
        //    child: Column(
        //      children: [
        //        CircularPercentIndicator(
        //           radius: 40.0,
        //           lineWidth: 4.0,
        //           percent: percent,
        //           center:   CircleAvatar(
        //             backgroundColor: AppTheme.primaryAqua,
        //             radius: 29,
        //             child : IconButton(
        //               icon: const Icon(
        //               Icons.arrow_forward_ios_rounded,
        //               size: 20.0,
        //               color: Colors.white,
        //                 ),
        //               onPressed: callback,
        //             ),
        //           ) ,
        //           backgroundColor: AppTheme.gray10,
        //           progressColor: AppTheme.primaryAqua,
        //           circularStrokeCap: CircularStrokeCap.round,
        //         ),
        //         TextButton(onPressed:() {
                  
        //         }, child: Text(
        //           'Saltar',
        //           style: TextStyle(
        //             color: saltarColor,
        //             fontSize: 25,
        //             fontWeight: FontWeight.w500
        //           ),
        //           ),
        //           ),
        //      ],
        //    ),
        //  ),
         
        ],
      ),
    );
  }
}

