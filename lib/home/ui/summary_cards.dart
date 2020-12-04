import 'package:flutter/material.dart';
import 'package:home_budget_app/home/model/home_budget_overview.dart';
import 'package:home_budget_app/home/ui/home_budget_metrics.dart';

class SummaryCards extends StatefulWidget {
  const SummaryCards(
      {Key key, @required this.budgetMetrics, this.selectedMonthRecord})
      : super(key: key);

  final HomeBudgetMetrics budgetMetrics;
  final HomeBudgetOverview selectedMonthRecord;

  @override
  _SummaryCardsState createState() => _SummaryCardsState();
}

class _SummaryCardsState extends State<SummaryCards> {
  Widget _getTitleOfSummary() {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Home Budget Plan for Month of: ${null == widget.selectedMonthRecord ? 'N/A' : widget.selectedMonthRecord.displayName}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        children: <Widget>[
          _getTitleOfSummary(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _getSummaryCard(context, Icons.payments_outlined, Colors.green,
                  'Income', widget.budgetMetrics.totalIncome),
              _getSummaryCard(
                  context,
                  Icons.payments_outlined,
                  Colors.redAccent,
                  'Expend',
                  widget.budgetMetrics.totalSpentAmount),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _getSummaryCard(context, Icons.account_balance_wallet,
                  Colors.blue, 'Balance', widget.budgetMetrics.remainingAmount)
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
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blueGrey, Colors.white70])),
            width: (MediaQuery.of(context).size.width / 2) - 4,
            height: 50,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
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
                    child: RichText(
                      text: TextSpan(
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                          children: <TextSpan>[
                            TextSpan(
                                text: '$transType: ',
                                style: const TextStyle(color: Colors.black)),
                            TextSpan(
                                text: '$_rupeeSymbol $amount',
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

  static final String _rupeeSymbol = String.fromCharCodes(Runes(' \u{20B9}'));
}
