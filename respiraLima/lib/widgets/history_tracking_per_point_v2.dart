import 'package:app4/themes/themes.dart';
import 'package:app4/widgets/widgets.dart';
import 'package:flutter/material.dart';

class HistoryTrackingPerPointV2 extends StatelessWidget {
  final bool isHoleBoll;
  final bool areLines;
  final String title;

  const HistoryTrackingPerPointV2({
    Key? key, 
    required this.isHoleBoll, 
    required this.areLines, 
    required this.title, 

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:  [
          isHoleBoll ? const SmallBolWithHole(radio: 6, widthHeight: 8,) : const SmallBoll(heightWidth: 12,),
          Column(
            children: !areLines ? [] : const [
              SmallVerticalLine(height: 2, width: 1,),
              SmallVerticalLine(height: 2, width: 1,),
              SmallVerticalLine(height: 2, width: 1,),
              SmallVerticalLine(height: 2, width: 1,),
             
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
              Text(title, style: const TextStyle(fontSize: 13, color: AppTheme.gray80, fontWeight: FontWeight.w300),),
            ],
          ),
          
        ],
      )
      ],
    );
  }
}
