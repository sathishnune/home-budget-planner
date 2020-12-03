import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/redux/budget_app_state.dart';
import 'package:home_budget_app/home/redux/thunk_actions.dart';
import 'package:home_budget_app/home/ui/add_new_item.dart';
import 'package:home_budget_app/home/ui/budget_details.dart';
import 'package:home_budget_app/home/ui/edit_modal.dart';
import 'package:home_budget_app/home/ui/home_budget_drawer.dart';
import 'package:home_budget_app/home/ui/popup_menu.dart';
import 'package:home_budget_app/home/ui/summary_cards.dart';
import 'package:home_budget_app/home/ui/utilities.dart';
import 'package:redux/redux.dart';

class MyHomeBudgetApp extends StatelessWidget {
  const MyHomeBudgetApp({this.store});

  final Store<BudgetAppState> store;

  @override
  Widget build(BuildContext context) {
    return StoreProvider<BudgetAppState>(
        store: store,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'My Home Budget Planner',
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
            const TabItem<Icon>(icon: Icon(Icons.history), title: 'History'),
            TabItem<dynamic>(icon: Icon(Icons.home), title: 'Home'),
            TabItem<dynamic>(icon: Icon(Icons.more_horiz), title: 'More')
          ],
          onTap: (int i) => {print("click index= $i")},
        ),
        appBar: AppBar(
          title: const Text('My Home Budget Planner'),
          actions: [PopupMenuItems()],
        ),
        body: MyHomeBudgetAppBody(),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              final Store<BudgetAppState> _state =
                  StoreProvider.of<BudgetAppState>(context);
              if (_state.state.selectedMonthRecord != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => AddRecord(),
                    fullscreenDialog: true,
                  ),
                );
              } else {
                final Widget _okButton = FlatButton(
                  child: const Text('Okay'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                );
                showDialog<AlertDialog>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('No month budget selected!!'),
                        content: const Text(
                            'Please choose the monthly budget to add the record'),
                        actions: [_okButton],
                      );
                    });
              }
            }),
        drawer: Drawer(
          child: Container(
            child: MyHomeBudgetDrawer(),
          ),
        ));
  }

  Widget _createFloatingAddButton(BuildContext context) {
    final Store<BudgetAppState> _state =
        StoreProvider.of<BudgetAppState>(context);
    if (_state.state.selectedMonthRecord != null) {
      return FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => AddRecord(),
                    fullscreenDialog: true,
                  ),
                ),
              });
    }
    return null;
  }
}

class MyHomeBudgetAppBody extends StatelessWidget {
  Widget _noDetailsMonthlyBudget() {
    return const Center(
        child: Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Details not available. Please create records.',
        style: TextStyle(fontSize: 18),
      ),
    ));
  }

  Widget _noBudgetSelected(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Oops. You didn't select the monthly record.",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<BudgetAppState, BudgetAppState>(
      distinct: true,
      converter: (Store<BudgetAppState> storeDetails) => storeDetails.state,
      builder: (BuildContext context, BudgetAppState storeDetails) {
        return Column(
          children: [
            if (storeDetails.selectedMonthRecord == null)
              _noBudgetSelected(context),
            if (storeDetails.selectedMonthRecord != null)
              SummaryCards(
                  budgetMetrics: storeDetails.budgetMetrics,
                  selectedMonthRecord: storeDetails.selectedMonthRecord),
            if (storeDetails.selectedMonthRecord != null) HorizontalLine(),
            if (storeDetails.isLoading)
              const LinearProgressIndicator()
            else
              Container(),
            if (storeDetails.selectedMonthRecord != null)
              Expanded(
                child: (null == storeDetails.listOfMonthRecords ||
                        storeDetails.listOfMonthRecords.isEmpty)
                    ? _noDetailsMonthlyBudget()
                    : ListView.builder(
                        itemCount: storeDetails.listOfMonthRecords.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: _budgetCardItemBuilder(
                                storeDetails.listOfMonthRecords[index],
                                context),
                          );
                        },
                      ),
              )
          ],
        );
      },
    );
  }

  static final String _rupeeSymbol =
      String.fromCharCodes(new Runes(' \u{20B9}'));

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
                    icon: const Icon(Icons.edit_sharp),
                    onPressed: () => {
                      if (budgetDetails != null)
                        {
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      EditFullScreenDialog(
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
                            'Amount: $_rupeeSymbol${budgetDetails.amount}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: IconButton(
                            icon: const Icon(
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
                        color: budgetDetails.type == 'Credit'
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
    final Widget cancelButton = FlatButton(
      child: const Text('Cancel'),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    final Widget continueButton = FlatButton(
      child: const Text('Delete'),
      onPressed: () {
        final Store<BudgetAppState> state =
            StoreProvider.of<BudgetAppState>(context);
        state.dispatch(deleteRecordWithThunk(details));
        Navigator.pop(context);
      },
    );

    showDialog<AlertDialog>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Delete?'),
            content:
                Text("Would you like to delete the '${details.title}' record?"),
            actions: [
              cancelButton,
              continueButton,
            ],
          );
        });
  }
}
