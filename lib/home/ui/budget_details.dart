class BudgetDetails {
  BudgetDetails({this.id, this.title, this.amount, this.status, this.type});

  String id;
  String title;
  int amount;
  String status;
  String type;

  @override
  String toString() {
    return 'BudgetDetails{title: $title, amount: $amount, status: $status, type: $type}';
  }
}
