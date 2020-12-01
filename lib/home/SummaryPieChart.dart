import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class BudgetData {
  final String category;
  final int cost;
  final charts.Color color;

  const BudgetData(this.category, this.cost, this.color);
}

class BudgetPieChart extends StatefulWidget {
  final List<BudgetData> budgetDetails;

  BudgetPieChart({Key key, @required this.budgetDetails}) : super(key: key);

  @override
  _BudgetPieChart createState() => _BudgetPieChart();
}

class _BudgetPieChart extends State<BudgetPieChart> {
  // Chart configs.
  bool _animate = true;
  double _arcRatio = 0.8;
  charts.BehaviorPosition _legendPosition = charts.BehaviorPosition.bottom;

  @override
  Widget build(BuildContext context) {
    return charts.PieChart(
      [
        charts.Series<BudgetData, String>(
          id: 'budgetAppChart',
          domainFn: (BudgetData data, _) => data.category,
          measureFn: (BudgetData data, _) => data.cost,
          colorFn: (BudgetData data, _) => data.color,
          data: widget.budgetDetails,
          // Set a label accessor to control the text of the arc label.
          labelAccessorFn: (BudgetData row, _) =>
              '${row.category}: ${row.cost}',
        ),
      ],
      animate: this._animate,
      defaultRenderer: charts.ArcRendererConfig(
        arcRatio: this._arcRatio,
        arcRendererDecorators: [
          charts.ArcLabelDecorator(labelPosition: charts.ArcLabelPosition.auto)
        ],
      ),
      behaviors: [
        // Add title.
        charts.ChartTitle(
          'Monthly Home Budget',
          behaviorPosition: charts.BehaviorPosition.bottom,
        ),
        // Add legend. ("Datum" means the "X-axis" of each data point.)
        charts.DatumLegend(
          position: this._legendPosition,
          desiredMaxRows: 2,
        ),
      ],
    );
  }
}
