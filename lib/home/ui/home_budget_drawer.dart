import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/redux/budget_app_state.dart';
import 'package:home_budget_app/home/redux/thunk_actions.dart';
import 'package:home_budget_app/home/ui/backup_restore.dart';
import 'package:home_budget_app/home/ui/create_new_budget.dart';
import 'package:home_budget_app/home/ui/manage_budgets.dart';
import 'package:home_budget_app/home/ui/manage_recurrning_records.dart';
import 'package:home_budget_app/home/ui/settings.dart';
import 'package:redux/redux.dart';

class MyHomeBudgetDrawer extends StatefulWidget {
  @override
  _MyHomeBudgetDrawerState createState() => _MyHomeBudgetDrawerState();
}

class _MyHomeBudgetDrawerState extends State<MyHomeBudgetDrawer> {
  void _onSettingButtonPress(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(context,
        MaterialPageRoute<void>(builder: (BuildContext context) => Settings()));
  }

  void _manageMonthlyBudgets(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => ManageBudgetRecords()));
  }

  void _manageRecurringRecords(BuildContext context) {
    final Store<BudgetAppState> _state =
        StoreProvider.of<BudgetAppState>(context);
    _state.dispatch(fetchRecurringRecords());

    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => ManageRecurringRecords()));
  }

  void _backupRestore(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => BackupRestore()));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Center(
              child: Container(
                  child: const Text(
                'Home Budget Application',
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
              )),
            )),
        ListTile(
          leading: const Icon(Icons.add_rounded),
          title: const Text('Create new budget'),
          onTap: () {
            Navigator.pop(context);
            createNewBudget(context);
          },
        ),
        const Divider(thickness: 2),
        ListTile(
          leading: const Icon(Icons.list),
          title: const Text('Manage Budgets'),
          onTap: () => _manageMonthlyBudgets(context),
        ),
        const Divider(thickness: 2),
        ListTile(
          leading: const Icon(Icons.repeat),
          title: const Text('Recurring Budget'),
          onTap: () => _manageRecurringRecords(context),
        ),
        const Divider(thickness: 2),
        ListTile(
          leading: const Icon(Icons.backup),
          title: const Text('Backup & Restore'),
          onTap: () => _backupRestore(context),
        ),
        const Divider(thickness: 2),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {
            _onSettingButtonPress(context);
          },
        ),
        const Divider(thickness: 2),
      ],
    );
  }
}
