class HomeBudgetMonthlyDetails {
  String id;
  String title;
  int amount;
  String transType;
  String monthRef;

  HomeBudgetMonthlyDetails(
      {this.id, this.title, this.amount, this.transType, this.monthRef});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'trans_type': transType,
      'month_ref': monthRef
    };
  }

  @override
  String toString() {
    return 'HomeBudgetMonthlyDetails{id: $id, title: $title, amount: $amount, transType: $transType, monthRef: $monthRef}';
  }

}
