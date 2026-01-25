import 'dart:convert';
import 'dart:math';
import 'package:azkari_app/models/question_of_the_day_model.dart';
import 'package:flutter/services.dart';

class DailyQuestionService {
  Future<List<Question>> loadQuestions() async {
    final jsonString =
        await rootBundle.loadString('assets/data/questions.json');

    final List data = json.decode(jsonString);
    return data.map((e) => Question.fromJson(e)).toList();
  }

  Question getRandomQuestion(List<Question> questions) {
    final random = Random();
    return questions[random.nextInt(questions.length)];
  }
}
