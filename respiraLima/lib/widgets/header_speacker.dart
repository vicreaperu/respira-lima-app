import 'package:app4/blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HeaderSpeacker extends StatelessWidget {
  const HeaderSpeacker({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationBloc = BlocProvider.of<NavigationBloc>(context);
    return SizedBox(
      // height: 25,
      child: BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, state) {
          return IconButton(
            padding: const EdgeInsets.all(0),
            // color: Colors.red,
            onPressed: () {
              // navigationBloc.add(DeactivateNavigationModeEvent());
              navigationBloc.add(state.speakRoute ? OffSpeakRouteEvent() : OnSpeakRouteEvent() );
            },
            icon: Icon(
              state.speakRoute ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              size: 25,
            ),
         
          );
        },
      ),
    );
  }
}
