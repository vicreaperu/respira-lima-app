part of 'location_bloc.dart';

class LocationState extends Equatable {
  final bool followingUser;
  final LatLng? lastKnownLocation;
  final String? lastKnownLocationStreetName;
  
  final List<LatLng> myLocationHistory;
  final List<LatLng> myRoute;
  final bool saveLocationHistory;
  final bool modifyForTesting;

  // TODO:
  // ultimo geolocation
  // history
  const LocationState(
      {
        this.lastKnownLocationStreetName,
        this.followingUser = false, 
        this.saveLocationHistory = false, 
        this.modifyForTesting = false,
        this.lastKnownLocation, 
        myLocationHistory,
        myRoute,
        
        }): 
            myLocationHistory = myLocationHistory ?? const [],
            myRoute = myRoute ?? const [];
  LocationState copyWith(
          {
          String? lastKnownLocationStreetName,
          List<LatLng>? myLocationHistory,
          List<LatLng>? myRoute,
          bool? saveLocationHistory,
          LatLng? lastKnownLocation,
          bool? modifyForTesting,
          bool? followingUser,
          }) =>
      LocationState(
        lastKnownLocationStreetName : lastKnownLocationStreetName  ?? this.lastKnownLocationStreetName,
        saveLocationHistory         : saveLocationHistory          ?? this.saveLocationHistory,
        lastKnownLocation           : lastKnownLocation            ?? this.lastKnownLocation,
        myLocationHistory           : myLocationHistory            ?? this.myLocationHistory,
        modifyForTesting            : modifyForTesting             ?? this.modifyForTesting,
        myRoute                     : myRoute                      ?? this.myRoute,
        followingUser               : followingUser                ?? this.followingUser,
        

      );

  @override
  List<Object?> get props =>
      [
        lastKnownLocationStreetName,
        saveLocationHistory,
        lastKnownLocation, 
        myLocationHistory,
        modifyForTesting,
        myRoute,
        followingUser, 
        ];
}


// we estends from Equetable to compare values on the future
// and we must add all propertires into the props, then to use it for comparison