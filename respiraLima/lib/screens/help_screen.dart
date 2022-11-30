import 'dart:async';

import 'package:app4/blocs/blocs.dart';
import 'package:app4/db/principal_db.dart';
import 'package:app4/implementation/implementation.dart';
import 'package:app4/models/question_model.dart';
import 'package:app4/themes/themes.dart';
import 'package:app4/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);
  static String pageRoute = 'Help';
  static final debouncer = Debouncer(milliseconds: 1000);
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final userAppDataBloc = BlocProvider.of<UserAppDataBloc>(context, listen: false);
    userAppDataBloc.add(SetAllQuestionsToShowEvent());
    return BlocBuilder<UserAppDataBloc, UserAppDataState>(
      builder: (context, state) {
        return  Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: true,
            title: const Text(
              'Preguntas frecuentes',
              // 'Preguntas frecuentes ${state.questionsListToShow.length}',
              style: TextStyle(
                  color: AppTheme.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w700),
            ),
          ),
          body: Stack(
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                color: AppTheme.gray10,
                ),
              SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Container(
                 color: AppTheme.gray10,
                 // padding: const EdgeInsets.all(20),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Container(
                       color: AppTheme.gray30,
                       height: 1,
                       width: size.width,
                     ),
                     const SizedBox(
                       height: 35,
                     ),
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 20.0),
                       child: TextFormField(
                         onChanged:(value){
                          print('HELP---> $value');
                          debouncer.run(() {
                            userAppDataBloc.add(LoadingUserAppDataEvent());
                            print('HELP---> DEBOUNCED $value');
                            PrincipalDB.getQuestionsMatches(value).then((value) {
                              Timer(const Duration(seconds: 1), () {
                                userAppDataBloc.add(AddQuestionsToShowEvent(questions: value));
                                print('HELP---> DEBOUNCED ${value.length}');
                                userAppDataBloc.add(StopLoadingUserAppDataEvent());
                              });
                            });
                              // put the code that you want to debounce
                              // example: calling an API, adding a BLoC event
                          });
                         },
                         autocorrect: false,
                         keyboardType: TextInputType.emailAddress,
                         style: const TextStyle(color: Colors.black),
                         decoration: InputDecotations.questionsInputDecoration(
                             labelText: '¿En qué te podemos ayudar?',
                             hintText: '¿Qué es el PM2.5?',
                             prefixIcon: Icons.search),
                       ),
                     ),
                     const SizedBox(
                       height: 15,
                     ),
                     const Padding(
                       padding: EdgeInsets.only(left: 20.0),
                       child: Text(
                         'Preguntas',
                         style: TextStyle(
                             color: AppTheme.blue,
                             fontSize: 16,
                             fontWeight: FontWeight.w700),
                       ),
                     ),
                     const SizedBox(
                       height: 25,
                     ),
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 20.0),
                       child: 
                         state.loadingUserAppData ? const SpinKitRing(
                           size: 70,
                           color: Colors.black87,
                         ) 
                         : 
                      StepList(steps: state.questionsListToShow),
                         
                      //    SizedBox(
                      //     //  height: size.height - 250,
                      //      child:  Column(
                      //      crossAxisAlignment: CrossAxisAlignment.start,
                      //      children: [
                           
                      //      for (int i =0; i < state.questionsList.length; i++)
                      //      SizedBox(child: Column(
                      //        children: [
                      //          Text(state.questionsList[i].question),
                      //          Text(state.questionsList[i].answer),
                      //        ],
                      //      ),)
                      //      ],
                      //    ),
                      //  ),
                      
                     ),
                     const SizedBox(
                       height: 20,
                     )
                   ],
                 ),
                  ),
              ),
            ],
          ),
          
        );
      },
    );
  }
}


class StepList extends StatefulWidget {
  final List<QuestionModel> steps;
  const StepList({Key? key, required this.steps}) : super(key: key);
  @override
  State<StepList> createState() => _StepListState(steps: steps);
}

class _StepListState extends State<StepList> {
  final List<QuestionModel> _steps;
  _StepListState({required List<QuestionModel> steps}) : _steps = steps;
  @override
  Widget build(BuildContext context) {
    // print('HELP---> ---------------${_steps.length}');
    // return ExpansionPanelList.radio(
    //   elevation: 2,
    //   expansionCallback: (int index, bool isExpanded) {
    //     setState(() {
    //       _steps[index].isExpanded = !isExpanded;
    //     });
    //   },
    //   children: _steps.map<ExpansionPanelRadio>((QuestionModel step) {
    //     return ExpansionPanelRadio(
    //       value: step.question,
    //       headerBuilder: (BuildContext context, bool isExpanded) {
    //         return ListTile(
    //           title: Text(step.question, style: const TextStyle(fontWeight: FontWeight.w600),),
    //         );
    //       },
    //       body: ListTile(
    //         title: Text(step.answer, style: const TextStyle(color: AppTheme.gray60),),
    //       ),
    //       canTapOnHeader: true
    //       // isExpanded: step.isExpanded,
    //     );
    //   }).toList(),
    // );
    return ExpansionPanelList(
      elevation: 2,
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _steps[index].isExpanded = !isExpanded;
        });
      },
      children: _steps.map<ExpansionPanel>((QuestionModel step) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(step.question, style: const TextStyle(fontWeight: FontWeight.w600),),
            );
          },
          body: ListTile(
            title: Text(step.answer+'\n', style: const TextStyle(color: AppTheme.gray60),),
          ),
          isExpanded: step.isExpanded,
        );
      }).toList(),
    );
  }
}