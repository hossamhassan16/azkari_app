import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/azkar_service.dart';
import '../../models/zikr_model.dart';

part 'azkar_detail_state.dart';

class AzkarDetailCubit extends Cubit<AzkarDetailState> {
  final AzkarService _azkarService;
  bool _isEditMode = false;

  AzkarDetailCubit(this._azkarService) : super(const AzkarDetailInitial());

  bool get isEditMode => _isEditMode;

  /// Toggle edit mode
  void toggleEditMode() {
    _isEditMode = !_isEditMode;
    emit(AzkarDetailEditMode(_isEditMode));
  }

  /// Save and exit edit mode
  void saveAndExitEditMode() {
    _isEditMode = false;
    emit(AzkarDetailEditMode(_isEditMode));
  }

  /// Update counter for a specific zikr
  Future<void> updateCounter({
    required String categoryName,
    required String zikrId,
    required int newCount,
  }) async {
    try {
      await _azkarService.saveProgress(categoryName, zikrId, newCount);
      emit(AzkarDetailCounterUpdated(
        categoryName: categoryName,
        zikrId: zikrId,
        newCount: newCount,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      emit(AzkarDetailError('خطأ في تحديث العداد: $e'));
    }
  }

  /// Decrement counter
  Future<void> decrementCounter({
    required String categoryName,
    required String zikrId,
    required int currentCount,
  }) async {
    if (currentCount > 0) {
      await updateCounter(
        categoryName: categoryName,
        zikrId: zikrId,
        newCount: currentCount - 1,
      );
    }
  }

  /// Add a custom zikr
  Future<void> addCustomZikr({
    required String categoryName,
    required ZikrModel zikr,
  }) async {
    try {
      await _azkarService.addCustomZikr(categoryName, zikr);
      emit(AzkarDetailZikrAdded(DateTime.now()));
    } catch (e) {
      emit(AzkarDetailError('خطأ في إضافة الذكر: $e'));
    }
  }

  /// Update an existing zikr
  Future<void> updateZikr({
    required String categoryName,
    required ZikrModel zikr,
  }) async {
    try {
      await _azkarService.updateZikr(categoryName, zikr);
      emit(AzkarDetailZikrUpdated(DateTime.now()));
    } catch (e) {
      emit(AzkarDetailError('خطأ في تحديث الذكر: $e'));
    }
  }

  /// Delete a zikr
  Future<void> deleteZikr({
    required String categoryName,
    required String zikrId,
  }) async {
    try {
      await _azkarService.deleteZikr(categoryName, zikrId);
      emit(AzkarDetailZikrDeleted(DateTime.now()));
    } catch (e) {
      emit(AzkarDetailError('خطأ في حذف الذكر: $e'));
    }
  }

  /// Reset to initial state
  void resetState() {
    emit(const AzkarDetailInitial());
  }
}
