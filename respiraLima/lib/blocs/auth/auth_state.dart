part of 'auth_bloc.dart';

class AuthState extends Equatable {

  final bool isValidToke;
  final bool hasAccount;
  final bool hasValidAccound;
  final bool startUpdating;
  final DateTime initialDate;
  final bool isAGuest;
  
  const AuthState({
    this.isAGuest = false,
    this.startUpdating = false,
    this.hasAccount = false,
    this.hasValidAccound = false,
    this.isValidToke = false,
    required this.initialDate,
    });
  AuthState copyWith({
    bool? isAGuest,
    bool? startUpdating,
    bool? isValidToke,
    bool? hasAccount,
    bool? hasValidAccound,
    DateTime? initialDate,
  }) => AuthState(
      hasValidAccound  : hasValidAccound ?? this.hasValidAccound,
      startUpdating    : startUpdating   ?? this.startUpdating,
      isValidToke      : isValidToke     ?? this.isValidToke,
      initialDate      : initialDate     ?? this.initialDate,
      hasAccount       : hasAccount      ?? this.hasAccount,
      isAGuest         : isAGuest        ?? this.isAGuest ,
  );
  @override
  List<Object> get props => [
    hasValidAccound,
    startUpdating,
    isValidToke,
    initialDate,
    hasAccount,
    isAGuest,
    ];
}
