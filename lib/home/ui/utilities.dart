import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/redux/actions.dart';
import 'package:home_budget_app/home/redux/budget_app_state.dart';
import 'package:home_budget_app/home/ui/budget_details.dart';
import 'package:home_budget_app/home/ui/create_new_budget.dart';
import 'package:home_budget_app/home/ui/home_budget_metrics.dart';
import 'package:redux/redux.dart';

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
