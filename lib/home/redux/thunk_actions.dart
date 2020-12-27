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
              type: e.transType,
              isCompleted: e.status == 1))
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
    final int recordOrder = (store.state.selectedMonthRecord != null &&
            store.state.selectedMonthRecord.listOfMonthRecords != null)
        ? store.state.selectedMonthRecord.listOfMonthRecords.length
        : 0;
    DBUtils.insertHomeBudgetMonthlyDetails(monthlyDetails, recordOrder);
    store.dispatch(AddNewRecord(record: record));
  };
}

ThunkAction<BudgetAppState> addNewRecurringRecord(BudgetDetails record) {
  return (Store<BudgetAppState> store) async {
    final HomeBudgetMonthlyDetails monthlyDetails = HomeBudgetMonthlyDetails(
        id: record.id,
        title: record.title,
        amount: record.amount,
        transType: record.type);

    DBUtils.insertHomeBudgetRecurringDetails(monthlyDetails);
    store.dispatch(AddRecurringRecord(recurringRecord: record));
  };
}

/// Adding new record...
ThunkAction<BudgetAppState> addNewMonthlyBudget(
    DateTime selectedDate,
    String formattedDate,
    BuildContext buildContext,
    bool copyRecurringRecords) {
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
        DBUtils.insertHomeBudgetOverview(budgetOverview).then((value) {
          if (true == copyRecurringRecords) {
            DBUtils.recurringRecords().then((List<BudgetDetails> value) {
              int i = 0;
              value.forEach((BudgetDetails element) {
                final HomeBudgetMonthlyDetails details =
                    HomeBudgetMonthlyDetails(
                        id: uuid.v4(),
                        status: 0,
                        title: element.title,
                        amount: element.amount,
                        monthRef: budgetOverview.id,
                        transType: element.type,
                        recordOrder: i);
                DBUtils.insertHomeBudgetMonthlyDetails(details, i);
                i++;
              });
              budgetOverview.listOfMonthRecords = value;
              if (DateTime.now().year == selectedDate.year) {
                store.dispatch(InsertHomeBudgetOverview(budgetOverview));
              }
            });
          } else {
            if (DateTime.now().year == selectedDate.year) {
              store.dispatch(InsertHomeBudgetOverview(budgetOverview));
            }
          }
        });

        Navigator.pop(buildContext);
      } else {
        store.dispatch(ValidCreateNewBudget(false));
      }
    });
  };
}

/// Edit new record...
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

/// Edit new record...
ThunkAction<BudgetAppState> editRecurringRecord(BudgetDetails record) {
  return (Store<BudgetAppState> store) async {
    DBUtils.updateHomeBudgetRecurringDetails(HomeBudgetMonthlyDetails(
        id: record.id,
        transType: record.type,
        amount: record.amount,
        title: record.title));
    store.dispatch(EditRecurringRecord(recurringRecord: record));
  };
}

ThunkAction<BudgetAppState> fetchRecurringRecords() {
  return (Store<BudgetAppState> store) async {
    DBUtils.recurringRecords().then((List<BudgetDetails> value) {
      store.dispatch(ListOfRecurringRecords(listOfRecurringRecords: value));
    });
  };
}

/// Delete the record
ThunkAction<BudgetAppState> deleteRecordWithThunk(BudgetDetails record) {
  return (Store<BudgetAppState> store) async {
    await DBUtils.deleteHomeBudgetMonthlyDetails(record.id);
    store.dispatch(DeleteRecord(record: record));
  };
}

ThunkAction<BudgetAppState> deleteRecurringRecord(BudgetDetails record) {
  return (Store<BudgetAppState> store) async {
    await DBUtils.deleteRecurringRecord(record.id);
    store.dispatch(DeleteRecurringRecord(recurringRecord: record));
  };
}

ThunkAction<BudgetAppState> deleteMonthlyBudget(
    HomeBudgetOverview selectedRecord) {
  return (Store<BudgetAppState> store) async {
    await DBUtils.deleteHomeBudgetOverview(selectedRecord.id);
    store.dispatch(DeleteMonthlyBudget(selectedRecord: selectedRecord));
  };
}

ThunkAction<BudgetAppState> updateRecordStatus(String id, bool status) {
  return (Store<BudgetAppState> store) async {
    await DBUtils.updateRecordStatus(id, status);
    store.dispatch(UpdateStatus(isCompleted: status, id: id));
  };
}
