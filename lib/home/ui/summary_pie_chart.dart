import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class BudgetData {
  const BudgetData(this.category, this.cost, this.color);

  final String category;
  final int cost;
  final charts.Color color;
}

class BudgetPieChart extends StatefulWidget {
  const BudgetPieChart({Key key, @required this.budgetDetails})
      : super(key: key);

  final List<BudgetData> budgetDetails;

  @override
  _BudgetPieChart createState() => _BudgetPieChart();
}

class _BudgetPieChart extends State<BudgetPieChart> {
  // Chart configs.
  final bool _animate = true;
  final double _arcRatio = 0.8;
  final charts.BehaviorPosition _legendPosition =
      charts.BehaviorPosition.bottom;

  @override
  Widget build(BuildContext context) {
    return charts.PieChart<dynamic>(
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
      animate: _animate,
      defaultRenderer: charts.ArcRendererConfig<dynamic>(
        arcRatio: _arcRatio,
        arcRendererDecorators: [
          charts.ArcLabelDecorator<dynamic>(
              labelPosition: charts.ArcLabelPosition.auto)
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
          position: _legendPosition,
          desiredMaxRows: 2,
        ),
      ],
    );
  }
}
