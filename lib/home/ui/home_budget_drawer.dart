import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/redux/budget_app_state.dart';
import 'package:home_budget_app/home/redux/thunk_actions.dart';
import 'package:redux/src/store.dart';

class MyHomeBudgetDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Store<BudgetAppState> state =
        StoreProvider.of<BudgetAppState>(context);
    return StoreConnector<BudgetAppState, BudgetAppState>(
        distinct: true,
        converter: (Store<BudgetAppState> storeDetails) => storeDetails.state,
        builder: (BuildContext context, BudgetAppState storeDetails) {
          return Column(
            children: [
              const UserAccountsDrawerHeader(
                  accountName: Text('Sathish Nune'),
                  accountEmail: Text('Sathish8103@gmail.com')),
              Expanded(
                  child: ExpansionTile(
                      title: const Text('Months - Budgets'),
                      children: [
                    ListView.separated(
                      separatorBuilder: (BuildContext context, int index) {
                        return const Divider();
                      },
                      shrinkWrap: true,
                      itemCount: null != storeDetails.monthRecords
                          ? storeDetails.monthRecords.length
                          : 0,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          tileColor: Colors.lightBlueAccent,
                          title: Text(
                              storeDetails.monthRecords[index].displayName),
                          onTap: () {
                            state.dispatch(refreshMonthSpecificData(
                                storeDetails.monthRecords[index]));
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ])),
            ],
          );
        });
  }
}
