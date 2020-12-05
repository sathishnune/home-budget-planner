import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/redux/actions.dart';
import 'package:home_budget_app/home/redux/budget_app_state.dart';
import 'package:home_budget_app/home/redux/thunk_actions.dart';
import 'package:home_budget_app/home/ui/budget_details.dart';
import 'package:redux/redux.dart';

class StatusSwitch extends StatefulWidget {
  const StatusSwitch({this.budgetDetails});

  final BudgetDetails budgetDetails;

  @override
  _StatusSwitchState createState() => _StatusSwitchState();
}

class _StatusSwitchState extends State<StatusSwitch> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: [
        const Text('Completed: '),
        Switch(
          activeColor: Theme.of(context).primaryColor,
          value: widget.budgetDetails.isCompleted,
          onChanged: (bool value) {
            setState(() {
              final Store<BudgetAppState> _state =
                  StoreProvider.of<BudgetAppState>(context);
              _state
                  .dispatch(updateRecordStatus(widget.budgetDetails.id, value));
              widget.budgetDetails.isCompleted = value;
            });
          },
        )
      ]),
    );
  }
}
