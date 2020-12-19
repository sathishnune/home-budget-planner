import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/redux/budget_app_state.dart';
import 'package:home_budget_app/home/redux/thunk_actions.dart';
import 'package:redux/redux.dart';

class ManageBudgetRecords extends StatefulWidget {
  @override
  _ManageBudgetRecordsState createState() => _ManageBudgetRecordsState();
}

class _ManageBudgetRecordsState extends State<ManageBudgetRecords> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Manage Budgets'),
            ),
            body: ManageBudgetList()));
  }
}

class ManageBudgetList extends StatefulWidget {
  @override
  _ManageBudgetListState createState() => _ManageBudgetListState();
}

class _ManageBudgetListState extends State<ManageBudgetList> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<BudgetAppState, BudgetAppState>(
        distinct: true,
        converter: (Store<BudgetAppState> storeDetails) => storeDetails.state,
        builder: (BuildContext context, BudgetAppState storeDetails) {
          if (storeDetails.monthRecords.isEmpty) {
            return Container(
              child: const Center(
                  child: Text(
                'No records available.',
                style: TextStyle(fontSize: 18),
              )),
            );
          } else {
            return ListView.builder(
              itemCount: null != storeDetails.monthRecords
                  ? storeDetails.monthRecords.length
                  : 0,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Card(
                    child: ListTile(
                        leading: const Icon(Icons.date_range),
                        title:
                            Text(storeDetails.monthRecords[index].displayName),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            final Widget _cancelButton = FlatButton(
                              child: const Text('Cancel'),
                              textColor: Theme.of(context).primaryColor,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            );

                            final Widget _continueButton = FlatButton(
                              child: const Text('Delete'),
                              textColor: Theme.of(context).primaryColor,
                              onPressed: () {
                                setState(() {
                                  final Store<BudgetAppState> _state =
                                      StoreProvider.of<BudgetAppState>(context);
                                  _state.dispatch(deleteMonthlyBudget(
                                      storeDetails.monthRecords[index]));
                                  Navigator.pop(context);
                                });
                              },
                            );

                            showDialog<AlertDialog>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirm Delete?'),
                                    content: Text(
                                        "You are deleting '${storeDetails.monthRecords[index].displayName}'. "
                                        'Please note: Deleting budget will delete all records under monthly budget.'),
                                    actions: <Widget>[
                                      _cancelButton,
                                      _continueButton
                                    ],
                                  );
                                });
                          },
                        )),
                  ),
                );
              },
            );
          }
        });
  }
}
