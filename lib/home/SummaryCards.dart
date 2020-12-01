import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/HomeBudgetMetrics.dart';
import 'package:home_budget_app/home/model/HomeBudgetOverview.dart';
import 'package:home_budget_app/home/redux/BudgetAppState.dart';

class SummaryCards extends StatefulWidget {
  final HomeBudgetMetrics budgetMetrics;
  final HomeBudgetOverview selectedMonthRecord;

  SummaryCards(
      {Key key, @required this.budgetMetrics, this.selectedMonthRecord})
      : super(key: key);

  @override
  _SummaryCardsState createState() => _SummaryCardsState();
}

class _SummaryCardsState extends State<SummaryCards> {
  Widget _getTitleOfSummary() {
    return Row(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Home Budget Plan for Month of: ${null == widget.selectedMonthRecord ? 'N/A' : widget.selectedMonthRecord.displayName}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: Column(
        children: [
          _getTitleOfSummary(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _getSummaryCard(context, Icons.payments_outlined, Colors.green,
                  "Income", widget.budgetMetrics.totalIncome),
              _getSummaryCard(
                  context,
                  Icons.payments_outlined,
                  Colors.redAccent,
                  "Expend",
                  widget.budgetMetrics.totalSpentAmount),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _getSummaryCard(context, Icons.account_balance_wallet,
                  Colors.blue, "Balance", widget.budgetMetrics.remainingAmount)
            ],
          ),
        ],
      ),
    );
  }

  Widget _getSummaryCard(BuildContext context, IconData iconData, Color color,
      String transType, int amount) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        constraints: BoxConstraints(
            maxWidth: (MediaQuery.of(context).size.width / 2) - 16),
        child: Card(
          elevation: 5,
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blueGrey, Colors.white70])),
            width: (MediaQuery.of(context).size.width / 2) - 4,
            height: 50,
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  iconData,
                  size: 40,
                  color: color,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: new RichText(
                  text: new TextSpan(
                      style: new TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                      children: [
                        new TextSpan(
                            text: "$transType: ",
                            style: TextStyle(color: Colors.black)),
                        new TextSpan(
                            text: "$_rupeeSymbol $amount",
                            style: TextStyle(color: color))
                      ]),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }

  static String _rupeeSymbol = new String.fromCharCodes(new Runes(' \u{20B9}'));
}
