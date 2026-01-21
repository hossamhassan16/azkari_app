part of 'azkar_detail_cubit.dart';

abstract class AzkarDetailState extends Equatable {
  const AzkarDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AzkarDetailInitial extends AzkarDetailState {
  const AzkarDetailInitial();
}

/// Edit mode state
class AzkarDetailEditMode extends AzkarDetailState {
  final bool isEditMode;

  const AzkarDetailEditMode(this.isEditMode);

  @override
  List<Object?> get props => [isEditMode];
}

/// Counter updated state
class AzkarDetailCounterUpdated extends AzkarDetailState {
  final String categoryName;
  final String zikrId;
  final int newCount;
  final DateTime timestamp;

  const AzkarDetailCounterUpdated({
    required this.categoryName,
    required this.zikrId,
    required this.newCount,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [categoryName, zikrId, newCount, timestamp];
}

/// Zikr added state
class AzkarDetailZikrAdded extends AzkarDetailState {
  final DateTime timestamp;

  const AzkarDetailZikrAdded(this.timestamp);

  @override
  List<Object?> get props => [timestamp];
}

/// Zikr updated state
class AzkarDetailZikrUpdated extends AzkarDetailState {
  final DateTime timestamp;

  const AzkarDetailZikrUpdated(this.timestamp);

  @override
  List<Object?> get props => [timestamp];
}

/// Zikr deleted state
class AzkarDetailZikrDeleted extends AzkarDetailState {
  final DateTime timestamp;

  const AzkarDetailZikrDeleted(this.timestamp);

  @override
  List<Object?> get props => [timestamp];
}

/// Error state
class AzkarDetailError extends AzkarDetailState {
  final String message;

  const AzkarDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
