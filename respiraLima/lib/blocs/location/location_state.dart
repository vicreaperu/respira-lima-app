part of 'location_bloc.dart';

class LocationState extends Equatable {
  final bool followingUser;
  final LatLng? lastKnownLocation;
  final String? lastKnownLocationStreetName;
  final double? lastKnownLocationHeading;
  final List<LatLng> myLocationHistory;
  final List<LatLng> myRoute;
  final bool saveLocationHistory;
  final bool modifyForTesting;
  final bool isInBackground;
  final bool readLocation;
  final int timeWaiting;

  // TODO:
  // ultimo geolocation
  // history
  const LocationState(
      {
        this.lastKnownLocationStreetName,
        this.lastKnownLocationHeading,
        this.followingUser = false, 
        this.saveLocationHistory = false, 
        this.modifyForTesting = false,
        this.isInBackground = false,
        this.readLocation = true,
        this.timeWaiting = 10,
        this.lastKnownLocation, 
        myLocationHistory,
        myRoute,
        
        }): 
            myLocationHistory = myLocationHistory ?? const [],
            myRoute = myRoute ?? const [];
  LocationState copyWith(
          {
          String? lastKnownLocationStreetName,
          double? lastKnownLocationHeading,
          List<LatLng>? myLocationHistory,
          List<LatLng>? myRoute,
          bool? saveLocationHistory,
          LatLng? lastKnownLocation,
          int? timeWaiting,
          bool? readLocation,
          bool? modifyForTesting,
          bool? followingUser,
          bool? isInBackground,
          }) =>
      LocationState(
        lastKnownLocationStreetName : lastKnownLocationStreetName  ?? this.lastKnownLocationStreetName,
        lastKnownLocationHeading    : lastKnownLocationHeading     ?? this.lastKnownLocationHeading,
        saveLocationHistory         : saveLocationHistory          ?? this.saveLocationHistory,
        readLocation                : readLocation                 ?? this.readLocation,
        timeWaiting                 : timeWaiting                  ?? this.timeWaiting,
        lastKnownLocation           : lastKnownLocation            ?? this.lastKnownLocation,
        myLocationHistory           : myLocationHistory            ?? this.myLocationHistory,
        modifyForTesting            : modifyForTesting             ?? this.modifyForTesting,
        isInBackground              : isInBackground               ?? this.isInBackground,
        followingUser               : followingUser                ?? this.followingUser,
        myRoute                     : myRoute                      ?? this.myRoute,
        

      );

  @override
  List<Object?> get props =>
      [
        lastKnownLocationStreetName,
        lastKnownLocationHeading,
        saveLocationHistory,
        readLocation,
        timeWaiting,
        lastKnownLocation, 
        myLocationHistory,
        modifyForTesting,
        isInBackground,
        myRoute,
        followingUser, 
        ];
}


// we estends from Equetable to compare values on the future
// and we must add all propertires into the props, then to use it for comparison