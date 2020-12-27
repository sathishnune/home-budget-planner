import 'package:flutter/material.dart';
import 'package:home_budget_app/home/model/home_budget_overview.dart';
import 'package:home_budget_app/home/ui/budget_details.dart';

class AddNewRecord {
  AddNewRecord({this.record});

  final BudgetDetails record;
}

class FetchMonthlyRecords {
  FetchMonthlyRecords({this.list});

  final List<BudgetDetails> list;
}

class MonthRecords {
  MonthRecords({this.list});

  final List<HomeBudgetOverview> list;
}

class SelectedMonth {
  SelectedMonth({this.selectedRecord});

  final HomeBudgetOverview selectedRecord;
}

class DeleteRecord {
  DeleteRecord({this.record});

  final BudgetDetails record;
}

class DeleteMonthlyBudget {
  DeleteMonthlyBudget({this.selectedRecord});

  final HomeBudgetOverview selectedRecord;
}

class ShowLoadingIndicator {
  ShowLoadingIndicator({this.showIndicator});

  final bool showIndicator;
}

class EditRecord {
  EditRecord({this.record});

  final BudgetDetails record;
}

class ValidCreateNewBudget {
  ValidCreateNewBudget(this.isValid);

  final bool isValid;
}

class InsertHomeBudgetOverview {
  InsertHomeBudgetOverview(this.budgetOverview);

  final HomeBudgetOverview budgetOverview;
}

class UpdateStatus extends SuperClass {
  UpdateStatus({this.isCompleted, this.id});

  final bool isCompleted;
  final String id;
}

class AddRecurringRecord {
  AddRecurringRecord({this.recurringRecord});

  final BudgetDetails recurringRecord;
}

class EditRecurringRecord {
  EditRecurringRecord({this.recurringRecord});

  final BudgetDetails recurringRecord;
}

class ListOfRecurringRecords {
  ListOfRecurringRecords({this.listOfRecurringRecords});

  final List<BudgetDetails> listOfRecurringRecords;
}

class DeleteRecurringRecord {
  DeleteRecurringRecord({this.recurringRecord});

  final BudgetDetails recurringRecord;
}

class SuperClass {}
