import 'dart:convert';
import 'package:azkari_app/cubits/cubit/questions_state.dart';
import 'package:azkari_app/models/question_of_the_day_model.dart';
import 'package:azkari_app/services/daily_question_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyQuestionCubit extends Cubit<DailyQuestionState> {
  final DailyQuestionService service;
  final SharedPreferences prefs;

  static const _questionKey = 'daily_question';
  static const _timeKey = 'daily_question_time';

  DailyQuestionCubit(this.service, this.prefs) 
      : super(const DailyQuestionInitial());

  Future<void> loadDailyQuestion() async {
    emit(const DailyQuestionLoading());

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final savedTime = prefs.getInt(_timeKey);

      // لو لسه في نفس الـ 24 ساعة
      if (savedTime != null &&
          now - savedTime < const Duration(hours: 24).inMilliseconds) {
        final savedQuestionJson = prefs.getString(_questionKey);
        if (savedQuestionJson != null) {
          final question = Question.fromJson(json.decode(savedQuestionJson));
          emit(DailyQuestionLoaded(question));
          return;
        }
      }

      // اختيار سؤال جديد
      final questions = await service.loadQuestions();
      final randomQuestion = service.getRandomQuestion(questions);

      await prefs.setString(_questionKey, json.encode(randomQuestion.toJson()));
      await prefs.setInt(_timeKey, now);

      emit(DailyQuestionLoaded(randomQuestion));
    } catch (e) {
      emit(const DailyQuestionError('حدث خطأ أثناء تحميل السؤال'));
    }
  }

  /// Check if the selected answer is correct
  void selectAnswer(String selectedAnswer) {
    final currentState = state;
    if (currentState is DailyQuestionLoaded) {
      final isCorrect = selectedAnswer == currentState.question.correctAnswer;
      emit(currentState.copyWith(
        selectedAnswer: selectedAnswer,
        isCorrect: isCorrect,
      ));
    }
  }

  /// Reset answer selection
  void resetAnswer() {
    final currentState = state;
    if (currentState is DailyQuestionLoaded) {
      emit(DailyQuestionLoaded(currentState.question));
    }
  }
}

