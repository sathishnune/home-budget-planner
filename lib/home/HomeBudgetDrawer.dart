import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/Utilities.dart';
import 'package:home_budget_app/home/redux/BudgetAppState.dart';
import 'package:home_budget_app/home/redux/ThunkActions.dart';
import 'package:home_budget_app/home/redux/actions.dart';

class MyHomeBudgetDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var state = StoreProvider.of<BudgetAppState>(context);
    return StoreConnector<BudgetAppState, BudgetAppState>(
        distinct: true,
        converter: (storeDetails) => storeDetails.state,
        builder: (context, storeDetails) {
          return Column(
            children: [
              UserAccountsDrawerHeader(
                  accountName: Text("Sathish Nune"),
                  accountEmail: Text("Sathish8103@gmail.com")),
              Expanded(
                  child:
                      ExpansionTile(title: Text('Months - Budgets'), children: [
                new ListView.separated(
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  shrinkWrap: true,
                  itemCount: null != storeDetails.monthRecords
                      ? storeDetails.monthRecords.length
                      : 0,
                  itemBuilder: (context, index) {
                    return ListTile(
                      tileColor: Colors.lightBlueAccent,
                      title: Text(storeDetails.monthRecords[index].displayName),
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
          return new ListView.builder(
            shrinkWrap: true,
            itemCount: 18,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Item 1'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              );
            },
          );
        });
  }
}
