import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/redux/actions.dart';
import 'package:home_budget_app/home/redux/budget_app_state.dart';
import 'package:home_budget_app/home/redux/thunk_actions.dart';
import 'package:home_budget_app/home/ui/budget_details.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:redux/src/store.dart';
import 'package:uuid/uuid.dart';

Uuid uuid = Uuid();

class AddRecord extends StatelessWidget {
  const AddRecord({this.isRecurringBudget});

  final bool isRecurringBudget;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('Add record')),
          body: AddRecordForm(isRecurringBudget: isRecurringBudget),
        )
      ],
    );
  }
}

class AddRecordForm extends StatefulWidget {
  const AddRecordForm({this.isRecurringBudget});

  final bool isRecurringBudget;

  @override
  AddRecordFormState createState() {
    return AddRecordFormState();
  }
}

class AddRecordFormState extends State<AddRecordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _amountTextController = TextEditingController();
  bool _validTitleText = true;
  bool _validAmount = true;

  String _transactionType = 'Credit';

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _titleTextController.dispose();
    _amountTextController.dispose();
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
              autofocus: true,
              maxLength: 50,
              controller: _titleTextController,
              decoration: InputDecoration(
                icon: const Icon(Icons.description),
                hintText: 'Enter Title',
                labelText: 'Title',
                errorText: !_validTitleText ? 'Title Can\'t Be Empty' : null,
              ),
            ),
            TextFormField(
              maxLength: 6,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              controller: _amountTextController,
              decoration: InputDecoration(
                  icon: const Icon(
                    MdiIcons.currencyInr,
                  ),
                  hintText: 'Enter Amount',
                  labelText: 'Amount',
                  errorText: !_validAmount ? 'Amount can\'t be Empty' : null),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Radio<String>(
                      activeColor: Theme.of(context).primaryColor,
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
                    Radio<String>(
                        activeColor: Theme.of(context).primaryColor,
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
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      setState(() {
                        _titleTextController.text.trim().isEmpty
                            ? _validTitleText = false
                            : _validTitleText = true;

                        _amountTextController.text.trim().isEmpty
                            ? _validAmount = false
                            : _validAmount = true;

                        if (_validTitleText && _validAmount) {
                          _createNewRecord();
                        }
                      });
                    },
                    child: const Text('ADD')),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _createNewRecord() {
    final Store<BudgetAppState> _state =
        StoreProvider.of<BudgetAppState>(context);
    final BudgetDetails _details = BudgetDetails(
        amount: int.parse(_amountTextController.text),
        title: _titleTextController.text.trim(),
        type: _transactionType,
        isCompleted: false,
        id: uuid.v4());

    if (widget.isRecurringBudget != null && widget.isRecurringBudget == true) {
      _state.dispatch(addNewRecurringRecord(_details));
    } else {
      _state.dispatch(addNewRecordWithThunk(_details));
    }

    Navigator.pop(context);
  }
}
