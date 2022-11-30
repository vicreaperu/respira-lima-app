import 'package:animate_do/animate_do.dart';
import 'package:app4/blocs/blocs.dart';
import 'package:app4/blocs/search/search_bloc.dart';
import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

class BtnCompass extends StatelessWidget {
  const BtnCompass({
    Key? key,
    required GlobalKey<ScaffoldState> globalKey,
  })  : _globalKey = globalKey,
        super(key: key);

  final GlobalKey<ScaffoldState> _globalKey;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        return state.displayManualMarker
            ? Container()
            : SafeArea(
                child: ElasticInLeft(
                  child: BlocBuilder<MapBloc, MapState>(
                    builder: (context, state) {
                      return Container(
                          padding: const EdgeInsets.only(top: 150, right: 20),
                          alignment: Alignment.centerRight,
                          child: Transform.rotate(
                            angle: - 2 * pi / 360 * state.cameraPosition.bearing,
                            child: CircleAvatar(
                              maxRadius: 20,
                              minRadius: 20,
                              backgroundColor: AppTheme.gray10,
                              child: const Icon(
                                Icons.navigation_sharp,
                                size: 22,
                                color: AppTheme.red,
                              ),
                            ),
                          ));
                    },
                  ),
                ),
              );
      },
    );
  }
}
