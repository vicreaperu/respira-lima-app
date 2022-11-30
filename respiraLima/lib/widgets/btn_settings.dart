import 'package:animate_do/animate_do.dart';
import 'package:app4/blocs/search/search_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BtnSettings extends StatelessWidget {
  const BtnSettings({
    Key? key,
    required GlobalKey<ScaffoldState> globalKey,
  }) : _globalKey = globalKey, super(key: key);

  final GlobalKey<ScaffoldState> _globalKey;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(builder:(context, state) {
      return state.displayManualMarker ? 
      Container() : 
      SafeArea(
      child:  ElasticInLeft(
        child: Container(
          padding: const EdgeInsets.only(top: 25, left: 2),
          alignment: Alignment.topLeft,
          child: CircleAvatar(
            maxRadius: 30,
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(
                Icons.list,
                size: 35,
                color: Colors.black,
                ),
              onPressed: () {
                _globalKey.currentState?.openDrawer();
              }, ),
          ),
        ),
      ),
    );
    },);
    
    
  }
}



