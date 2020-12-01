import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/database/DatabaseUtil.dart';
import 'package:home_budget_app/home/model/HomeBudgetOverview.dart';
import 'package:home_budget_app/home/redux/BudgetAppState.dart';
import 'package:home_budget_app/home/redux/ThunkActions.dart';
import 'package:home_budget_app/home/redux/actions.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:uuid/uuid.dart';

Uuid uuid = new Uuid();

class CreateNewMonthlyBudget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: AddNewBudgetForm());
  }
}

class AddNewBudgetForm extends StatefulWidget {
  @override
  _AddNewBudgetFormState createState() => _AddNewBudgetFormState();
}

class _AddNewBudgetFormState extends State<AddNewBudgetForm> {
  final _formKey = GlobalKey<FormState>();
  final titleTextController = TextEditingController();
  final dateController = TextEditingController();
  DateTime selectedDateFromApp = null;
  bool _isDateValid = true;

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    titleTextController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    var state = StoreProvider.of<BudgetAppState>(context).state;
    return Form(
        key: _formKey,
        child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  state.isCreateNewBudgetValid
                      ? Container()
                      : Text(
                          "Record already exists",
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                  TextFormField(
                      controller: dateController,
                      decoration: InputDecoration(
                          labelText: 'Select Month & Year',
                          hintText: 'Select Month & Year',
                          disabledBorder: InputBorder.none,
                          errorText: !_isDateValid
                              ? 'Please select Month & Year'
                              : null,
                          icon: const Icon(Icons.calendar_today)),
                      onTap: () {
                        StoreProvider.of<BudgetAppState>(context)
                            .dispatch(ValidCreateNewBudget(true));
                        FocusScope.of(context).requestFocus(new FocusNode());
                        showMonthPicker(
                          context: context,
                          firstDate: DateTime(DateTime.now().year - 1, 5),
                          lastDate: DateTime(DateTime.now().year + 1, 9),
                          initialDate: selectedDate,
                          //  locale: Locale("es"),
                        ).then((date) {
                          if (date != null) {
                            setState(() {
                              final DateFormat formatter =
                                  DateFormat('MMM-yyyy');
                              dateController.text = formatter.format(date);
                              selectedDateFromApp = date;
                            });
                          }
                        });
                      }),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: RaisedButton(
                          color: Colors.lightBlue,
                          onPressed: () {
                            setState(() {
                              debugPrint("dateController.text.isEmpty: " +
                                  dateController.text.isEmpty.toString());
                              dateController.text.isEmpty
                                  ? _isDateValid = false
                                  : _isDateValid = true;
                              if (_isDateValid) {
                                _validateAndCreateNewBudget(
                                    selectedDateFromApp, dateController.text);
                              }
                            });
                          },
                          child: Text(
                            "CREATE NEW BUDGET",
                            style: TextStyle(
                                //  color: Colors.black12,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          )),
                    ),
                  )
                ])));
  }

  void _validateAndCreateNewBudget(
      DateTime selectedDate, String formattedDate) {
    if (null != selectedDate) {
      var state = StoreProvider.of<BudgetAppState>(context);
      state.dispatch(addNewMonthlyBudget(selectedDate, formattedDate, context));
      // Add if no record exists.
    }
  }
}
