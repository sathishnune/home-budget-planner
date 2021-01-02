import 'dart:async';

import 'package:home_budget_app/home/model/home_budget_monthly_details.dart';
import 'package:home_budget_app/home/model/home_budget_overview.dart';
import 'package:home_budget_app/home/ui/budget_details.dart';
import 'package:home_budget_app/home/ui/utilities.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBUtils {
  static const String DB_NAME = 'home_budget_database.db';

  static const String TABLE_HOME_BUDGET_THEME = 'HOME_BUDGET_THEME';
  static const String TABLE_HOME_BUDGET_OVERVIEW = 'HOME_BUDGET_OVERVIEW';
  static const String TABLE_HOME_RECURRING_BUDGET = 'HOME_BUDGET_RECURRING';
  static const String TABLE_HOME_BUDGET_MONTHLY_DETAILS =
      'HOME_BUDGET_MONTHLY_DETAILS';
  static const String TABLE_HOME_BUDGET_BACK_UP = 'HOME_BUDGET_BACK_UP';

  static const String SQL_CREATE_HOME_DETAILS_OVERVIEW =
      'CREATE TABLE HOME_BUDGET_OVERVIEW(id TEXT PRIMARY KEY, month INTEGER, '
      'year INTEGER, display_name TEXT)';

  static const String SQL_CREATE_HOME_DETAILS_THEME =
      'CREATE TABLE HOME_BUDGET_THEME(colorCode INTEGER)';

  static const String SQL_CREATE_HOME_BUDGET_BACK_UP =
      'CREATE TABLE HOME_BUDGET_BACK_UP(last_back_up TEXT)';

  static const String SQL_CREATE_HOME_BUDGET_MONTHLY_DETAILS =
      'CREATE TABLE HOME_BUDGET_MONTHLY_DETAILS(id TEXT PRIMARY KEY, '
      'title TEXT, amount INTEGER, trans_type TEXT,status integer, '
      'record_order integer, month_ref TEXT, FOREIGN KEY (month_ref) REFERENCES '
      'HOME_BUDGET_OVERVIEW (id))';

  static const String SQL_CREATE_HOME_BUDGET_RECURRING_DETAILS =
      'CREATE TABLE HOME_BUDGET_RECURRING(id TEXT PRIMARY KEY, '
      'title TEXT, amount INTEGER, trans_type TEXT)';

  static Future<Database> database() async {
    return openDatabase(join(await getDatabasesPath(), DB_NAME),
        onCreate: (Database db, int version) => _createTables(db), version: 1);
  }

  static void _createTables(Database db) {
    db.execute(SQL_CREATE_HOME_DETAILS_OVERVIEW);
    db.execute(SQL_CREATE_HOME_BUDGET_MONTHLY_DETAILS);
    db.execute(SQL_CREATE_HOME_DETAILS_THEME);
    db.execute(SQL_CREATE_HOME_BUDGET_RECURRING_DETAILS);
    db.execute(SQL_CREATE_HOME_BUDGET_BACK_UP);
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
      HomeBudgetMonthlyDetails monthlyDetails, int currentLength) async {
    final Database db = await database();
    await db.insert(
      TABLE_HOME_BUDGET_MONTHLY_DETAILS,
      monthlyDetails.toMap(currentLength),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  static Future<void> insertHomeBudgetRecurringDetails(
      HomeBudgetMonthlyDetails monthlyDetails) async {
    final Database db = await database();
    await db.insert(
      TABLE_HOME_RECURRING_BUDGET,
      monthlyDetails.toMapWithOutOrder(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  static Future<void> updateHomeBudgetRecurringDetails(
      HomeBudgetMonthlyDetails monthlyDetails) async {
    final Database db = await database();
    await db.update(
        TABLE_HOME_RECURRING_BUDGET, monthlyDetails.toMapWithOutOrder(),
        where: 'id = ?', whereArgs: <String>[monthlyDetails.id]);
  }

  static Future<void> updateHomeBudgetMonthlyDetails(
      HomeBudgetMonthlyDetails monthlyDetails) async {
    final Database db = await database();
    await db.update(TABLE_HOME_BUDGET_MONTHLY_DETAILS,
        monthlyDetails.toMap(monthlyDetails.recordOrder),
        where: 'id = ?', whereArgs: <String>[monthlyDetails.id]);
  }

  static Future<List<BudgetDetails>> recurringRecords() async {
    final Database db = await database();
    final List<Map<String, dynamic>> maps =
        await db.query(TABLE_HOME_RECURRING_BUDGET);
    return List.generate(maps.length, (int i) {
      return BudgetDetails(
          id: Utils.cast<String>(maps[i]['id']),
          title: Utils.cast<String>(maps[i]['title']),
          amount: Utils.cast<int>(maps[i]['amount']),
          type: Utils.cast<String>(maps[i]['trans_type']));
    });
  }

  static Future<List<HomeBudgetMonthlyDetails>> monthlyDetails(
      String monthRefId) async {
    final Database db = await database();
    final List<Map<String, dynamic>> maps = await db.query(
        TABLE_HOME_BUDGET_MONTHLY_DETAILS,
        where: 'month_ref = ?',
        whereArgs: <String>[monthRefId],
        orderBy: 'record_order ASC');
    return List.generate(maps.length, (int i) {
      return HomeBudgetMonthlyDetails(
        id: Utils.cast<String>(maps[i]['id']),
        title: Utils.cast<String>(maps[i]['title']),
        amount: Utils.cast<int>(maps[i]['amount']),
        transType: Utils.cast<String>(maps[i]['trans_type']),
        monthRef: Utils.cast<String>(maps[i]['month_ref']),
        status: Utils.cast<int>(maps[i]['status']),
      );
    });
  }

  static Future<List<HomeBudgetOverview>> budgetOverviews() async {
    final Database db = await database();
    final List<Map<String, dynamic>> maps = await db
        .query(TABLE_HOME_BUDGET_OVERVIEW, orderBy: 'year desc, month desc');
    return List.generate(maps.length, (int i) {
      return mapModelToPOJO(maps[i]);
    });
  }

  static HomeBudgetOverview mapModelToPOJO(Map<String, dynamic> maps) {
    return HomeBudgetOverview(
      id: Utils.cast<String>(maps['id']),
      displayName: Utils.cast<String>(maps['display_name']),
      month: Utils.cast<int>(maps['month']),
      year: Utils.cast<int>(maps['year']),
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
    await deleteHomeBudgetMonthlyDetailsByRef(id);
  }

  static Future<void> deleteHomeBudgetMonthlyDetails(String id) async {
    final Database db = await database();
    await db.delete(
      TABLE_HOME_BUDGET_MONTHLY_DETAILS,
      where: 'id = ?',
      whereArgs: <String>[id],
    );
  }

  static Future<void> deleteRecurringRecord(String id) async {
    final Database db = await database();
    await db.delete(
      TABLE_HOME_RECURRING_BUDGET,
      where: 'id = ?',
      whereArgs: <String>[id],
    );
  }

  static Future<void> deleteHomeBudgetMonthlyDetailsByRef(String id) async {
    final Database db = await database();
    await db.delete(
      TABLE_HOME_BUDGET_MONTHLY_DETAILS,
      where: 'month_ref = ?',
      whereArgs: <String>[id],
    );
  }

  static Future<void> updateRecordStatus(String id, bool status) async {
    final Database db = await database();
    final Map<String, dynamic> row = <String, dynamic>{
      'status': status ? 1 : 0
    };

    await db.update(TABLE_HOME_BUDGET_MONTHLY_DETAILS, row,
        whereArgs: <String>[id], where: 'id = ?');
  }

  static Future<void> updateRecordOrder(String id, int recordOrder) async {
    final Database db = await database();
    final Map<String, dynamic> row = <String, dynamic>{
      'record_order': recordOrder
    };

    await db.update(TABLE_HOME_BUDGET_MONTHLY_DETAILS, row,
        whereArgs: <String>[id], where: 'id = ?');
  }

  static Future<void> updateColorCodeForAppTheme(int colorCode) async {
    final Database db = await database();
    await db
        .query(TABLE_HOME_BUDGET_THEME)
        .then((List<Map<String, dynamic>> value) async {
      final Map<String, dynamic> row = <String, dynamic>{
        'colorCode': colorCode
      };
      if (value.isEmpty) {
        await db.insert(TABLE_HOME_BUDGET_THEME, row);
      } else {
        await db.update(TABLE_HOME_BUDGET_THEME, row);
      }
    });
  }

  static Future<List<Map<String, dynamic>>> getColorCode() async {
    final Database db = await database();
    return await db.query(TABLE_HOME_BUDGET_THEME,
        columns: ['colorCode'], limit: 1);
  }

  static Future<void> insertOrUpdateBackupTimeStamp() async {
    final Database db = await database();
    final List<Map<String, dynamic>> data =
        await db.query(TABLE_HOME_BUDGET_BACK_UP);
    final Map<String, dynamic> row = <String, dynamic>{
      'last_back_up': currentTimeStamp()
    };
    if (data.isNotEmpty) {
      await db.update(TABLE_HOME_BUDGET_BACK_UP, row);
    } else {
      await db.insert(TABLE_HOME_BUDGET_BACK_UP, row);
    }
  }

  static Future<String> lastBackUpTimeStamp() async {
    final Database db = await database();
    final List<Map<String, dynamic>> data =
        await db.query(TABLE_HOME_BUDGET_BACK_UP);
    if (data.isNotEmpty) {
      return Utils.cast<String>(data.first['last_back_up']);
    }
    return null;
  }

  static String currentTimeStamp() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat.yMd().add_jm();
    return formatter.format(now);
  }
}
