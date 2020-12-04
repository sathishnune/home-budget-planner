class HomeBudgetMonthlyDetails {
  HomeBudgetMonthlyDetails(
      {this.id,
      this.title,
      this.amount,
      this.transType,
      this.monthRef,
      this.status});

  String id;
  String title;
  int amount;
  String transType;
  String monthRef;
  int status;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'amount': amount,
      'trans_type': transType,
      'month_ref': monthRef,
      'status': status
    };
  }

  @override
  String toString() {
    return 'HomeBudgetMonthlyDetails{id: $id, title: $title, amount: $amount, transType: $transType, monthRef: $monthRef, status: $status}';
  }
}
