import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';


class PoliticsScreen extends StatelessWidget {
  const PoliticsScreen({Key? key}) : super(key: key);
  static String pageRoute = 'Politics';
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
   
        return 
        
        Scaffold(
          backgroundColor: AppTheme.white,
          appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: true,
            title: const Text(
              'Políticas de privacidad',
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
                    'Políticas de privacidad / Términos y condiciones',
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
                    child: 
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
                    ),
                  
                ),
              ],
            ),
          ),
        );
      
  }
}

