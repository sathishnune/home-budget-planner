import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/redux/budget_app_state.dart';
import 'package:home_budget_app/home/redux/thunk_actions.dart';
import 'package:home_budget_app/home/ui/add_new_item.dart';
import 'package:home_budget_app/home/ui/budget_details.dart';
import 'package:home_budget_app/home/ui/edit_modal.dart';
import 'package:home_budget_app/home/ui/home_budget_metrics.dart';
import 'package:home_budget_app/home/ui/status_switch.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';

class HorizontalLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(color: Colors.black);
  }
}

class Utils {
  static T cast<T>(dynamic x) => x is T ? x : null;
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

String formatNumber(int number) {
  final NumberFormat numberFormat =
      NumberFormat.currency(locale: 'en_IN', decimalDigits: 0, name: '');
  return numberFormat.format(number);
}

void deleteBudgetListItem(
    BuildContext context, BudgetDetails details, bool isRecurringBudget) {
  final Widget cancelButton = FlatButton(
    child: const Text('Cancel'),
    textColor: Theme.of(context).primaryColor,
    onPressed: () {
      Navigator.pop(context);
    },
  );
  final Widget continueButton = FlatButton(
    child: const Text('Delete'),
    textColor: Theme.of(context).primaryColor,
    onPressed: () {
      final Store<BudgetAppState> state =
          StoreProvider.of<BudgetAppState>(context);
      if (null != isRecurringBudget && true == isRecurringBudget) {
        state.dispatch(deleteRecurringRecord(details));
      } else {
        state.dispatch(deleteRecordWithThunk(details));
      }

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
          actions: <Widget>[
            cancelButton,
            continueButton,
          ],
        );
      });
}

Widget _statusSwitch(BudgetDetails budgetDetails, bool isRecurringBudget) {
  if (true != isRecurringBudget) {
    return StatusSwitch(budgetDetails: budgetDetails);
  } else {
    return Container();
  }
}

Widget budgetCardItemBuilder(
    BudgetDetails budgetDetails, BuildContext context, bool isRecurringBudget) {
  return Card(
      key: Key(budgetDetails.id),
      //clipBehavior: Clip.antiAlias,
      elevation: 2,
      //color: Colors.white70,
      child: ClipPath(
        child: Container(
          height: 120,
          child: Column(
            children: <Widget>[
              ListTile(
                isThreeLine: false,
                title: Text(budgetDetails.title),
                trailing: IconButton(
                  icon: Icon(Icons.edit,
                      color: Theme.of(context).iconTheme.color),
                  onPressed: () => <void>{
                    if (budgetDetails != null)
                      <void>{
                        Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    EditFullScreenDialog(
                                        budgetDetails: budgetDetails,
                                        isRecurringBudget: isRecurringBudget),
                                fullscreenDialog: true))
                      }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 15, bottom: 5),
                      child: Text(
                          'Amount: $_rupeeSymbol${formatNumber(budgetDetails.amount)}'),
                    ),
                    const Spacer(),
                    _statusSwitch(budgetDetails, isRecurringBudget),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: IconButton(
                          icon: Icon(Icons.delete_rounded,
                              color: Theme.of(context).iconTheme.color),
                          onPressed: () => <void>{
                                deleteBudgetListItem(
                                    context, budgetDetails, isRecurringBudget)
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

final String _rupeeSymbol = String.fromCharCodes(Runes(' \u{20B9}'));

Widget floatingAddNewRecordToBudget(
    BuildContext context, bool isRecurringBudgetRecord) {
  return FloatingActionButton(
      backgroundColor:
          Theme.of(context).floatingActionButtonTheme.backgroundColor,
      foregroundColor:
          Theme.of(context).floatingActionButtonTheme.foregroundColor,
      child: const Icon(Icons.add),
      onPressed: () {
        final Store<BudgetAppState> _state =
            StoreProvider.of<BudgetAppState>(context);
        final Widget _okButton = FlatButton(
          child: const Text('Okay'),
          textColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.pop(context);
          },
        );
        if (null != isRecurringBudgetRecord &&
            true == isRecurringBudgetRecord) {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const AddRecord(
                isRecurringBudget: true,
              ),
              fullscreenDialog: true,
            ),
          );
        } else {
          if (_state.state.selectedMonthRecord != null) {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => AddRecord(
                  isRecurringBudget: isRecurringBudgetRecord,
                ),
                fullscreenDialog: true,
              ),
            );
          } else {
            showDialog<AlertDialog>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('No month budget created!!'),
                    content: const Text(
                        'Please create monthly budget to add the record'),
                    actions: <Widget>[_okButton],
                  );
                });
          }
        }
      });
}
