import 'dart:async';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/database/database_util.dart';
import 'package:home_budget_app/home/model/home_budget_overview.dart';
import 'package:home_budget_app/home/redux/budget_app_state.dart';
import 'package:home_budget_app/home/redux/thunk_actions.dart';
import 'package:home_budget_app/home/ui/app_bar_title.dart';
import 'package:home_budget_app/home/ui/budget_details.dart';
import 'package:home_budget_app/home/ui/create_new_budget.dart';
import 'package:home_budget_app/home/ui/home_budget_drawer.dart';
import 'package:home_budget_app/home/ui/reorder_list.dart';
import 'package:home_budget_app/home/ui/summary_cards.dart';
import 'package:home_budget_app/home/ui/utilities.dart';
import 'package:redux/redux.dart';

class MyHomeBudgetApp extends StatefulWidget {
  const MyHomeBudgetApp({this.store});

  final Store<BudgetAppState> store;

  @override
  _MyHomeBudgetAppState createState() => _MyHomeBudgetAppState();
}

class _MyHomeBudgetAppState extends State<MyHomeBudgetApp> {
  @override
  Widget build(BuildContext context) {
    return StoreProvider<BudgetAppState>(
        store: widget.store,
        child: DynamicTheme(
            defaultBrightness: Brightness.light,
            data: (Brightness brightness) => ThemeData(
                  primarySwatch: Colors.indigo,
                  brightness: brightness,
                ),
            themedWidgetBuilder: (BuildContext context, ThemeData theme) {
              return MaterialApp(
                title: 'My Home Budget Planner',
                theme: theme,
                home: HomeWidget(),
              );
            }));
  }
}

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  String monthSelected = 'NA';

  String defaultMonthSelected() {
    final Store<BudgetAppState> _state =
        StoreProvider.of<BudgetAppState>(context);
    if (_state.state != null && _state.state.selectedMonthRecord != null) {
      return _state.state.selectedMonthRecord.displayName;
    }
    return monthSelected;
  }

  int i = 0;

  String onMonthArrowPressed(bool isLeft) {
    final Store<BudgetAppState> _state =
        StoreProvider.of<BudgetAppState>(context);
    final List<HomeBudgetOverview> months = _state.state.monthRecords;

    if (isLeft) {
      if (i != 0) {
        --i;
      }
    } else {
      if (i + 1 < months.length) {
        ++i;
      }
    }

    if (i >= 0 && i < months.length && months.elementAt(i) != null) {
      return months.elementAt(i).displayName;
    }
    return monthSelected;
  }

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 1), () => <void>{_getColorCode(context)});
  }

  void _getColorCode(BuildContext context) {
    DBUtils.getColorCode().then((List<Map<String, dynamic>> value) {
      if (null != value &&
          value.isNotEmpty &&
          null != value.first &&
          null != value.first.entries &&
          null != value.first.entries.first &&
          null != value.first.entries.first.value) {
        final int colorCode =
            Utils.cast<int>(value.first.entries.first.value);
        DynamicTheme.of(context).setThemeData(
            ThemeData(primaryColor: Color(colorCode ?? Colors.green.value)));
      }
    });
  }

  Widget buildTitleCard(BuildContext context) {
    final Store<BudgetAppState> _state =
        StoreProvider.of<BudgetAppState>(context);

    if (_state.state.monthRecords.isEmpty) {
      return Container(
        child: const Text('Home Budget Planner'),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          IconButton(
              icon: const Icon(
                Icons.arrow_left,
                size: 35,
              ),
              onPressed: () {
                final String monthName = onMonthArrowPressed(true);
                if (null != monthName) {
                  setState(() {
                    monthSelected = monthName;
                    _state.dispatch(
                        refreshMonthSpecificData(_state.state.monthRecords[i]));
                  });
                }
              }),
          Text(monthSelected),
          IconButton(
            icon: const Icon(
              Icons.arrow_right,
              size: 35,
            ),
            onPressed: () {
              final String monthName = onMonthArrowPressed(false);
              if (null != monthName) {
                setState(() {
                  monthSelected = monthName;
                  if (null != _state.state.monthRecords &&
                      _state.state.monthRecords.isNotEmpty &&
                      _state.state.monthRecords.length > i) {
                    _state.dispatch(
                        refreshMonthSpecificData(_state.state.monthRecords[i]));
                  }
                });
              }
            },
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    monthSelected = defaultMonthSelected();
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(title: AppBarTitle()),
        body: MyHomeBudgetAppBody(),
        floatingActionButton: floatingAddNewRecordToBudget(context, false),
        drawer: Drawer(
          child: Container(
            child: MyHomeBudgetDrawer(),
          ),
        ));
  }
}

class MyHomeBudgetAppBody extends StatelessWidget {
  Widget _noDetailsMonthlyBudget() {
    return const Center(
        child: Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Details not available. Please create records.',
        style: TextStyle(fontSize: 18),
      ),
    ));
  }

  Widget _noBudgetSelected(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            "Oops. You haven't created a monthly budget yet.",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: RaisedButton(
              child: const Text('CREATE BUDGET'),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                createNewBudget(context);
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<BudgetAppState, BudgetAppState>(
      distinct: true,
      converter: (Store<BudgetAppState> storeDetails) => storeDetails.state,
      builder: (BuildContext context, BudgetAppState storeDetails) {
        return Column(
          children: <Widget>[
            if (storeDetails.selectedMonthRecord == null)
              _noBudgetSelected(context),
            if (storeDetails.selectedMonthRecord != null)
              SummaryCards(
                  budgetMetrics: storeDetails.budgetMetrics,
                  selectedMonthRecord: storeDetails.selectedMonthRecord),
            if (storeDetails.selectedMonthRecord != null) HorizontalLine(),
            if (storeDetails.isLoading)
              const LinearProgressIndicator()
            else
              Container(),
            if (storeDetails.selectedMonthRecord != null)
              Expanded(
                child: (null ==
                            storeDetails
                                .selectedMonthRecord.listOfMonthRecords ||
                        storeDetails
                            .selectedMonthRecord.listOfMonthRecords.isEmpty)
                    ? _noDetailsMonthlyBudget()
                    : buildReOrderedListView(context, storeDetails),
              )
          ],
        );
      },
    );
  }

  ReorderableListView buildReOrderedListView(
      BuildContext context, BudgetAppState storeDetails) {
    return ReorderableListView(
      onReorder: (int oldIndex, int newIndex) => reorderMonthlyRecords(
          context,
          storeDetails.selectedMonthRecord.listOfMonthRecords,
          oldIndex,
          newIndex),
      children: storeDetails.selectedMonthRecord.listOfMonthRecords
          .map(
            (BudgetDetails budgetDetails) =>
                budgetCardItemBuilder(budgetDetails, context, false),
          )
          .toList(),
    );
  }
}
