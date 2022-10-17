
import 'package:animate_do/animate_do.dart';
import 'package:app4/blocs/blocs.dart';
import 'package:app4/delegates/delegates.dart';
import 'package:app4/models/models.dart';
import 'package:app4/share_preferences/share_preferences.dart';
import 'package:app4/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(builder:(context, state) {
      return state.displayManualMarker ? const SizedBox() : ElasticInDown(child: const _SearchBarBody());
    }, );
  }
}


class _SearchBarBody extends StatelessWidget {
   
  const _SearchBarBody({Key? key}) : super(key: key);
  void searchActions(BuildContext context, SearchResult result)async{
    final searchBloc = BlocProvider.of<SearchBloc>(context);
    final mapBloc = BlocProvider.of<MapBloc>(context);
    final navigationBloc = BlocProvider.of<NavigationBloc>(context);
    if(result.manual == true)
    {
      await mapBloc.updateForSearchData();
      searchBloc.add(OnActivateManualMarkerEvent());
      return;
    } else{
      if(result.coordinates != null){
        await mapBloc.updateForSearchData2(coordinates: result.coordinates!, streetName: result.streetName!);
        navigationBloc.add(OnSelectingRoute(result.coordinates!));  
        return;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        // margin: const EdgeInsets.only(top: 10),
        // padding: const EdgeInsets.only(left: 60),
      
        width: double.infinity,
        child: 
        
        TextFormField(
          readOnly: true,
          onTap: () async {
            final result = await showSearch(context: context, delegate: SearchDestinationDelegate());
            print('THE PLACE IS RESULT ISS ..... $result');
            if (result == null) return;
            searchActions(context, result);
          },
          autocorrect: false,
          keyboardType:
              TextInputType.emailAddress,
          style: const TextStyle(
              color: Colors.black),
          decoration: InputDecotations
              .authInputDecoration(
      
            labelText: 'Donde quieres ir?',
            hintText: 'qAira',
            // prefixIcon: Icons.alternate_email_outlined
          ),
          
        ),
        
        
        
   

      ),
    );
  }
}




// class _SearchBarBody extends StatelessWidget {
   
//   const _SearchBarBody({Key? key}) : super(key: key);
//   void searchActions(BuildContext context, SearchResult result){
//     final searchBloc = BlocProvider.of<SearchBloc>(context);
//     if(result.manual == true)
//     {
//       searchBloc.add(OnActivateManualMarkerEvent());
//       return;
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Container(
//         margin: const EdgeInsets.only(top: 10),
//         padding: const EdgeInsets.only(left: 60),
      
//         width: double.infinity,
        
//         child: GestureDetector(
//           onTap: () async {
//             final result = await showSearch(context: context, delegate: SearchDestinationDelegate());
//             if (result == null) return;
//             searchActions(context, result);
//           },
//           child: Container(
            
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
//             decoration: BoxDecoration(
//               color: AppTheme.white,
//               borderRadius: BorderRadius.circular(100),
//               boxShadow: const [BoxShadow(
//                 color: AppTheme.black,
//                 blurRadius: 5,
//                 offset: Offset(0,5),
//                 )]
//             ),
//             child: const Text('Donde quieres ir?', style: TextStyle(color: AppTheme.black),),
//           ),
//         ),
//       ),
//     );
//   }
// }




