import 'package:app4/blocs/blocs.dart';
import 'package:app4/themes/themes.dart';
import 'package:app4/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileAndModeAvatar extends StatelessWidget {
  final String profile;
  final IconData profileIcon;
  final String mode;
  final IconData modeIcon;

  const ProfileAndModeAvatar({
    Key? key, required this.profile, required this.profileIcon, required this.mode, required this.modeIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(

      children: [
        //  const HeaderSpeacker(),
        //  const SizedBox(width: 5,),
         CircleAvatar(
          radius: 17,
          backgroundColor: AppTheme.primaryAqua,
          child: Icon(
            profileIcon,
            color: Colors.white,
            size: 17,
          ),
        ),
        const SizedBox(width: 5,),
        Text(profile),


        const Expanded(flex: 1, child: SizedBox()),


        CircleAvatar(
          radius: 17,
          backgroundColor: AppTheme.primaryAqua,
          child: Icon(
            
            modeIcon,
            size: 17,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 5,),
        Text(mode),

        
        const Expanded(flex: 3, child: SizedBox()),
      ],
    );
  }
}



