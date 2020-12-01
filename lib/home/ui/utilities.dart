import 'package:flutter/material.dart';
import 'package:home_budget_app/home/ui/budget_details.dart';
import 'package:home_budget_app/home/ui/home_budget_metrics.dart';

class HorizontalLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(color: Colors.black);
  }
}

HomeBudgetMetrics updateTotalAmountsRef(List<BudgetDetails> list) {
  int totalIncome = 0;
  int totalSpent = 0;

  list.forEach((BudgetDetails element) {
    if (element.type == 'Credit') {
      totalIncome += element.amount;
    } else {
      totalSpent += element.amount;
    }
  });

  return HomeBudgetMetrics(
      totalPlannedAmount: 0,
      totalSpentAmount: totalSpent,
      remainingAmount: totalIncome - totalSpent,
      totalIncome: totalIncome);
}
