import 'package:flutter/material.dart';
import 'package:home_budget_app/home/model/home_budget_overview.dart';
import 'package:home_budget_app/home/ui/home_budget_metrics.dart';

/// State has to be immutable for redux to detect the changes.
/// Clone should have same existing state along with new updates.
@immutable
class BudgetAppState {
  const BudgetAppState(
      {this.monthRecords,
      this.budgetMetrics,
      this.isLoading,
      this.isCreateNewBudgetValid,
      this.selectedMonthRecord,
      this.applicationTheme});

  final List<HomeBudgetOverview> monthRecords;
  final HomeBudgetMetrics budgetMetrics;
  final bool isLoading;
  final bool isCreateNewBudgetValid;
  final HomeBudgetOverview selectedMonthRecord;
  final ThemeData applicationTheme;

  BudgetAppState clone(
      {final List<HomeBudgetOverview> monthRecords,
      final HomeBudgetMetrics budgetMetrics,
      final bool isLoading,
      final bool isCreateNewBudgetValid,
      final HomeBudgetOverview selectedMonthRecord,
      final ThemeData applicationTheme}) {
    return BudgetAppState(
        applicationTheme: applicationTheme ?? this.applicationTheme,
        monthRecords: monthRecords ?? this.monthRecords,
        budgetMetrics: budgetMetrics ?? this.budgetMetrics,
        isLoading: isLoading ?? this.isLoading,
        isCreateNewBudgetValid:
            isCreateNewBudgetValid ?? this.isCreateNewBudgetValid,
        selectedMonthRecord: selectedMonthRecord == null
            ? this.selectedMonthRecord
            : selectedMonthRecord.markAsDelete
                ? null
                : selectedMonthRecord);
  }
}
