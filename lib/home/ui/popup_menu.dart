import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/redux/actions.dart';
import 'package:home_budget_app/home/redux/budget_app_state.dart';
import 'package:home_budget_app/home/redux/thunk_actions.dart';
import 'package:home_budget_app/home/ui/create_new_budget.dart';
import 'package:home_budget_app/home/ui/popup_menu_items.dart';
import 'package:redux/src/store.dart';

class PopupMenuItems extends StatefulWidget {
  @override
  _PopupMenuItemsState createState() => _PopupMenuItemsState();
}

class _PopupMenuItemsState extends State<PopupMenuItems> {
  @override
  Widget build(BuildContext context) {
    final Store<BudgetAppState> _state =
        StoreProvider.of<BudgetAppState>(context);
    return PopupMenuButton<MyHomePopUpMenuItem>(
      onSelected: (MyHomePopUpMenuItem result) {
        setState(() {
          final Widget _cancelButton = FlatButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          );

          final Widget _okButton = FlatButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.pop(context);
            },
          );

          final Widget _continueButton = FlatButton(
            child: const Text('Delete'),
            onPressed: () {
              _state.dispatch(
                  deleteMonthlyBudget(_state.state.selectedMonthRecord));
              Navigator.pop(context);
            },
          );

          if (MyHomePopUpMenuItem.CREATE == result) {
            _state.dispatch(ValidCreateNewBudget(true));
            showDialog<SimpleDialog>(
                context: context,
                builder: (BuildContext context) => SimpleDialog(
                      title: const Text('Create New Month Budget Plan'),
                      children: [CreateNewMonthlyBudget()],
                    ));
          } else if (MyHomePopUpMenuItem.DELETE == result) {
            if (_state.state.selectedMonthRecord == null) {
              showDialog<AlertDialog>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('No month budget selected!!'),
                      content: const Text(
                          'Please choose the monthly budget to delete the record'),
                      actions: [_okButton],
                    );
                  });
            } else {
              showDialog<AlertDialog>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Delete?'),
                      content: Text(
                          "You are deleting '${_state.state.selectedMonthRecord.displayName}'. "
                          'Please note: Deleting budget will delete all records under monthly budget.'),
                      actions: [_cancelButton, _continueButton],
                    );
                  });
            }
          }
        });
      },
      itemBuilder: (BuildContext context) =>
          <PopupMenuEntry<MyHomePopUpMenuItem>>[
        const PopupMenuItem<MyHomePopUpMenuItem>(
          value: MyHomePopUpMenuItem.CREATE,
          child: Text('Create New Budget'),
        ),
        const PopupMenuItem<MyHomePopUpMenuItem>(
          value: MyHomePopUpMenuItem.DELETE,
          child: Text('Delete Current Budget'),
        )
      ],
    );
  }
}
