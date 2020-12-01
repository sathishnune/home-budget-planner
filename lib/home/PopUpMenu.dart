import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/redux/BudgetAppState.dart';
import 'package:home_budget_app/home/redux/actions.dart';

import 'CreateNewBudget.dart';
import 'PopUpMenuItems.dart';

class PopupMenuItems extends StatefulWidget {
  @override
  _PopupMenuItemsState createState() => _PopupMenuItemsState();
}

class _PopupMenuItemsState extends State<PopupMenuItems> {
  MyHomePopUpMenuItem selectedItem;

  @override
  Widget build(BuildContext context) {
    var state = StoreProvider.of<BudgetAppState>(context);
    return PopupMenuButton<MyHomePopUpMenuItem>(
      onSelected: (MyHomePopUpMenuItem result) {
        setState(() {
          selectedItem = result;
          state.dispatch(ValidCreateNewBudget(true));
          showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                    title: Text('Create New Month Budget Plan'),
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
