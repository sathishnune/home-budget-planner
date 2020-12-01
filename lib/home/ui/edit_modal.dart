import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/redux/budget_app_state.dart';
import 'package:home_budget_app/home/redux/thunk_actions.dart';
import 'package:home_budget_app/home/ui/budget_details.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:redux/src/store.dart';

class EditFullScreenDialog extends StatelessWidget {
  const EditFullScreenDialog({this.budgetDetails});

  final BudgetDetails budgetDetails;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
              title: const Text('Edit the record'),
              elevation: 7,
              // backgroundColor: Colors.transparent,
              shadowColor: Colors.lightBlueAccent,
            ),
            body: EditForm(editRecord: budgetDetails))
      ],
    );
  }
}

class EditForm extends StatefulWidget {
  const EditForm({this.editRecord});

  final BudgetDetails editRecord;

  @override
  _EditFormState createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleTextEditController = TextEditingController();
  TextEditingController _amountTextEditController = TextEditingController();
  bool _validTitleText = true;
  bool _validAmount = true;
  String _transactionType = 'Credit';

  @override
  void initState() {
    super.initState();
    _titleTextEditController =
        TextEditingController(text: widget.editRecord.title);
    _amountTextEditController =
        TextEditingController(text: widget.editRecord.amount.toString());
    _transactionType = widget.editRecord.type;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _titleTextEditController.dispose();
    _amountTextEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: _titleTextEditController,
                    decoration: InputDecoration(
                        icon: const Icon(Icons.description),
                        hintText: 'Enter Title',
                        labelText: 'Title',
                        errorText:
                            !_validTitleText ? 'Amount can\'t be empty' : null),
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _amountTextEditController,
                    decoration: InputDecoration(
                        icon: const Icon(
                          MdiIcons.currencyInr,
                        ),
                        hintText: 'Enter Amount',
                        labelText: 'Amount',
                        errorText:
                            !_validAmount ? 'Amount can\'t be empty' : null),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Radio(
                            value: 'Credit',
                            groupValue: _transactionType,
                            onChanged: (String value) => {
                              setState(() {
                                _transactionType = value;
                              })
                            },
                          ),
                          const Text(
                            'Credit',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          Radio(
                              value: 'Debit',
                              groupValue: _transactionType,
                              onChanged: (String value) => {
                                    setState(() {
                                      _transactionType = value;
                                    })
                                  }),
                          const Text(
                            'Debit',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          )
                        ]),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: RaisedButton(
                          color: Colors.lightBlue,
                          onPressed: () {
                            setState(() {
                              _titleTextEditController.text.trim().isEmpty
                                  ? _validTitleText = false
                                  : _validTitleText = true;

                              _amountTextEditController.text.trim().isEmpty
                                  ? _validAmount = false
                                  : _validAmount = true;

                              if (_validTitleText && _validAmount) {
                                _updateRecord();
                              }
                            });
                          },
                          child: const Text(
                            'SAVE',
                            style: TextStyle(
                                //  color: Colors.black12,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          )),
                    ),
                  )
                ])));
  }

  void _updateRecord() {
    final Store<BudgetAppState> _state =
        StoreProvider.of<BudgetAppState>(context);
    final BudgetDetails details = widget.editRecord;
    details.amount = int.parse(_amountTextEditController.text);
    details.title = _titleTextEditController.text.trim();
    details.type = _transactionType;
    _state.dispatch(editRecordWithThunk(details));
    Navigator.pop(context);
  }
}
