import 'package:flutter/material.dart';
import 'package:home_budget_app/home/model/home_budget_overview.dart';
import 'package:home_budget_app/home/redux/actions.dart';
import 'package:home_budget_app/home/redux/budget_app_state.dart';
import 'package:home_budget_app/home/redux/budget_home_app_reducer.dart';
import 'package:home_budget_app/home/redux/thunk_actions.dart';
import 'package:home_budget_app/home/ui/budget_details.dart';
import 'package:home_budget_app/home/ui/home_budget_metrics.dart';
import 'package:home_budget_app/home/ui/my_home_budget_app.dart';
import 'package:home_budget_app/home/ui/theme.dart';
import 'package:home_budget_app/home/ui/utilities.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

void main() {
  final BudgetAppState _initialState = BudgetAppState(
      monthRecords: <HomeBudgetOverview>[],
      budgetMetrics: updateTotalAmountsRef(<BudgetDetails>[]),
      isLoading: false,
      isCreateNewBudgetValid: true);
  final Store<BudgetAppState> _store = Store<BudgetAppState>(applicationReducer,
      initialState: _initialState, middleware: [thunkMiddleware]);

  runApp(MyHomeBudgetApp(store: _store));
  _store.dispatch(getApplicationTheme());
  _store.dispatch(ShowLoadingIndicator(showIndicator: true));
  _store.dispatch(fetchListOfMonths());
}
