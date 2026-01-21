part of 'azkar_categories_cubit.dart';

abstract class AzkarCategoriesState extends Equatable {
  const AzkarCategoriesState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no data loaded yet
class AzkarCategoriesInitial extends AzkarCategoriesState {
  const AzkarCategoriesInitial();
}

/// Loading state - fetching categories
class AzkarCategoriesLoading extends AzkarCategoriesState {
  const AzkarCategoriesLoading();
}

/// Success state - categories loaded successfully
class AzkarCategoriesLoaded extends AzkarCategoriesState {
  final List<AzkarCategoryModel> categories;

  const AzkarCategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

/// Error state - failed to load categories
class AzkarCategoriesError extends AzkarCategoriesState {
  final String message;

  const AzkarCategoriesError(this.message);

  @override
  List<Object?> get props => [message];
}
