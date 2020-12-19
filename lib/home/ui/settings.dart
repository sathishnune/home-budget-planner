import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/database/database_util.dart';
import 'package:home_budget_app/home/redux/budget_app_state.dart';
import 'package:home_budget_app/home/ui/utilities.dart';
import 'package:redux/redux.dart';
import 'package:package_info/package_info.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Color pickerColor = Colors.green;
  Color currentColor = Colors.green;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  bool darkTheme = false;

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  @override
  Widget build(BuildContext context) {
    currentColor = Theme.of(context).primaryColor;
    return Container(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Card(
              child: ListTile(
                  title: const Text('Dark Theme'),
                  leading: const Icon(Icons.dashboard_rounded),
                  trailing: Switch(
                    value: darkTheme,
                    onChanged: (bool value) {
                      setState(() {
                        darkTheme = value;
                        setToDarkTheme(value);
                      });
                    },
                  )),
            ),
            Card(
              child: ListTile(
                  title: const Text('Primary Color'),
                  leading: const Icon(Icons.color_lens_rounded),
                  trailing: IconButton(
                      icon: const Icon(Icons.colorize),
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
                      })),
            ),
            const Spacer(),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'App Version: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_packageInfo.version.toString())
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }

  void setToDarkTheme(bool darkTheme) {
    if (darkTheme) {
      DynamicTheme.of(context)
          .setThemeData(ThemeData(brightness: Brightness.dark));
    } else {
      DynamicTheme.of(context)
          .setThemeData(ThemeData(brightness: Brightness.light));
    }
  }

  void _updateApplicationTheme(BuildContext context) {
    super.didChangeDependencies();
    DynamicTheme.of(context).setThemeData(ThemeData(primaryColor: pickerColor));
    currentColor = pickerColor;
    final Store<BudgetAppState> _state =
        StoreProvider.of<BudgetAppState>(context);
    debugPrint('saving value' + currentColor.value.toString());
    DBUtils.updateColorCodeForAppTheme(currentColor.value)
        .then((value) => debugPrint("saving is done.."));
  }
}
