import 'package:uuid/uuid.dart';

class BudgetDetails {
  String id;
  String title;
  int amount;
  String status;
  String type;

  static Uuid uuid = new Uuid();

  BudgetDetails([this.id, this.title, this.amount, this.status, this.type]);

  static List<BudgetDetails> getBudgetItems() {
    return [
      BudgetDetails(uuid.v4(), 'Priya Salary', 50000, 'Open', 'Credit'),
      BudgetDetails(uuid.v4(), 'Sathish Salary', 25000, 'Open', 'Credit'),
      BudgetDetails(uuid.v4(), 'Room Rent', 10000, 'Closed'),
      BudgetDetails(uuid.v4(), 'House Loan EMI', 50000, 'Open'),
      BudgetDetails(uuid.v4(), 'Chit - Rajireddy', 10000, 'Open'),
      BudgetDetails(uuid.v4(), 'Other Expenses', 5000, 'Closed'),
      BudgetDetails(uuid.v4(), 'Extra Spent', 5000, 'Open'),
    ];
  }

  @override
  String toString() {
    return 'BudgetDetails{title: $title, amount: $amount, status: $status, type: $type}';
  }
}
