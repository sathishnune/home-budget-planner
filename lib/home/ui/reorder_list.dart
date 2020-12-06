import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/database/database_util.dart';
import 'package:home_budget_app/home/redux/actions.dart';
import 'package:home_budget_app/home/redux/budget_app_state.dart';
import 'package:home_budget_app/home/ui/budget_details.dart';
import 'package:redux/redux.dart';

void reorderMonthlyRecords(BuildContext context,
    List<BudgetDetails> listOfMonthRecords, int oldIndex, int newIndex) {
  if (listOfMonthRecords.isEmpty || listOfMonthRecords.length == 1) {
    return;
  }
  if (newIndex > listOfMonthRecords.length) {
    newIndex = listOfMonthRecords.length;
  }
  if (newIndex > oldIndex) {
    newIndex--;
  }
  final List<BudgetDetails> modifiedList = listOfMonthRecords;
  final BudgetDetails budgetDetails = modifiedList.removeAt(oldIndex);
  modifiedList.insert(newIndex, budgetDetails);
  final Store<BudgetAppState> _state =
      StoreProvider.of<BudgetAppState>(context);
  _state.dispatch(FetchMonthlyRecords(list: modifiedList));
  // TODO(SathishNune): We may not need to update all the elements position.
  for (int i = 0; i < modifiedList.length; i++) {
    _state.dispatch(
        DBUtils.updateRecordOrder(modifiedList.elementAt(i).id, i + 1));
  }
}
