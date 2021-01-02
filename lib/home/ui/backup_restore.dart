import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/redux/budget_app_state.dart';
import 'package:home_budget_app/home/redux/thunk_actions.dart';
import 'package:redux/redux.dart';

class BackupRestore extends StatefulWidget {
  @override
  _BackupRestoreState createState() => _BackupRestoreState();
}

class _BackupRestoreState extends State<BackupRestore> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                'assets/restore_backup.jpg',
                fit: BoxFit.fill,
              ),
              title: const Text('Backup & Restore'),
            ),
          ),
          SliverFillRemaining(
            child: ManageBackupRestore(),
          )
        ],
      ),
    ));
  }
}

class ManageBackupRestore extends StatefulWidget {
  @override
  _ManageBackupRestoreState createState() => _ManageBackupRestoreState();
}

class _ManageBackupRestoreState extends State<ManageBackupRestore> {
  @override
  Widget build(BuildContext context) {
    final Store<BudgetAppState> _state =
        StoreProvider.of<BudgetAppState>(context);
    _state.dispatch(refreshLastBackupTime());
    return StoreConnector<BudgetAppState, BudgetAppState>(
        distinct: true,
        converter: (Store<BudgetAppState> storeDetails) => storeDetails.state,
        builder: (BuildContext context, BudgetAppState storeDetails) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: RaisedButton.icon(
                          color: Colors.lightGreen,
                          onPressed: () {
                            createBackUpRestorePopup(context, true);
                          },
                          icon: const Icon(Icons.backup),
                          label: const Text('Backup')),
                      width: MediaQuery.of(context).size.width / 2,
                      height: 50,
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: RaisedButton.icon(
                            color: Colors.lightBlueAccent,
                            onPressed: () {
                              createBackUpRestorePopup(context, false);
                            },
                            icon: const Icon(Icons.settings_backup_restore),
                            label: const Text('Restore recent backup')),
                        width: MediaQuery.of(context).size.width / 2,
                        height: 50,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: _progressInfo(storeDetails),
                ),
                _lastBackUpTime(storeDetails)
              ],
            ),
          );
        });
  }

  Widget _lastBackUpTime(BudgetAppState storeDetails) {
    if (null != storeDetails.lastBackUpTime) {
      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Text(
          'Last backup time: ' + storeDetails.lastBackUpTime,
          style: const TextStyle(color: Colors.blue),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _progressInfo(BudgetAppState storeDetails) {
    if (null != storeDetails.backupMessage &&
        'NV' != storeDetails.backupMessage) {
      if (true == storeDetails.isProgress) {
        return Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: CircularProgressIndicator(),
              ),
              Text(
                storeDetails.backupMessage,
                style: const TextStyle(
                    color: Colors.lightGreen,
                    fontWeight: FontWeight.w500,
                    fontSize: 20),
              ),
            ],
          ),
        );
      } else {
        return Container(
          child: Text(
            storeDetails.backupMessage,
            style: const TextStyle(
                color: Colors.lightGreen,
                fontWeight: FontWeight.w500,
                fontSize: 20),
          ),
        );
      }
    } else {
      return Container();
    }
  }

  void createBackUpRestorePopup(BuildContext context, bool isBackUp) {
    final Widget cancelButton = FlatButton(
      child: const Text('Cancel'),
      textColor: Theme.of(context).primaryColor,
      onPressed: () {
        Navigator.pop(context);
      },
    );
    final Widget continueButton = FlatButton(
      child: const Text('Continue'),
      textColor: Theme.of(context).primaryColor,
      onPressed: () {
        final Store<BudgetAppState> _state =
            StoreProvider.of<BudgetAppState>(context);
        if (true == isBackUp) {
          _state.dispatch(backupDB());
        } else {
          _state.dispatch(restoreDB());
        }

        Navigator.pop(context);
      },
    );

    showDialog<AlertDialog>(
        context: context,
        builder: (BuildContext context) {
          String modelTitle = 'Confirm Backup?';
          String modelContent =
              'System will backup existing data to Google Drive and replace existing backup. Would you like to continue?';
          if (true != isBackUp) {
            modelTitle = 'Confirm Restore?';
            modelContent =
                'System will restore back up from Google Drive (If available) and replace existing data. Would you like to continue?';
          }
          return AlertDialog(
            title: Text(modelTitle),
            content: Text(modelContent),
            actions: <Widget>[
              cancelButton,
              continueButton,
            ],
          );
        });
  }
}
