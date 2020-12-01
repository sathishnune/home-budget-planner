class HomeBudgetOverview {
  String id;
  int month;
  int year;
  String displayName;

  HomeBudgetOverview({this.id, this.month, this.year, this.displayName});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'month': month,
      'year': year,
      'display_name': displayName,
    };
  }

  @override
  String toString() {
    return 'HomeBudgetOverview{id: $id, month: $month, year: $year, displayName: $displayName}';
  }
}
