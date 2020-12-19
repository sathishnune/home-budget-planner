import 'package:flutter/material.dart';
import 'package:home_budget_app/home/ui/create_new_budget.dart';
import 'package:home_budget_app/home/ui/manage_budgets.dart';
import 'package:home_budget_app/home/ui/settings.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              child: Text('SN'),
            ),
            accountName: Text('Sathish Nune'),
            accountEmail: Text('Sathish8103@gmail.com')),
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
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {
            _onSettingButtonPress(context);
          },
        ),
        const Divider(thickness: 2),
        ListTile(
          leading: const Icon(Icons.list),
          title: const Text('Manage Budgets'),
          onTap: () => _manageMonthlyBudgets(context),
        ),
        const Divider(thickness: 2),
      ],
    );
  }
}
