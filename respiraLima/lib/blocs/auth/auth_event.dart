part of 'auth_bloc.dart';

class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

// class UpdateTokenEvent extends AuthEvent{}

class HasAccountEvent extends AuthEvent{}
class HasSimpleAccountEvent extends AuthEvent{}
class HasAccountAsGuestEvent extends AuthEvent{}
class NotHasAccountEvent extends AuthEvent{}

class HasValidAccountEvent extends AuthEvent{}
class NotHasValidAccountEvent extends AuthEvent{}

class IsAguestEvent extends AuthEvent{}
class IsNotAguestEvent extends AuthEvent{}


class StartUpdatingAccountEvent extends AuthEvent{}
class SetIsUpdating extends AuthEvent{}
class StopUpdatingAccountEvent extends AuthEvent{}

