part of 'app_data_bloc.dart';

class AppDataEvent extends Equatable {
  const AppDataEvent();

  @override
  List<Object> get props => [];
}

class IsLoadingAppDataEvent extends AppDataEvent{}
class StopLoadingAppDataEvent extends AppDataEvent{}

class SetAppData extends AppDataEvent{
  final List<Map<String,dynamic>> alertPlaces;
  final List<String> alertPollution;
  const SetAppData(this.alertPlaces, this.alertPollution);
}


class IsAppData extends AppDataEvent{}
class IsNotAppData extends AppDataEvent{}

