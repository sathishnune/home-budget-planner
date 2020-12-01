import 'package:flutter/material.dart';
import 'package:home_budget_app/home/BudgetDetails.dart';
import 'package:home_budget_app/home/HomeBudgetMetrics.dart';
import 'package:home_budget_app/home/model/HomeBudgetOverview.dart';

/// State has to be immutable for redux to detect the changes.
/// Clone should have same existing state along with new updates.
@immutable
class BudgetAppState {
  final List<HomeBudgetOverview> monthRecords;
  final HomeBudgetMetrics budgetMetrics;
  final bool isLoading;
  final bool isCreateNewBudgetValid;
  final List<BudgetDetails> listOfMonthRecords;
  final HomeBudgetOverview selectedMonthRecord;

  BudgetAppState(
      {this.monthRecords,
      this.budgetMetrics,
      this.isLoading,
      this.isCreateNewBudgetValid,
      this.listOfMonthRecords,
      this.selectedMonthRecord});

  BudgetAppState clone(
      {final List<HomeBudgetOverview> monthRecords,
      final HomeBudgetMetrics budgetMetrics,
      final bool isLoading,
      final bool isCreateNewBudgetValid,
      final List<BudgetDetails> listOfMonthRecords,
      final HomeBudgetOverview selectedMonthRecord}) {
    return new BudgetAppState(
        monthRecords: null != monthRecords ? monthRecords : this.monthRecords,
        budgetMetrics:
            null != budgetMetrics ? budgetMetrics : this.budgetMetrics,
        isLoading: null != isLoading ? isLoading : this.isLoading,
        isCreateNewBudgetValid: null != isCreateNewBudgetValid
            ? isCreateNewBudgetValid
            : this.isCreateNewBudgetValid,
        listOfMonthRecords: null != listOfMonthRecords
            ? listOfMonthRecords
            : this.listOfMonthRecords,
        selectedMonthRecord: null != selectedMonthRecord
            ? selectedMonthRecord
            : this.selectedMonthRecord);
  }
}
