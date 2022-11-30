part of 'user_app_data_bloc.dart';

class UserAppDataState extends Equatable {

  final bool arePoliticsData;
  final bool areQuestions;
  final bool loadingUserAppData;
  final bool showListConoceMas;
  final bool showListEnlacesDeInteres;
  final bool selectingPic;
  final String politicsAndTerms;
  final List<QuestionModel> questionsList;
  final List<QuestionModel> questionsListToShow;
  final List<LinkModel> conoceMas;
  final List<LinkModel> enlacesDeInteres;
  final List<File> picName;

  const UserAppDataState( {
    List<QuestionModel>? questionsList,
    List<QuestionModel>? questionsListToShow,
    List<LinkModel>? conoceMas,
    List<LinkModel>? enlacesDeInteres,
    List<File>? picName,
    this.arePoliticsData = false,
    this.areQuestions = false,
    this.loadingUserAppData = false,
    this.showListConoceMas = false,
    this.showListEnlacesDeInteres = false,
    this.selectingPic = false,
    this.politicsAndTerms = '',
    
  }): 
  questionsList = questionsList ?? const [],
  questionsListToShow = questionsListToShow ?? const [],
  conoceMas = conoceMas ?? const [],
  picName = picName ?? const [],
  enlacesDeInteres = enlacesDeInteres ?? const [];

  UserAppDataState copyWith({
    bool? arePoliticsData,
    bool? areQuestions,
    bool? selectingPic,
    bool? loadingUserAppData,
    bool? showListConoceMas,
    bool? showListEnlacesDeInteres,
    List<QuestionModel>? questionsList,
    List<QuestionModel>? questionsListToShow,
    List<LinkModel>? conoceMas,
    List<LinkModel>? enlacesDeInteres,
    String? politicsAndTerms,
    List<File>? picName,
  }) => UserAppDataState(
    showListEnlacesDeInteres: showListEnlacesDeInteres ?? this.showListEnlacesDeInteres, 
    questionsListToShow     : questionsListToShow      ?? this.questionsListToShow, 
    loadingUserAppData      : loadingUserAppData       ?? this.loadingUserAppData, 
    showListConoceMas       : showListConoceMas        ?? this.showListConoceMas, 
    politicsAndTerms        : politicsAndTerms         ?? this.politicsAndTerms, 
    enlacesDeInteres        : enlacesDeInteres         ?? this.enlacesDeInteres, 
    arePoliticsData         : arePoliticsData          ?? this.arePoliticsData,
    questionsList           : questionsList            ?? this.questionsList,
    selectingPic            : selectingPic             ?? this.selectingPic,
    areQuestions            : areQuestions             ?? this.areQuestions,
    conoceMas               : conoceMas                ?? this.conoceMas,
    picName                 : picName                 ?? this.picName,
  );
  
  @override
  List<Object> get props => [
    showListEnlacesDeInteres,
    questionsListToShow,
    loadingUserAppData,
    showListConoceMas,
    politicsAndTerms,
    enlacesDeInteres,
    arePoliticsData,
    questionsList,
    selectingPic,
    areQuestions,
    conoceMas,
    picName,
  ];
}