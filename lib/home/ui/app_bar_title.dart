import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/model/home_budget_overview.dart';
import 'package:home_budget_app/home/redux/budget_app_state.dart';
import 'package:home_budget_app/home/redux/thunk_actions.dart';
import 'package:redux/redux.dart';

class AppBarTitle extends StatefulWidget {
  @override
  _AppBarTitleState createState() => _AppBarTitleState();
}

class _AppBarTitleState extends State<AppBarTitle> {
  String monthSelected;
  int i = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<BudgetAppState, BudgetAppState>(
        distinct: true,
        converter: (Store<BudgetAppState> storeDetails) => storeDetails.state,
        builder: (BuildContext context, BudgetAppState storeDetails) {
          monthSelected = storeDetails.selectedMonthRecord?.displayName;
          i = _findSelectedMonthIndex(storeDetails);
          if (storeDetails.monthRecords.isEmpty) {
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
                      onMonthListLeftArrowClick(context, storeDetails);
                    }),
                Text(monthSelected),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_right,
                    size: 35,
                  ),
                  onPressed: () {
                    onMonthListRightArrowClick(storeDetails, context);
                  },
                ),
              ],
            );
          }
        });
  }

  void onMonthListLeftArrowClick(
      BuildContext context, BudgetAppState storeDetails) {
    final String monthName = onMonthArrowPressed(true);
    if (null != monthName) {
      setState(() {
        final Store<BudgetAppState> _state =
            StoreProvider.of<BudgetAppState>(context);
        monthSelected = monthName;
        _state.dispatch(refreshMonthSpecificData(storeDetails.monthRecords[i]));
      });
    }
  }

  void onMonthListRightArrowClick(
      BudgetAppState storeDetails, BuildContext context) {
    final String monthName = onMonthArrowPressed(false);
    if (null != monthName) {
      setState(() {
        monthSelected = monthName;
        if (null != storeDetails.monthRecords &&
            storeDetails.monthRecords.isNotEmpty &&
            storeDetails.monthRecords.length > i) {
          final Store<BudgetAppState> _state =
              StoreProvider.of<BudgetAppState>(context);
          _state
              .dispatch(refreshMonthSpecificData(storeDetails.monthRecords[i]));
        }
      });
    }
  }

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

  int _findSelectedMonthIndex(BudgetAppState storeDetails) {
    if (null == storeDetails ||
        null == storeDetails.selectedMonthRecord ||
        storeDetails.monthRecords.isEmpty) {
      return 0;
    }
    return storeDetails.monthRecords.indexWhere((HomeBudgetOverview element) =>
        element.id == storeDetails.selectedMonthRecord.id);
  }
}
