import 'package:app4/blocs/blocs.dart';
import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PoliticsScreen extends StatelessWidget {
  const PoliticsScreen({Key? key}) : super(key: key);
  static String pageRoute = 'Politics';
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocBuilder<UserAppDataBloc, UserAppDataState>(
      builder: (context, state) {
        return Scaffold(
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
          body: Stack(
            children: [
              Container(
                color: AppTheme.gray10,
                // padding: const EdgeInsets.all(20),
                height: double.infinity,
                width: double.infinity,
              ),
              SizedBox(
                
                child: SingleChildScrollView(
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
                        padding: EdgeInsets.only(left: 20.0),
                        child: Text(
                          'Políticas de privacidad / Términos y condiciones',
                          style: TextStyle(
                              color: AppTheme.blue,
                              fontSize: 17,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: SizedBox(
                          // height: size.height - 220,
                          child: 
                          state.loadingUserAppData ? const SpinKitRing(
                          size: 70,
                          color: Colors.black87,
                         ) 
                         : 
                          Text(
                            state.politicsAndTerms,
                            style: const TextStyle(
                                color: AppTheme.gray80,
                                fontSize: 16,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
