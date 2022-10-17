import 'package:app4/themes/themes.dart';
import 'package:app4/widgets/widgets.dart';
import 'package:flutter/material.dart';

class HistoryTrackingPerPoint extends StatelessWidget {
  final bool isHoleBoll;
  final bool areLines;
  final String titleHeader;
  final String title;
  final String time;
  final String distance;
  final String exposure;
  final String airQuality;
  const HistoryTrackingPerPoint({
    Key? key, 
    required this.isHoleBoll, 
    required this.areLines, 
    required this.titleHeader, 
    required this.title, 
    required this.time,
    required this.distance, 
    required this.exposure, 
    required this.airQuality,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:  [
          isHoleBoll ? const SmallBolWithHole() : const SmallBoll(),
          Column(
            children: !areLines ? [] : const [
              SmallVerticalLine(),
              SmallVerticalLine(),
              SmallVerticalLine(),
              SmallVerticalLine(),
              SmallVerticalLine(),
              SmallVerticalLine(),
              SmallVerticalLine(),
              SmallVerticalLine(),
              SmallVerticalLine(),
              SmallVerticalLine(),
             
            ],
          ),
   
        ],
      
      ),
      const SizedBox(width: 12,),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(titleHeader, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),),
              Text(title, style: const TextStyle(fontSize: 14),),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 83,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Hace $time min', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),),
                        // Text(time, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),),
                        // const Text(' min', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),),
                      ],
                    ),
                    Row(
                      children: [
                        Text('(${distance}km)', style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),),
                        // const Text(' km'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10,),
              Container(
                color: AppTheme.gray30,
                width: 1,
                height: 40,
              ),
              const SizedBox(width: 10,),
             
              _CustomColumWithIcon4Exposure(textToShow: exposure),
              const SizedBox(width: 10,),
              Container(
                color: AppTheme.gray30,
                width: 1,
                height: 40,
              ),
              const SizedBox(width: 10,),
              _CustomColumWithIcon4AirQuality(textToShow: airQuality),
            ],
          )
        ],
      )
      ],
    );
  }
}

class _CustomColumWithIcon4Exposure extends StatelessWidget {
  const _CustomColumWithIcon4Exposure({
    Key? key,
    required this.textToShow
  }) : super(key: key);

  final String textToShow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Exposición', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12),),
          Row(

            children:  [
              // const Icon(Icons.air, size: 17,),
              const SizedBox(width: 2,),
              
              Text(textToShow, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),),
              const Text('ug/m3', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),),
            ],
          ),
        ],
      ),
    );
  }
}
class _CustomColumWithIcon4AirQuality extends StatelessWidget {
  const _CustomColumWithIcon4AirQuality({
    Key? key,
    required this.textToShow
  }) : super(key: key);

  final String textToShow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Calidad del aire', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12),),
        Row(

          children:  [
            Icon(
              textToShow == 'Buena' ? Icons.sentiment_satisfied_alt_outlined: 
              textToShow == 'Moderada' ? Icons.sentiment_neutral_outlined :
              textToShow == 'Mala' ? Icons.sentiment_very_dissatisfied  :
              Icons.sentiment_very_dissatisfied_outlined ,  // MUY MALA
              size: 15,
              ),
            const SizedBox(width: 4,),
            Text(textToShow, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),),
          ],
        ),
      ],
    );
  }
}
