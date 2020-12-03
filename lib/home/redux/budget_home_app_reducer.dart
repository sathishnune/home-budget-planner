import 'package:home_budget_app/home/model/home_budget_overview.dart';
import 'package:home_budget_app/home/redux/actions.dart';
import 'package:home_budget_app/home/redux/budget_app_state.dart';
import 'package:home_budget_app/home/ui/budget_details.dart';
import 'package:home_budget_app/home/ui/home_budget_metrics.dart';
import 'package:home_budget_app/home/ui/utilities.dart';

BudgetAppState applicationReducer(BudgetAppState currentState, dynamic action) {
  if (null == action) {
    return currentState;
  }
  switch (action.runtimeType) {
    case AddNewRecord:
      return addRecordToState(currentState, action);
    case DeleteRecord:
      return deleteRecordFromState(currentState, action);
    case EditRecord:
      return updateRecord(currentState, action);
    case MonthRecords:
      List<HomeBudgetOverview> monthRecords = currentState.monthRecords;
      monthRecords ??= [];
      monthRecords.addAll(action.list);
      return currentState.clone(monthRecords: monthRecords);

    case ShowLoadingIndicator:
      return currentState.clone(isLoading: action.showIndicator);

    case FetchMonthlyRecords:
      return currentState.clone(
          listOfMonthRecords: action.list,
          budgetMetrics: updateTotalAmountsRef(action.list));

    case SelectedMonth:
      return currentState.clone(selectedMonthRecord: action.selectedRecord);

    case ValidCreateNewBudget:
      return currentState.clone(isCreateNewBudgetValid: action.isValid);

    case InsertHomeBudgetOverview:
      List<HomeBudgetOverview> monthRecords = [];
      if (null == currentState.monthRecords) {
        monthRecords = [];
      }
      monthRecords.add(action.budgetOverview);
      if (currentState.monthRecords == null ||
          currentState.monthRecords.isEmpty) {
        return currentState.clone(
            monthRecords: monthRecords,
            selectedMonthRecord: action.budgetOverview);
      }
      return currentState.clone(monthRecords: monthRecords);

    case DeleteMonthlyBudget:
      return deleteMonthlyBudget(currentState, action);

    default:
      return currentState;
  }
}

BudgetAppState updateRecord(BudgetAppState currentState, EditRecord action) {
  final List<BudgetDetails> listOfMonthRecords =
      currentState.listOfMonthRecords;
  final BudgetDetails recordToBeUpdated = listOfMonthRecords
      .firstWhere((BudgetDetails element) => element.id == action.record.id);
  if (null != recordToBeUpdated) {
    recordToBeUpdated.type = action.record.type;
    recordToBeUpdated.amount = action.record.amount;
    recordToBeUpdated.title = action.record.title;

    return currentState.clone(
        listOfMonthRecords: listOfMonthRecords,
        budgetMetrics: updateTotalAmountsRef(listOfMonthRecords));
  }
  return currentState;
}

BudgetAppState deleteRecordFromState(
    BudgetAppState currentState, DeleteRecord action) {
  final List<BudgetDetails> listOfMonthRecords =
      currentState.listOfMonthRecords;
  final BudgetDetails recordToBeDeleted = listOfMonthRecords
      .firstWhere((BudgetDetails element) => element.id == action.record.id);
  if (null != recordToBeDeleted) {
    listOfMonthRecords.remove(recordToBeDeleted);
    return currentState.clone(
        listOfMonthRecords: listOfMonthRecords,
        budgetMetrics: updateTotalAmountsRef(listOfMonthRecords));
  }
  return currentState;
}

/// Delete the selected month from month records.
BudgetAppState deleteMonthlyBudget(
    BudgetAppState currentState, dynamic action) {
  final List<HomeBudgetOverview> listOfMonths = currentState.monthRecords;
  final HomeBudgetOverview recordToBeDeleted = listOfMonths.firstWhere(
      (HomeBudgetOverview element) => element.id == action.selectedRecord.id);
  if (null != recordToBeDeleted) {
    listOfMonths.remove(recordToBeDeleted);
    final HomeBudgetOverview selRecord = currentState.selectedMonthRecord;
    selRecord.markAsDelete = true;
    return currentState.clone(
        monthRecords: listOfMonths,
        selectedMonthRecord: selRecord,
        listOfMonthRecords: [],
        budgetMetrics: HomeBudgetMetrics().getDefaultValues());
  }
  return currentState;
}

BudgetAppState addRecordToState(BudgetAppState currentState, dynamic action) {
  final List<BudgetDetails> listOfMonthRecords = [];
  if (currentState.listOfMonthRecords != null) {
    listOfMonthRecords.addAll(currentState.listOfMonthRecords);
  }
  listOfMonthRecords.add(action.record);
  return currentState.clone(
      listOfMonthRecords: listOfMonthRecords,
      budgetMetrics: updateTotalAmountsRef(listOfMonthRecords));
}
