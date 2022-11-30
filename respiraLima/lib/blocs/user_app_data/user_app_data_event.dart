part of 'user_app_data_bloc.dart';

class UserAppDataEvent extends Equatable {
  const UserAppDataEvent();

  @override
  List<Object> get props => [];
}

class AddPoliticsAndQuestionsEvent extends UserAppDataEvent{
  final String politics;
  final List<QuestionModel> questions;

  const AddPoliticsAndQuestionsEvent({
    required this.politics, 
    required this.questions
  });
}
class AddPoliticsAndQuestionsAndLinksEvent extends UserAppDataEvent{
  final String politics;
  final List<QuestionModel> questions;
  final List<LinkModel> conoceMas;
  final List<LinkModel> enlacesDeInteres;

  const AddPoliticsAndQuestionsAndLinksEvent({
    required this.politics, 
    required this.questions,
    required this.conoceMas,
    required this.enlacesDeInteres,
  });
}
class AddPoliticsEvent extends UserAppDataEvent{
  final String politics;

  const AddPoliticsEvent({
    required this.politics, 
  });
}
class AddQuestionsEvent extends UserAppDataEvent{
  final List<QuestionModel> questions;

  const AddQuestionsEvent({
    required this.questions
  });
}


class AddQuestionsToShowEvent extends UserAppDataEvent{
  final List<QuestionModel> questions;

  const AddQuestionsToShowEvent({
    required this.questions
  });
}
class SetAllQuestionsToShowEvent extends UserAppDataEvent{}


class NotHasPoliticsAndQuestionsEvent extends UserAppDataEvent{}
class NotHasPoliticsEvent extends UserAppDataEvent{}
class NotHasQuestionsEvent extends UserAppDataEvent{}

class LoadingUserAppDataEvent extends UserAppDataEvent{}
class StopLoadingUserAppDataEvent extends UserAppDataEvent{}

class ShowListConoceMasEvent extends UserAppDataEvent{}
class HideListConoceMasEvent extends UserAppDataEvent{}

class ShowListEnlacesDeInteresEvent extends UserAppDataEvent{}
class HideListEnlacesDeInteresEvent extends UserAppDataEvent{}

class OnSelectingPicEvent extends UserAppDataEvent{}
class OffSelectingPicEvent extends UserAppDataEvent{}

class AddNewPicEvent extends UserAppDataEvent{
  final File fileName;
  const AddNewPicEvent({required this.fileName});
}
class DeletePicEvent extends UserAppDataEvent{}