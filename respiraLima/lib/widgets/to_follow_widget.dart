

import 'package:app4/blocs/blocs.dart';
import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ToFollowWidget extends StatelessWidget {
  const ToFollowWidget({
    Key? key,
    required this.draggableScrollableController,
    required this.mapBloc,
    required this.child,
  }) : super(key: key);
  final Widget child;
  final MapBloc mapBloc;
  final DraggableScrollableController draggableScrollableController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        return Column(
          children: [
            state.isFollowingUser
                ? child
                // Container(
                //   color: Colors.red,
                //   width: double.infinity,
                //   height: 10,
                //   child: Icon(Icons.arrow_downw),
                //   // child: child,
                // )
                : SizedBox(
                    // color: Colors.red,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            mapBloc.add(WillStartFollowingUser());
                            // draggableScrollableController.reset();
                            draggableScrollableController.jumpTo(0.9);
                            // draggableScrollableController.jumpTo(0.11);
                            // draggableScrollableController.jumpTo(0.15);
                          },
                          icon: const CircleAvatar(
                            backgroundColor: AppTheme.gray10,
                            radius: 45,
                            child: Icon(
                              Icons.gps_fixed,
                              size: 20,
                              color: AppTheme.gray60,
                            ),
                          ),
                          color: AppTheme.gray30,
                          iconSize: 50,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Centrar',
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(
                              'Regresar a tu ubicación',
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.circle,
                              color: mapBloc.state.isTheCameraTargetOnAre
                                  ? AppTheme.green
                                  : AppTheme.red,
                              size: 12,
                            ),
                            mapBloc.state.isTheCameraTargetOnAre
                                ? const SizedBox()
                                : const Text(
                                    'Fuera de area',
                                    style: TextStyle(fontSize: 12),
                                  ),
                          ],
                        ),
                        // mapBloc.state.isTheCameraTargetOnAre ? const  Icon(Icons.circle, color: Colors.green,) : const  Text( 'Fuera de area'),
                        // Text(mapBloc.state.isTheCameraTargetOnAre ? 'En Area' : 'Fuera de area'),
                      ],
                    ),
                  ),
            state.isFollowingUser
                ? const SizedBox(
                    height: 0,
                  )
                : const SizedBox(
                    height: 20,
                  )
          ],
        );
      },
    );
  }
}
