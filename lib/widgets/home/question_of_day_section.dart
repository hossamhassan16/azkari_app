import 'package:azkari_app/cubits/cubit/questions_cubit.dart';
import 'package:azkari_app/cubits/cubit/questions_state.dart';
import 'package:azkari_app/services/daily_question_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class QuestionOfDaySection extends StatelessWidget {
  const QuestionOfDaySection({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink(); // Return empty while loading
        }

        return BlocProvider(
          create: (context) => DailyQuestionCubit(
            DailyQuestionService(),
            snapshot.data!,
          )..loadDailyQuestion(),
          child: const QuestionOfDaySectionView(),
        );
      },
    );
  }
}

class QuestionOfDaySectionView extends StatelessWidget {
  const QuestionOfDaySectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.questionOfTheDay,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.info_outline,
                  color: AppColors.white,
                  size: 20,
                ),
                onPressed: () {
                  // Handle info
                },
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: BlocBuilder<DailyQuestionCubit, DailyQuestionState>(
            builder: (context, state) {
              if (state is DailyQuestionLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                );
              }

              if (state is DailyQuestionError) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                    ),
                  ),
                );
              }

              if (state is DailyQuestionLoaded) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Text
                    Text(
                      state.question.question,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Options
                    ...List.generate(
                      state.question.options.length,
                      (index) {
                        final option = state.question.options[index];
                        final isSelected = state.selectedAnswer == option;
                        final isCorrectAnswer =
                            option == state.question.correctAnswer;
                        final showResult = state.selectedAnswer != null;

                        // Determine colors based on selection and correctness
                        Color borderColor = AppColors.primaryGreen;
                        Color? backgroundColor;

                        if (showResult) {
                          if (isSelected) {
                            // User selected this option
                            if (state.isCorrect == true) {
                              // Correct answer - green
                              borderColor = Colors.green;
                              backgroundColor = Colors.green.withOpacity(0.2);
                            } else {
                              // Wrong answer - red
                              borderColor = Colors.red;
                              backgroundColor = Colors.red.withOpacity(0.2);
                            }
                          } else if (isCorrectAnswer) {
                            // Show correct answer in green
                            borderColor = Colors.green;
                            backgroundColor = Colors.green.withOpacity(0.1);
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: state.selectedAnswer == null
                                ? () {
                                    context
                                        .read<DailyQuestionCubit>()
                                        .selectAnswer(option);
                                  }
                                : null,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: borderColor,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? borderColor
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: borderColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 12,
                                            color: AppColors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  // Show icon for correct/wrong after selection
                                  if (showResult && isSelected)
                                    Icon(
                                      state.isCorrect == true
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: state.isCorrect == true
                                          ? Colors.green
                                          : Colors.red,
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Feedback message
                    if (state.selectedAnswer != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: state.isCorrect == true
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              state.isCorrect == true
                                  ? Icons.check_circle
                                  : Icons.info_outline,
                              color: state.isCorrect == true
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.isCorrect == true
                                    ? '🎉 أحسنت! إجابتك صحيحة'
                                    : 'الإجابة الصحيحة هي: ${state.question.correctAnswer}',
                                style: TextStyle(
                                  color: state.isCorrect == true
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                  ],
                );
              }

              // Initial state
              return const Center(
                child: Text(
                  'جاري التحميل...',
                  style: TextStyle(color: AppColors.white),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
