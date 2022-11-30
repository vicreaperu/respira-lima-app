import 'dart:io';

import 'package:app4/db/db.dart';
import 'package:app4/models/links_model.dart';
import 'package:app4/models/question_model.dart';
import 'package:app4/services/app_user_information.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'user_app_data_event.dart';
part 'user_app_data_state.dart';

class UserAppDataBloc extends Bloc<UserAppDataEvent, UserAppDataState> {
  final UserAppInformationService userAppInformationService;
  UserAppDataBloc(
    {
      required this.userAppInformationService,
    }
  ) : super(const UserAppDataState()) {


    on<ShowListConoceMasEvent>((event, emit) => emit(state.copyWith(showListConoceMas: true)));
    on<HideListConoceMasEvent>((event, emit) => emit(state.copyWith(showListConoceMas: false)));
   
    on<ShowListEnlacesDeInteresEvent>((event, emit) => emit(state.copyWith(showListEnlacesDeInteres: true)));
    on<HideListEnlacesDeInteresEvent>((event, emit) => emit(state.copyWith(showListEnlacesDeInteres: false)));

   
    on<OnSelectingPicEvent>((event, emit) => emit(state.copyWith(selectingPic: true)));
    on<OffSelectingPicEvent>((event, emit) => emit(state.copyWith(selectingPic: false)));


    on<AddNewPicEvent>((event, emit) => emit(state.copyWith(picName: [event.fileName])));

   
    on<LoadingUserAppDataEvent>((event, emit) => emit(state.copyWith(loadingUserAppData: true)));
    on<StopLoadingUserAppDataEvent>((event, emit) => emit(state.copyWith(loadingUserAppData: false)));

    on<AddQuestionsToShowEvent>((event, emit) => emit(state.copyWith(questionsListToShow: event.questions)));
    on<SetAllQuestionsToShowEvent>((event, emit) => emit(state.copyWith(questionsListToShow: state.questionsList)));
    
    
    on<AddPoliticsAndQuestionsAndLinksEvent>((event, emit) => emit(state.copyWith(
      areQuestions: true, 
      arePoliticsData: true, 
      questionsList: event.questions,
      questionsListToShow: event.questions, 
      politicsAndTerms: event.politics,
      conoceMas: event.conoceMas,
      enlacesDeInteres: event.enlacesDeInteres,
      )));
    on<AddPoliticsAndQuestionsEvent>((event, emit) => emit(state.copyWith(areQuestions: true, arePoliticsData: true, questionsList: event.questions,questionsListToShow: event.questions, politicsAndTerms: event.politics)));
    on<NotHasPoliticsAndQuestionsEvent>((event, emit) => emit(state.copyWith(areQuestions: false, arePoliticsData: false)));
    _init();
  }
  void _init() async{
    // TODO: Verify if has data
    final String? fileName = await PrincipalDB.getProfilePicturePath();
    if(fileName != null){
      File imageFile = File(fileName);
      add(AddNewPicEvent(fileName: imageFile ));
    }
  }

    Future<bool> getPoliticsAndQuestions() async{
      add(LoadingUserAppDataEvent());
      bool response = false;
      // final token = await PrincipalDB.getFirebaseToken();
      final resp = await userAppInformationService.getPoliticsAndQuestions();
      if(resp['error'] == null){
        print('appData--->   xxxxxFINALLLLL RESP IS:: $response');
        response = true;
        final frecQuest = resp['frequent_questions'].map((question) => QuestionModel.fromMap(question)).toList();
        final List<QuestionModel> frecQuestions = frecQuest.cast<QuestionModel>();


        final intLink = resp['interest_links'].map((question) => LinkModel.fromMap(question)).toList();
        final List<LinkModel> intLinks = intLink.cast<LinkModel>();

        final learnMore = resp['learn_more'].map((question) => LinkModel.fromMap(question)).toList();
        final List<LinkModel> learningMore = learnMore.cast<LinkModel>();



        intLinks.asMap().forEach((index, element) async{ 
          await PrincipalDB.insertUpdateInterestLinksWithCustomID(element, index);
        });
        learningMore.asMap().forEach((index, element) async{ 
          await PrincipalDB.insertUpdateLearnMoreWithCustomID(element, index);
        });


        frecQuestions.asMap().forEach((index, element) async{ 
          await PrincipalDB.insertUpdateFrequentQuestionsWithCustomID(element, index);
        });



        final String politicsAndTerms = resp['privacy_policies']['content'];

        await PrincipalDB.politicsAndTerms(politicsAndTerms);

        // add(AddPoliticsAndQuestionsEvent(politics: politicsAndTerms, questions: frecQuestions));
        add(AddPoliticsAndQuestionsAndLinksEvent(politics: politicsAndTerms, questions: frecQuestions, conoceMas: learningMore, enlacesDeInteres: intLinks));
        print('appData--->   yyyyFINALLLLL RESP IS:: $response');
        
      } else{
        print('appData---> ERROR getPoliticsAndQuestions');
      }
      print('appData--->   FINALLLLL RESP IS:: $response');
      add(StopLoadingUserAppDataEvent());
      return response;
    }


}
