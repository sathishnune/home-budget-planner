class BudgetDetails {
  BudgetDetails(
      {this.id,
      this.title,
      this.amount,
      this.status,
      this.type,
      this.isCompleted});

  String id;
  String title;
  int amount;
  String status;
  String type;
  bool isCompleted = false;

  @override
  String toString() {
    return 'BudgetDetails{id: $id, title: $title, amount: $amount, status: $status, type: $type, isCompleted: $isCompleted}';
  }
}
