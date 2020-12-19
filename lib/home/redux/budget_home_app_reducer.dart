import 'package:home_budget_app/home/database/database_util.dart';
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
  switch (DBUtils.cast<Type>(action.runtimeType)) {
    case AddNewRecord:
      return addRecordToState(currentState, action);
    case DeleteRecord:
      return deleteRecordFromState(
          currentState, DBUtils.cast<DeleteRecord>(action));
    case EditRecord:
      return updateRecord(currentState, DBUtils.cast<EditRecord>(action));
    case MonthRecords:
      List<HomeBudgetOverview> monthRecords = currentState.monthRecords;
      monthRecords ??= List<HomeBudgetOverview>.of(<HomeBudgetOverview>[]);
      monthRecords.addAll(DBUtils.cast<List<HomeBudgetOverview>>(action.list));
      return currentState.clone(monthRecords: monthRecords);

    case ShowLoadingIndicator:
      return currentState.clone(
          isLoading: DBUtils.cast<bool>(action.showIndicator));

    case FetchMonthlyRecords:
      final HomeBudgetOverview selectedMonthRecord =
          currentState.selectedMonthRecord;
      selectedMonthRecord.listOfMonthRecords =
          DBUtils.cast<List<BudgetDetails>>(action.list);
      return currentState.clone(
          selectedMonthRecord: selectedMonthRecord,
          budgetMetrics: updateTotalAmountsRef(
              DBUtils.cast<List<BudgetDetails>>(action.list)));

    case SelectedMonth:
      return currentState.clone(
          selectedMonthRecord:
              DBUtils.cast<HomeBudgetOverview>(action.selectedRecord));

    case ValidCreateNewBudget:
      return currentState.clone(
          isCreateNewBudgetValid: DBUtils.cast<bool>(action.isValid));

    case InsertHomeBudgetOverview:
      List<HomeBudgetOverview> monthRecords = <HomeBudgetOverview>[];
      if (null == currentState.monthRecords) {
        monthRecords = <HomeBudgetOverview>[];
      } else {
        monthRecords = currentState.monthRecords;
      }
      monthRecords.add(DBUtils.cast<HomeBudgetOverview>(action.budgetOverview));

      _sortMonthRecords(monthRecords);

      return currentState.clone(
          monthRecords: monthRecords,
          selectedMonthRecord:
              DBUtils.cast<HomeBudgetOverview>(action.budgetOverview),
          budgetMetrics: updateTotalAmountsRef([]));

    case DeleteMonthlyBudget:
      return deleteMonthlyBudget(currentState, action);

    case UpdateStatus:
      return updateTheRecordStatus(
          currentState,
          DBUtils.cast<bool>(action.isCompleted),
          DBUtils.cast<String>(action.id));

    default:
      return currentState;
  }
}

List<HomeBudgetOverview> _sortMonthRecords(
    List<HomeBudgetOverview> monthRecords) {
  monthRecords.sort((HomeBudgetOverview ele1, HomeBudgetOverview ele2) =>
      ele2.month.compareTo(ele1.month));
}

BudgetAppState updateTheRecordStatus(
    BudgetAppState currentState, bool isCompleted, String id) {
  final List<BudgetDetails> listOfMonthRecords =
      currentState.selectedMonthRecord.listOfMonthRecords;
  final BudgetDetails recordToBeUpdated = listOfMonthRecords
      .firstWhere((BudgetDetails element) => element.id == id, orElse: null);
  if (null != recordToBeUpdated) {
    recordToBeUpdated.isCompleted = isCompleted;
    return currentState.clone(
        selectedMonthRecord: currentState.selectedMonthRecord);
  }
  return currentState;
}

BudgetAppState updateRecord(BudgetAppState currentState, EditRecord action) {
  final List<BudgetDetails> listOfMonthRecords =
      currentState.selectedMonthRecord.listOfMonthRecords;
  final BudgetDetails recordToBeUpdated = listOfMonthRecords
      .firstWhere((BudgetDetails element) => element.id == action.record.id);
  if (null != recordToBeUpdated) {
    recordToBeUpdated.type = action.record.type;
    recordToBeUpdated.amount = action.record.amount;
    recordToBeUpdated.title = action.record.title;
    currentState.selectedMonthRecord.listOfMonthRecords = listOfMonthRecords;
    return currentState.clone(
        selectedMonthRecord: currentState.selectedMonthRecord,
        budgetMetrics: updateTotalAmountsRef(listOfMonthRecords));
  }
  return currentState;
}

BudgetAppState deleteRecordFromState(
    BudgetAppState currentState, DeleteRecord action) {
  final List<BudgetDetails> listOfMonthRecords =
      currentState.selectedMonthRecord.listOfMonthRecords;
  final BudgetDetails recordToBeDeleted = listOfMonthRecords
      .firstWhere((BudgetDetails element) => element.id == action.record.id);
  if (null != recordToBeDeleted) {
    listOfMonthRecords.remove(recordToBeDeleted);
    currentState.selectedMonthRecord.listOfMonthRecords = listOfMonthRecords;
    return currentState.clone(
        selectedMonthRecord: currentState.selectedMonthRecord,
        budgetMetrics: updateTotalAmountsRef(listOfMonthRecords));
  }
  return currentState;
}

/// Delete the selected month from month records.
BudgetAppState deleteMonthlyBudget(
    BudgetAppState currentState, dynamic action) {
  final List<HomeBudgetOverview> listOfMonths = currentState.monthRecords;
  HomeBudgetOverview recordToBeDeleted;
  if (listOfMonths.isNotEmpty) {
    recordToBeDeleted = listOfMonths.firstWhere(
        (HomeBudgetOverview element) => element.id == action.selectedRecord.id,
        orElse: null);
  }

  if (null != recordToBeDeleted) {
    listOfMonths.remove(recordToBeDeleted);
    HomeBudgetOverview selRecord;
    if (listOfMonths.isNotEmpty) {
      selRecord = listOfMonths.elementAt(0);
    } else {
      selRecord = currentState.selectedMonthRecord;
      selRecord.markAsDelete = true;
    }
    return currentState.clone(
        monthRecords: listOfMonths,
        selectedMonthRecord: selRecord,
        budgetMetrics: HomeBudgetMetrics().getDefaultValues());
  }
  return currentState;
}

BudgetAppState addRecordToState(BudgetAppState currentState, dynamic action) {
  final List<BudgetDetails> listOfMonthRecords = <BudgetDetails>[];
  // TODO(Sathishnune): Need fix..
  if (currentState.selectedMonthRecord != null &&
      currentState.selectedMonthRecord.listOfMonthRecords != null) {
    listOfMonthRecords
        .addAll(currentState.selectedMonthRecord.listOfMonthRecords);
  }
  listOfMonthRecords.add(DBUtils.cast<BudgetDetails>(action.record));
  currentState.selectedMonthRecord.listOfMonthRecords = listOfMonthRecords;
  return currentState.clone(
      selectedMonthRecord: currentState.selectedMonthRecord,
      budgetMetrics: updateTotalAmountsRef(listOfMonthRecords));
}
