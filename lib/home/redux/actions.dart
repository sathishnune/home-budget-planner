import 'package:home_budget_app/home/BudgetDetails.dart';
import 'package:home_budget_app/home/model/HomeBudgetOverview.dart';

class AddNewRecord {
  final BudgetDetails record;

  AddNewRecord({this.record});
}

class FetchMonthlyRecords {
  final List<BudgetDetails> list;

  FetchMonthlyRecords({this.list});
}

class MonthRecords {
  final List<HomeBudgetOverview> list;

  MonthRecords({this.list});
}

class SelectedMonth {
  final HomeBudgetOverview selectedRecord;

  SelectedMonth({this.selectedRecord});
}

class DeleteRecord {
  final BudgetDetails record;

  DeleteRecord({this.record});
}

class ShowLoadingIndicator {
  final bool showIndicator;

  ShowLoadingIndicator({this.showIndicator});
}

class EditRecord {
  final BudgetDetails record;

  EditRecord({this.record});
}

class ValidCreateNewBudget {
  final bool isValid;

  ValidCreateNewBudget(this.isValid);
}

class InsertHomeBudgetOverview {
  final HomeBudgetOverview budgetOverview;

  InsertHomeBudgetOverview(this.budgetOverview);
}
