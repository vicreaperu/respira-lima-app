class QuestionModel{
  late int id;
  final String question;
  final String answer;
  bool isExpanded;
  QuestionModel(
    {
      required this.question, 
      required this.answer,
      this.isExpanded = false,
    });
  static QuestionModel fromMap(Map<String, dynamic> map){
    return QuestionModel(
      question: map['question'], 
      answer: map['answer']
      );
  }
  Map<String, dynamic> toMap(){
    return{
      'question' : question,
      'answer'   : answer,
    };
  }
}