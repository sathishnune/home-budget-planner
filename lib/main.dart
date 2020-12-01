import 'package:flutter/material.dart';
import 'package:home_budget_app/home/BudgetDetails.dart';
import 'package:home_budget_app/home/HomeBudgetMetrics.dart';
import 'package:home_budget_app/home/redux/BudgetAppState.dart';
import 'package:home_budget_app/home/redux/BudgetHomeAppReducer.dart';
import 'package:home_budget_app/home/redux/ThunkActions.dart';
import 'package:home_budget_app/home/redux/actions.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'home/MyHomeBudgetApp.dart';

void main() {
  final _initialState = BudgetAppState(
      monthRecords: [],
      budgetMetrics: _updateTotalAmountsRef([]),
      isLoading: false,
      isCreateNewBudgetValid: true);
  final Store<BudgetAppState> _store = Store<BudgetAppState>(applicationReducer,
      initialState: _initialState, middleware: [thunkMiddleware]);

  runApp(MyHomeBudgetApp(store: _store));
  _store.dispatch(ShowLoadingIndicator(showIndicator: true));
  _store.dispatch(fetchListOfMonths());
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
