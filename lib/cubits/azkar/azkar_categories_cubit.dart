import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/azkar_category_model.dart';
import '../../services/azkar_service.dart';

part 'azkar_categories_state.dart';

class AzkarCategoriesCubit extends Cubit<AzkarCategoriesState> {
  final AzkarService _azkarService;

  AzkarCategoriesCubit(this._azkarService)
      : super(const AzkarCategoriesInitial());

  /// Load all azkar categories
  Future<void> loadCategories() async {
    try {
      emit(const AzkarCategoriesLoading());
      final categories = await _azkarService.loadAzkarCategories();
      emit(AzkarCategoriesLoaded(categories));
    } catch (e) {
      emit(AzkarCategoriesError('خطأ في تحميل البيانات: $e'));
    }
  }

  /// Refresh categories (reload from service)
  Future<void> refreshCategories() async {
    await loadCategories();
  }

  /// Add a custom category
  Future<void> addCustomCategory(String categoryName) async {
    try {
      await _azkarService.addCustomCategory(categoryName);
      await loadCategories(); // Reload to reflect changes
    } catch (e) {
      emit(AzkarCategoriesError('خطأ في إضافة المجموعة: $e'));
    }
  }
}
