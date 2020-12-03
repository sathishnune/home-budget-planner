import 'package:flutter/material.dart';
import 'package:home_budget_app/home/database/database_util.dart';
import 'package:home_budget_app/home/model/home_budget_monthly_details.dart';
import 'package:home_budget_app/home/model/home_budget_overview.dart';
import 'package:home_budget_app/home/redux/budget_app_state.dart';
import 'package:home_budget_app/home/redux/actions.dart';
import 'package:home_budget_app/home/ui/budget_details.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:uuid/uuid.dart';

Uuid uuid = Uuid();

ThunkAction<BudgetAppState> refreshMonthSpecificData(
    HomeBudgetOverview selectedRecord) {
  return (Store<BudgetAppState> store) async {
    store.dispatch(SelectedMonth(selectedRecord: selectedRecord));
    store.dispatch(fetchMonthRecords(selectedRecord.id));
  };
}

ThunkAction<BudgetAppState> fetchMonthRecords(String id) {
  return (Store<BudgetAppState> store) async {
    await DBUtils.monthlyDetails(id)
        .then((List<HomeBudgetMonthlyDetails> list) {
      final List<BudgetDetails> newList = list
          .map((HomeBudgetMonthlyDetails e) => BudgetDetails(
              id: e.id,
              title: e.title,
              amount: e.amount,
              status: null,
              type: e.transType))
          .toList();
      store.dispatch(ShowLoadingIndicator(showIndicator: false));
      store.dispatch(FetchMonthlyRecords(list: newList));
    });
  };
}

ThunkAction<BudgetAppState> fetchListOfMonths() {
  final DateTime currentDate = DateTime.now();
  return (Store<BudgetAppState> store) async {
    await DBUtils.budgetOverviews().then((List<HomeBudgetOverview> list) {
      final List<HomeBudgetOverview> newList = list
          .where(
              (HomeBudgetOverview element) => element.year == currentDate.year)
          .map((HomeBudgetOverview e) => HomeBudgetOverview(
                id: e.id,
                month: e.month,
                year: e.year,
                displayName: e.displayName,
              ))
          .toList();
      store.dispatch(ShowLoadingIndicator(showIndicator: false));
      if (newList.isNotEmpty) {
        // Loading month specific values now..
        store.dispatch(refreshMonthSpecificData(newList[0]));
      }
      store.dispatch(MonthRecords(list: newList));
    });
  };
}

/// Adding new record...
ThunkAction<BudgetAppState> addNewRecordWithThunk(BudgetDetails record) {
  return (Store<BudgetAppState> store) async {
    final HomeBudgetMonthlyDetails monthlyDetails = HomeBudgetMonthlyDetails(
        id: record.id,
        title: record.title,
        amount: record.amount,
        monthRef: store.state.selectedMonthRecord.id,
        transType: record.type);
    DBUtils.insertHomeBudgetMonthlyDetails(monthlyDetails);
    store.dispatch(AddNewRecord(record: record));
  };
}

/// Adding new record...
ThunkAction<BudgetAppState> addNewMonthlyBudget(
    DateTime selectedDate, String formattedDate, BuildContext buildContext) {
  return (Store<BudgetAppState> store) async {
    // Check if we have any record...
    DBUtils.checkIfWeHaveMonthExists(selectedDate.month, selectedDate.year)
        .then((List<HomeBudgetOverview> value) {
      if (value.isEmpty) {
        final HomeBudgetOverview budgetOverview = HomeBudgetOverview(
            month: selectedDate.month,
            year: selectedDate.year,
            displayName: formattedDate,
            id: uuid.v4());

        // Add if record not there..
        DBUtils.insertHomeBudgetOverview(budgetOverview);
        if (DateTime.now().year == selectedDate.year) {
          store.dispatch(InsertHomeBudgetOverview(budgetOverview));
        }

        Navigator.pop(buildContext);
      } else {
        store.dispatch(ValidCreateNewBudget(false));
      }
    });
  };
}

/// Adding new record...
ThunkAction<BudgetAppState> editRecordWithThunk(BudgetDetails record) {
  return (Store<BudgetAppState> store) async {
    DBUtils.updateHomeBudgetMonthlyDetails(HomeBudgetMonthlyDetails(
        id: record.id,
        transType: record.type,
        monthRef: store.state.selectedMonthRecord.id,
        amount: record.amount,
        title: record.title));
    store.dispatch(EditRecord(record: record));
  };
}

/// Delete the record
ThunkAction<BudgetAppState> deleteRecordWithThunk(BudgetDetails record) {
  return (Store<BudgetAppState> store) async {
    await DBUtils.deleteHomeBudgetMonthlyDetails(record.id);
    store.dispatch(DeleteRecord(record: record));
  };
}

ThunkAction<BudgetAppState> deleteMonthlyBudget(
    HomeBudgetOverview selectedRecord) {
  return (Store<BudgetAppState> store) async {
    await DBUtils.deleteHomeBudgetOverview(selectedRecord.id);
    store.dispatch(DeleteMonthlyBudget(selectedRecord: selectedRecord));
  };
}
