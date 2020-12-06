import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/database/database_util.dart';
import 'package:home_budget_app/home/redux/actions.dart';
import 'package:home_budget_app/home/redux/budget_app_state.dart';
import 'package:home_budget_app/home/ui/theme.dart';
import 'package:redux/redux.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  Color pickerColor = Colors.green;
  Color currentColor = Colors.green;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('Select Color:'),
                RaisedButton(
                  child: const Text('Pick Color'),
                  color: pickerColor,
                  onPressed: () {
                    showDialog<AlertDialog>(
                        context: context,
                        child: AlertDialog(
                          title: const Text('Pick a Primary Color!!'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: pickerColor,
                              onColorChanged: changeColor,
                              showLabel: true,
                              pickerAreaHeightPercent: 0.8,
                            ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: const Text('Pick it'),
                              onPressed: () {
                                setState(() {
                                  _updateApplicationTheme(context);
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ));
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: const Text(
                        'Selected button color applied to Button to check. '
                        'Same will be applied on next app start..'),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _updateApplicationTheme(BuildContext context) {
    currentColor = pickerColor;
    final ThemeData newThemeData = applicationTheme(currentColor);
    final Store<BudgetAppState> _state =
        StoreProvider.of<BudgetAppState>(context);

    _state.dispatch(ApplicationTheme(applicationTheme: newThemeData));
    _state.dispatch(DBUtils.updateColorCodeForAppTheme(currentColor.value));
  }
}
