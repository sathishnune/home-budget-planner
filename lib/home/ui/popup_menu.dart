import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/redux/budget_app_state.dart';
import 'package:home_budget_app/home/redux/actions.dart';
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
          _state.dispatch(ValidCreateNewBudget(true));
          showDialog<SimpleDialog>(
              context: context,
              builder: (BuildContext context) => SimpleDialog(
                    title: const Text('Create New Month Budget Plan'),
                    children: [CreateNewMonthlyBudget()],
                  ));
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
          child: Text('Extra Details'),
        )
      ],
    );
  }
}
