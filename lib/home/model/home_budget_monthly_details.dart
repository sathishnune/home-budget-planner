class HomeBudgetMonthlyDetails {
  HomeBudgetMonthlyDetails(
      {this.id,
      this.title,
      this.amount,
      this.transType,
      this.monthRef,
      this.status,
      this.recordOrder});

  String id;
  String title;
  int amount;
  String transType;
  String monthRef;
  int status;
  int recordOrder;

  Map<String, dynamic> toMap(int currentLength) {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'amount': amount,
      'trans_type': transType,
      'month_ref': monthRef,
      'status': status,
      'record_order': currentLength
    };
  }

  @override
  String toString() {
    return 'HomeBudgetMonthlyDetails{id: $id, title: $title, amount: $amount, '
        'transType: $transType, monthRef: $monthRef, status: $status, '
        'recordOrder: $recordOrder}';
  }
}
