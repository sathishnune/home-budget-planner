import 'package:home_budget_app/home/ui/budget_details.dart';

class HomeBudgetOverview {
  HomeBudgetOverview(
      {this.id,
      this.month,
      this.year,
      this.displayName,
      this.listOfMonthRecords});

  String id;
  int month;
  int year;
  String displayName;
  bool markAsDelete = false;
  List<BudgetDetails> listOfMonthRecords;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'month': month,
      'year': year,
      'display_name': displayName,
    };
  }

  @override
  String toString() {
    return 'HomeBudgetOverview{id: $id, month: $month, year: $year, displayName: $displayName, markAsDelete: $markAsDelete, listOfMonthRecords: $listOfMonthRecords}';
  }
}
