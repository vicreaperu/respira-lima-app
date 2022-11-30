import 'package:app4/blocs/blocs.dart';
import 'package:app4/models/models.dart';
import 'package:app4/themes/themes.dart';
import 'package:app4/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);
  static String pageRoute = 'History';
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
              'Historial de viajes',
              style: TextStyle(
                  color: AppTheme.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w700),
            ),
          ),
          body: SizedBox(
            // padding: const EdgeInsets.all(20),
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
                    padding:  EdgeInsets.only(left:20.0),
                    child:  Text(
                      'Últimos lugares visitados',
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
                            'Regístrate para porder ingresar a tu historial',
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
                     ) 
                     : 
                    
                    state.historyData.length > 0 ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    
                    for (int i =state.historyData.length - 1; i >= 0; i--)
                    // for (int i =0; i < state.historyData.length; i++)
                    HistoryFormat(
                      size: size,
                      myHistory: state.historyData[i],
                    ),
                      ],
                    ) : 
                    SizedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 70,),
                          Image.asset(
                            fit: BoxFit.cover,
                            'assets/icons/history.png',
                            // width: 130,  
                          // height: 130,
                          ),
                          const SizedBox(height: 35,),
                          const Text(
                            'Aún no has hecho ningún recorrido',
                          style: TextStyle(
                            color: AppTheme.gray60,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class HistoryFormat extends StatelessWidget {
//  {distance: 0.0, end_street_name: Calle Santiago Acuña 180, exposure: 6.77, profile: walking,
// start_street_name: Calle Santiago Acuña 180,
//start_timestamp: 2022-10-03 12:46:09, total_time: 9.0}
  final HistoryModel myHistory;
  const HistoryFormat({
    Key? key,
    required this.size,
    required this.myHistory,
  }) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                      width: 300,
                      child: Text(
                        '${myHistory.startTimestamp.split(' ')[0]} | ${myHistory.profile == 'walking' ? 'peatón' : 'ciclista'} | ${myHistory.distance}km | ${myHistory.totalTime}min | Exposición PM2.5: ${myHistory.exposure}ug/m3',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      )),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            HistoryTrackingPerPointV2(
              isHoleBoll: true,
              areLines: true,
              title: myHistory.endStreetName,
            ),
            HistoryTrackingPerPointV2(
              isHoleBoll: false,
              areLines: false,
              title: myHistory.startStreetName,
            ),
          ],
        ),
        const SizedBox(
          height: 25,
        ),
        Container(
          color: AppTheme.gray30,
          height: 1,
          width: size.width,
        ),
        const SizedBox(
          height: 25,
        ),
      ],
    );
  }
}
