import 'package:flutter/material.dart';

class HeaderAcompanhando extends StatelessWidget {
  const HeaderAcompanhando({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            // color: Colors.red,
            onPressed: () {
              // navigationBloc.add(DeactivateNavigationModeEvent());
            },
            icon: const Icon(Icons.arrow_drop_down),
          )
        ],
      ),
    );
  }
}
