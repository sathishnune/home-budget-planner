import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/redux/budget_app_state.dart';
import 'package:home_budget_app/home/ui/utilities.dart';
import 'package:redux/redux.dart';

class ManageRecurringRecords extends StatefulWidget {
  @override
  _ManageRecurringRecordsState createState() => _ManageRecurringRecordsState();
}

class _ManageRecurringRecordsState extends State<ManageRecurringRecords> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Manage Recurring Records'),
      ),
      body: ManageRecurringList(),
      floatingActionButton: floatingAddNewRecordToBudget(context, true),
    ));
  }
}

class ManageRecurringList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<BudgetAppState, BudgetAppState>(
        distinct: true,
        converter: (Store<BudgetAppState> storeDetails) => storeDetails.state,
        builder: (BuildContext context, BudgetAppState storeDetails) {
          if (null == storeDetails.recurringRecords ||
              storeDetails.recurringRecords.isEmpty) {
            return Center(
              child: Container(
                child: const Text('No records found'),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: storeDetails.recurringRecords.length,
              itemBuilder: (BuildContext context, int index) {
                return budgetCardItemBuilder(
                    storeDetails.recurringRecords[index], context, true);
              },
            );
          }
        });
  }
}
