class InstructionsModel{
  final int initInterval;
  final int endInterval;
  final String streetName;
  final String description;
  final int state;

  InstructionsModel(
    {
      required this.initInterval, 
      required this.endInterval, 
      required this.streetName, 
      required this.description, 
      required this.state,
    });
  InstructionsModel copyWith({
    int? initInterval,  
    int? endInterval,  
    String? streetName,
    String? description,
    int? state,  
  }) => InstructionsModel(
    initInterval: initInterval ?? this.initInterval,
     endInterval: endInterval  ?? this.endInterval, 
     streetName : streetName   ?? this.streetName, 
     description: description  ?? this.description, 
     state      : state        ?? this.state
    );
  static InstructionsModel fromMap(Map<String,dynamic> map){
    return InstructionsModel(
      initInterval: map['interval'][0], 
      endInterval : map['interval'][1], 
      description : map['text'], 
      streetName  : map['street_name'], 
      state       : map['state'] ?? 0,
      );
  }
  Map<String,dynamic> toMap(){
    return{
      'interval'   : [initInterval, endInterval],
      'text'       : description,
      'street_name': streetName,
      'state'      : state
    };
  }

}