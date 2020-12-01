import 'dart:async';

import 'package:home_budget_app/home/model/home_budget_monthly_details.dart';
import 'package:home_budget_app/home/model/home_budget_overview.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBUtils {
  static const String DB_NAME = 'home_budget_database.db';

  static const String TABLE_HOME_BUDGET_OVERVIEW = 'HOME_BUDGET_OVERVIEW';
  static const String TABLE_HOME_BUDGET_MONTHLY_DETAILS =
      'HOME_BUDGET_MONTHLY_DETAILS';

  static const String SQL_CREATE_HOME_DETAILS_OVERVIEW =
      'CREATE TABLE HOME_BUDGET_OVERVIEW(id TEXT PRIMARY KEY, month INTEGER, '
      'year INTEGER, display_name TEXT)';

  static const String SQL_CREATE_HOME_BUDGET_MONTHLY_DETAILS =
      'CREATE TABLE HOME_BUDGET_MONTHLY_DETAILS(id TEXT PRIMARY KEY, '
      'title TEXT, amount INTEGER, trans_type TEXT, '
      'month_ref TEXT, FOREIGN KEY (month_ref) REFERENCES '
      'HOME_BUDGET_OVERVIEW (id))';

  static Future<Database> database() async {
    return openDatabase(
        join(await getDatabasesPath(), 'home_budget_database.db'),
        onCreate: (Database db, int version) => _createTables(db),
        version: 1);
  }

  static void _createTables(Database db) {
    db.execute(SQL_CREATE_HOME_DETAILS_OVERVIEW);
    db.execute(SQL_CREATE_HOME_BUDGET_MONTHLY_DETAILS);
  }

  static Future<void> insertHomeBudgetOverview(
      HomeBudgetOverview homeBudgetOverview) async {
    final Database db = await database();
    await db.insert(
      TABLE_HOME_BUDGET_OVERVIEW,
      homeBudgetOverview.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  static Future<void> insertHomeBudgetMonthlyDetails(
      HomeBudgetMonthlyDetails monthlyDetails) async {
    final Database db = await database();
    await db.insert(
      TABLE_HOME_BUDGET_MONTHLY_DETAILS,
      monthlyDetails.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  static Future<void> updateHomeBudgetMonthlyDetails(
      HomeBudgetMonthlyDetails monthlyDetails) async {
    final Database db = await database();
    await db.update(TABLE_HOME_BUDGET_MONTHLY_DETAILS, monthlyDetails.toMap(),
        where: 'id = ?', whereArgs: <String>[monthlyDetails.id]);
  }

  static Future<List<HomeBudgetMonthlyDetails>> monthlyDetails(
      String monthRefId) async {
    final Database db = await database();
    final List<Map<String, dynamic>> maps = await db.query(
        TABLE_HOME_BUDGET_MONTHLY_DETAILS,
        where: 'month_ref = ?',
        whereArgs: <String>[monthRefId]);
    return List.generate(maps.length, (int i) {
      return HomeBudgetMonthlyDetails(
        id: maps[i]['id'],
        title: maps[i]['title'],
        amount: maps[i]['amount'],
        transType: maps[i]['trans_type'],
        monthRef: maps[i]['month_ref'],
      );
    });
  }

  static Future<List<HomeBudgetOverview>> budgetOverviews() async {
    final Database db = await database();
    final List<Map<String, dynamic>> maps = await db
        .query(TABLE_HOME_BUDGET_OVERVIEW, orderBy: 'year desc, month desc');
    return List.generate(maps.length, (i) {
      return mapModelToPOJO(maps[i]);
    });
  }

  static HomeBudgetOverview mapModelToPOJO(Map<String, dynamic> maps) {
    return HomeBudgetOverview(
      id: maps['id'],
      displayName: maps['display_name'],
      month: maps['month'],
      year: maps['year'],
    );
  }

  static Future<List<HomeBudgetOverview>> checkIfWeHaveMonthExists(
      int month, int year) async {
    final Database db = await database();
    final List<Map<String, dynamic>> maps = await db.query(
        TABLE_HOME_BUDGET_OVERVIEW,
        where: 'month = ? and year = ?',
        whereArgs: <int>[month, year]);
    return List.generate(maps.length, (i) {
      return mapModelToPOJO(maps[i]);
    });
  }

  static Future<void> deleteHomeBudgetOverview(String id) async {
    final Database db = await database();
    await db.delete(
      TABLE_HOME_BUDGET_OVERVIEW,
      where: 'id = ?',
      whereArgs: <String>[id],
    );
  }

  static Future<void> deleteHomeBudgetMonthlyDetails(String id) async {
    final Database db = await database();
    await db.delete(
      TABLE_HOME_BUDGET_MONTHLY_DETAILS,
      where: 'id = ?',
      whereArgs: <String>[id],
    );
  }
}
