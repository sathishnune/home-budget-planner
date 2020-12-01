import 'package:home_budget_app/home/BudgetDetails.dart';
import 'package:home_budget_app/home/HomeBudgetMetrics.dart';
import 'package:home_budget_app/home/model/HomeBudgetOverview.dart';
import 'package:home_budget_app/home/redux/BudgetAppState.dart';
import 'package:home_budget_app/home/redux/actions.dart';

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
      if (null == monthRecords) {
        monthRecords = [];
      }
      monthRecords.addAll(action.list);
      return currentState.clone(monthRecords: monthRecords);

    case ShowLoadingIndicator:
      return currentState.clone(isLoading: action.showIndicator);

    case FetchMonthlyRecords:
      return currentState.clone(
          listOfMonthRecords: action.list,
          budgetMetrics: _updateTotalAmountsRef(action.list));

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
      return currentState.clone(monthRecords: monthRecords);

    default:
      return currentState;
  }
}

BudgetAppState updateRecord(BudgetAppState currentState, EditRecord action) {
  final List<BudgetDetails> listOfMonthRecords =
      currentState.listOfMonthRecords;
  final BudgetDetails recordToBeUpdated = listOfMonthRecords
      .firstWhere((element) => element.id == action.record.id);
  if (null != recordToBeUpdated) {
    recordToBeUpdated.type = action.record.type;
    recordToBeUpdated.amount = action.record.amount;
    recordToBeUpdated.title = action.record.title;

    return currentState.clone(
        listOfMonthRecords: listOfMonthRecords,
        budgetMetrics: _updateTotalAmountsRef(listOfMonthRecords));
  }
  return currentState;
}

BudgetAppState deleteRecordFromState(
    BudgetAppState currentState, DeleteRecord action) {
  final List<BudgetDetails> listOfMonthRecords =
      currentState.listOfMonthRecords;
  final BudgetDetails recordToBeDeleted = listOfMonthRecords
      .firstWhere((element) => element.id == action.record.id);
  if (null != recordToBeDeleted) {
    listOfMonthRecords.remove(recordToBeDeleted);
    return currentState.clone(
        listOfMonthRecords: listOfMonthRecords,
        budgetMetrics: _updateTotalAmountsRef(listOfMonthRecords));
  }
  return currentState;
}

BudgetAppState addRecordToState(BudgetAppState currentState, action) {
  List<BudgetDetails> listOfMonthRecords = [];
  if (currentState.listOfMonthRecords != null) {
    listOfMonthRecords.addAll(currentState.listOfMonthRecords);
  }
  listOfMonthRecords.add(action.record);
  return currentState.clone(
      listOfMonthRecords: listOfMonthRecords,
      budgetMetrics: _updateTotalAmountsRef(listOfMonthRecords));
}

HomeBudgetMetrics _updateTotalAmountsRef(List<BudgetDetails> list) {
  int totalIncome = 0;
  int totalSpent = 0;

  list.forEach((element) {
    if (element.type == "Credit") {
      totalIncome += element.amount;
    } else {
      totalSpent += element.amount;
    }
  });

  return HomeBudgetMetrics(
      0, totalSpent, (totalIncome - totalSpent), totalIncome);
}
