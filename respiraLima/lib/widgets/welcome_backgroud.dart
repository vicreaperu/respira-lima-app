import 'package:app4/themes/themes.dart';
import 'package:app4/widgets/widgets.dart';
import 'package:flutter/material.dart';

class WelcomeBackground extends StatelessWidget {
  final Widget child;
  const WelcomeBackground({Key? key, required this.child}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final Size sizeScreen = MediaQuery.of(context).size;
    return  Scaffold(
      body: Stack(
        children: [
          Container(
            color: AppTheme.white,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            width: double.infinity,
            height: sizeScreen.height*0.55,
            child: Column(
              children: [
               Expanded(child: SizedBox(height: sizeScreen.height*0.02,)),
               Expanded(
                flex: 2,
                 child: Image.asset(
                    'assets/logos/logoLima.png',
                    width: sizeScreen.width*0.66,
                    // height: width*0.05,
                  ),
               ),
               Expanded(child: SizedBox(height: sizeScreen.height*0.05,)),
               Expanded(
                flex: 3,
                 child: Image.asset(
                    'assets/generalPics/city.png',
                    width: double.infinity,
                    // height: width*0.05,
                  ),
               ),
               SizedBox(height: sizeScreen.height*0.01,),
               const Expanded(
                flex: 2,
                 child: BrandingApp(width: 550,)
               ),
               
                
              
               
              ],
            ),
          ),

          Container(
            width: double.infinity,
            height: double.infinity, 
            // color: Colors.red,
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  child
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}

