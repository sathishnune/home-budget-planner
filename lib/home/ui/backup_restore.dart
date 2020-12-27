import 'package:flutter/material.dart';
import 'package:home_budget_app/home/database/database_util.dart';

class BackupRestore extends StatefulWidget {
  @override
  _BackupRestoreState createState() => _BackupRestoreState();
}

class _BackupRestoreState extends State<BackupRestore> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background/back_restore.png'),
              fit: BoxFit.scaleDown,
            ),
          ),
          child: ManageBackupRestore()),
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
    return Container(
      child: const Center(child: Text('Manage Backup & Restore here...')),
    );
  }
}
