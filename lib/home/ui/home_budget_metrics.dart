class HomeBudgetMetrics {
  HomeBudgetMetrics(
      {this.totalPlannedAmount,
      this.totalSpentAmount,
      this.remainingAmount,
      this.totalIncome});

  int totalPlannedAmount = 0;
  int totalSpentAmount = 0;
  int remainingAmount = 0;
  int totalIncome = 0;

  HomeBudgetMetrics getDefaultValues() {
    return HomeBudgetMetrics(
        totalSpentAmount: 0,
        totalPlannedAmount: 0,
        remainingAmount: 0,
        totalIncome: 0);
  }
}
