part of 'app_data_bloc.dart';

class AppDataState extends Equatable {

  final List<Map<String, dynamic>> placesAlerts;
  final List<String> pollutionCategory;
  final bool isPredictionsGridUpdated;
  final bool isLoadingAppData;
  final bool isAppData;

  const AppDataState({
    List<Map<String, dynamic>>? placesAlerts,
    List<String>? pollutionCategory,
    this.isPredictionsGridUpdated = false,
    this.isLoadingAppData = false,
    this.isAppData = false,
  }):placesAlerts = placesAlerts ?? const [],
     pollutionCategory = pollutionCategory ?? const [];

  AppDataState copyWith({
    List<Map<String, dynamic>>? placesAlerts,
    List<String>? pollutionCategory,
    bool? isPredictionsGridUpdated,
    bool? isLoadingAppData,
    bool? isAppData,
  }) => AppDataState(
    isPredictionsGridUpdated: isPredictionsGridUpdated ?? this.isPredictionsGridUpdated,
    pollutionCategory       : pollutionCategory        ?? this.pollutionCategory,
    isLoadingAppData        : isLoadingAppData         ?? this.isLoadingAppData,
    placesAlerts            : placesAlerts             ?? this.placesAlerts,
    isAppData               : isAppData                ?? this.isAppData,
    );
  
  @override
  List<Object> get props => [
    isPredictionsGridUpdated,
    pollutionCategory,
    isLoadingAppData,
    placesAlerts,
    isAppData,
  ];
}
