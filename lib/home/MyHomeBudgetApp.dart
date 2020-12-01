import 'package:charts_flutter/flutter.dart' as charts;
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/AddNewItem.dart';
import 'package:home_budget_app/home/BudgetDetails.dart';
import 'package:home_budget_app/home/EditModal.dart';
import 'package:home_budget_app/home/HomeBudgetDrawer.dart';
import 'package:home_budget_app/home/PopUpMenu.dart';
import 'package:home_budget_app/home/SummaryCards.dart';
import 'package:home_budget_app/home/SummaryPieChart.dart';
import 'package:home_budget_app/home/Utilities.dart';
import 'package:home_budget_app/home/redux/BudgetAppState.dart';
import 'package:home_budget_app/home/redux/ThunkActions.dart';
import 'package:redux/redux.dart';

class MyHomeBudgetApp extends StatelessWidget {
  final Store<BudgetAppState> store;

  MyHomeBudgetApp({this.store});

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
        store: store,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "My Home Budget Planner",
          home: HomeWidget(),
        ));
  }
}

class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        bottomNavigationBar: ConvexAppBar(
          style: TabStyle.reactCircle,
          initialActiveIndex: 1,
          height: 60,
          items: [
            TabItem(icon: Icon(Icons.history), title: 'History'),
            TabItem(icon: Icon(Icons.home), title: 'Home'),
            TabItem(icon: Icon(Icons.more_horiz), title: 'More')
          ],
          onTap: (int i) => {print("click index= $i")},
        ),
        appBar: AppBar(
          title: Text('My Home Budget Planner'),
          actions: [PopupMenuItems()],
        ),
        body: MyHomeBudgetAppBody(),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => AddRecord(),
                      fullscreenDialog: true,
                    ),
                  ),
                }),
        drawer: Drawer(
          child: Container(
            child: MyHomeBudgetDrawer(),
          ),
        ));
  }
}

class MyHomeBudgetAppBody extends StatelessWidget {
  Widget _noDetailsMonthlyBudget() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        "Details not available. Please create records.",
        style: TextStyle(fontSize: 18),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<BudgetAppState, BudgetAppState>(
      distinct: true,
      converter: (storeDetails) => storeDetails.state,
      builder: (context, storeDetails) {
        return Column(
          children: [
            SummaryCards(
                budgetMetrics: storeDetails.budgetMetrics,
                selectedMonthRecord: storeDetails.selectedMonthRecord),
            HorizontalLine(),
            storeDetails.isLoading
                ? new LinearProgressIndicator()
                : new Container(),
            Expanded(
              child: (null == storeDetails.listOfMonthRecords ||
                      storeDetails.listOfMonthRecords.isEmpty)
                  ? _noDetailsMonthlyBudget()
                  : ListView.builder(
                      itemCount: storeDetails.listOfMonthRecords.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: _budgetCardItemBuilder(
                              storeDetails.listOfMonthRecords[index], context),
                        );
                      },
                    ),
            )
          ],
        );
      },
    );
  }

  static String _rupeeSymbol = new String.fromCharCodes(new Runes(' \u{20B9}'));

  Widget _budgetCardItemBuilder(
      BudgetDetails budgetDetails, BuildContext context) {
    return Card(
        //clipBehavior: Clip.antiAlias,
        elevation: 2,
        //color: Colors.white70,
        child: ClipPath(
          child: Container(
            child: Column(
              children: [
                ListTile(
                  isThreeLine: false,
                  title: Text(budgetDetails.title),
                  trailing: IconButton(
                    icon: Icon(Icons.edit_sharp),
                    onPressed: () => {
                      if (budgetDetails != null)
                        {
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (context) => EditFullScreenDialog(
                                      budgetDetails: budgetDetails),
                                  fullscreenDialog: true))
                        }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15, bottom: 5),
                        child: Text(
                            "Amount: $_rupeeSymbol${budgetDetails.amount}"),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.black45,
                            ),
                            onPressed: () => {
                                  _deleteBudgetListItem(context, budgetDetails)
                                }),
                      ),
                    ],
                  ),
                )
              ],
            ),
            decoration: BoxDecoration(
                border: Border(
                    left: BorderSide(
                        color: budgetDetails.type == "Credit"
                            ? Colors.green
                            : Colors.redAccent,
                        width: 10))),
          ),
          clipper: ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
        ));
  }

  void _deleteBudgetListItem(BuildContext context, BudgetDetails details) {
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Delete"),
      onPressed: () {
        var state = StoreProvider.of<BudgetAppState>(context);
        state.dispatch(deleteRecordWithThunk(details));
        Navigator.pop(context);
      },
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirm Delete?"),
            content:
                Text("Would you like to delete the '${details.title}' record?"),
            actions: [
              cancelButton,
              continueButton,
            ],
          );
        });
  }

  List<BudgetData> updateTotalAmounts(List<BudgetDetails> list) {
    int totalIncome = 0;
    int totalSpent = 0;

    list.forEach((element) {
      if (element.type == "Credit") {
        totalIncome += element.amount;
      } else {
        totalSpent += element.amount;
      }
    });

    return [
      BudgetData(
          "Income", totalIncome, charts.MaterialPalette.green.shadeDefault),
      BudgetData(
          "Remaining",
          (totalIncome - totalSpent) < 0 ? 0 : (totalIncome - totalSpent),
          charts.MaterialPalette.red.shadeDefault),
      BudgetData("Expend", totalSpent, charts.MaterialPalette.blue.shadeDefault)
    ];
  }

  Widget _loadingIndicator() {
    return Container(
      color: Colors.white.withOpacity(0.5),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
