import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/redux/budget_app_state.dart';
import 'package:home_budget_app/home/redux/thunk_actions.dart';
import 'package:home_budget_app/home/redux/actions.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:redux/src/store.dart';
import 'package:uuid/uuid.dart';

Uuid uuid = Uuid();

Widget createNewBudget(BuildContext context) {
  final Store<BudgetAppState> _state =
      StoreProvider.of<BudgetAppState>(context);
  _state.dispatch(ValidCreateNewBudget(true));
  showDialog<SimpleDialog>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
            title: const Text('Create New Month Budget Plan'),
            children: <Widget>[CreateNewMonthlyBudget()],
          ));
}

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime _selectedDateFromApp;
  bool _isDateValid = true;
  bool _copyRecurringRecords = true;

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _titleTextController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime _selectedDate = DateTime.now();
    final BudgetAppState _state =
        StoreProvider.of<BudgetAppState>(context).state;
    return Form(
        key: _formKey,
        child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (_state.isCreateNewBudgetValid)
                    Container()
                  else
                    const Text(
                      'Record already exists',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  TextFormField(
                      controller: _dateController,
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
                        FocusScope.of(context).requestFocus(FocusNode());
                        showMonthPicker(
                          context: context,
                          firstDate: DateTime(DateTime.now().year - 1),
                          lastDate: DateTime(DateTime.now().year + 4),
                          initialDate: _selectedDate,
                        ).then((DateTime date) {
                          if (date != null) {
                            setState(() {
                              final DateFormat _formatter =
                                  DateFormat('MMM-yyyy');
                              _dateController.text = _formatter.format(date);
                              _selectedDateFromApp = date;
                            });
                          }
                        });
                      }),
                  Row(
                    children: [
                      const Text('Copy Recurring records: '),
                      Checkbox(
                        value: _copyRecurringRecords,
                        onChanged: (bool value) {
                          setState(() {
                            _copyRecurringRecords = value;
                          });
                        },
                      )
                    ],
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: RaisedButton(
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            setState(() {
                              _dateController.text.isEmpty
                                  ? _isDateValid = false
                                  : _isDateValid = true;
                              if (_isDateValid) {
                                _validateAndCreateNewBudget(
                                    _selectedDateFromApp, _dateController.text);
                              }
                            });
                          },
                          child: const Text(
                            'CREATE NEW BUDGET',
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
      setState(() {
        final Store<BudgetAppState> _state =
            StoreProvider.of<BudgetAppState>(context);
        _state.dispatch(
            addNewMonthlyBudget(selectedDate, formattedDate, context, _copyRecurringRecords));
      });
    }
  }
}
