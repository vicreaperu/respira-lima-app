import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';

class Text4Omboarding extends StatelessWidget {
  final List<InlineSpan> listInline;
  final String title;
  const Text4Omboarding({
    Key? key, required this.listInline, required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    const textStyle0 =  TextStyle(fontSize: 35, color: AppTheme.primaryBlue, fontWeight: FontWeight.w800, backgroundColor: Colors.white60) ;
    const textStyle1 =  TextStyle(height: 1.5, fontSize: 18, color: AppTheme.darkBlue, fontWeight: FontWeight.w400) ;
    const textStyle2 =  TextStyle(height: 1.5, fontSize: 18, color: AppTheme.darkBlue, fontWeight: FontWeight.w800) ;
    return Container(
      // height: 150,
      alignment: Alignment.center,
      // color: Colors.white54,
      padding: const EdgeInsets.symmetric( horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  [
          Text(title, style: textStyle0,),
          const SizedBox(height: 20,),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            color: Colors.white54,
            child: RichText(text: TextSpan(
              children: listInline
            )),
          ),
         
        ],
      ),
    );
  }
}