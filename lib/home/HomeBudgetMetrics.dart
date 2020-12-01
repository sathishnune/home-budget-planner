class HomeBudgetMetrics {
  int totalPlannedAmount = 568458;
  int totalSpentAmount = 0;
  int remainingAmount = 0;
  int totalIncome = 0;

  HomeBudgetMetrics(
      [this.totalPlannedAmount,
      this.totalSpentAmount,
      this.remainingAmount,
      this.totalIncome]);

  int get getTotalPlannedAmount {
    return this.totalPlannedAmount;
  }
}
