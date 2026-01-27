import 'package:equatable/equatable.dart';
import 'package:azkari_app/models/question_of_the_day_model.dart';

abstract class DailyQuestionState extends Equatable {
  const DailyQuestionState();
  
  @override
  List<Object?> get props => [];
}

class DailyQuestionInitial extends DailyQuestionState {
  const DailyQuestionInitial();
}

class DailyQuestionLoading extends DailyQuestionState {
  const DailyQuestionLoading();
}

class DailyQuestionLoaded extends DailyQuestionState {
  final Question question;
  final String? selectedAnswer;
  final bool? isCorrect;
  
  const DailyQuestionLoaded(
    this.question, {
    this.selectedAnswer,
    this.isCorrect,
  });
  
  @override
  List<Object?> get props => [question, selectedAnswer, isCorrect];
  
  DailyQuestionLoaded copyWith({
    Question? question,
    String? selectedAnswer,
    bool? isCorrect,
  }) {
    return DailyQuestionLoaded(
      question ?? this.question,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}

class DailyQuestionError extends DailyQuestionState {
  final String message;
  
  const DailyQuestionError(this.message);
  
  @override
  List<Object?> get props => [message];
}
