import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/BudgetDetails.dart';
import 'package:home_budget_app/home/redux/BudgetAppState.dart';
import 'package:home_budget_app/home/redux/ThunkActions.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class EditFullScreenDialog extends StatelessWidget {
  final BudgetDetails budgetDetails;

  EditFullScreenDialog({this.budgetDetails});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
              title: Text("Edit the record"),
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
  final BudgetDetails editRecord;

  EditForm({this.editRecord});

  @override
  _EditFormState createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleTextEditController = TextEditingController();
  TextEditingController amountTextEditController = TextEditingController();
  bool _validTitleText = true;
  bool _validAmount = true;
  String transactionType2 = "Credit";

  @override
  void initState() {
    super.initState();
    titleTextEditController =
        TextEditingController(text: widget.editRecord.title);
    amountTextEditController =
        TextEditingController(text: widget.editRecord.amount.toString());
    transactionType2 = widget.editRecord.type;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    titleTextEditController.dispose();
    amountTextEditController.dispose();
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
                    controller: titleTextEditController,
                    decoration: InputDecoration(
                        icon: const Icon(Icons.description),
                        hintText: 'Enter Title',
                        labelText: 'Title',
                        errorText:
                            !_validTitleText ? 'Amount can\'t be empty' : null),
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: amountTextEditController,
                    decoration: InputDecoration(
                        icon: Icon(
                          MdiIcons.currencyInr,
                        ),
                        hintText: 'Enter Amount',
                        labelText: 'Amount',
                        errorText:
                            !_validAmount ? 'Amount can\'t be empty' : null),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: new Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Radio(
                            value: "Credit",
                            groupValue: transactionType2,
                            onChanged: (value) => {
                              setState(() {
                                transactionType2 = value;
                              })
                            },
                          ),
                          new Text(
                            'Credit',
                            style: new TextStyle(fontSize: 18.0),
                          ),
                          new Radio(
                              value: "Debit",
                              groupValue: transactionType2,
                              onChanged: (value) => {
                                    setState(() {
                                      transactionType2 = value;
                                    })
                                  }),
                          new Text(
                            'Debit',
                            style: new TextStyle(
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
                              titleTextEditController.text.trim().isEmpty
                                  ? _validTitleText = false
                                  : _validTitleText = true;

                              amountTextEditController.text.trim().isEmpty
                                  ? _validAmount = false
                                  : _validAmount = true;

                              if (_validTitleText && _validAmount) {
                                _readTheValues();
                              }
                            });
                          },
                          child: Text(
                            "SAVE",
                            style: TextStyle(
                                //  color: Colors.black12,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          )),
                    ),
                  )
                ])));
  }

  void _readTheValues() {
    var state = StoreProvider.of<BudgetAppState>(context);
    final BudgetDetails details = widget.editRecord;
    details.amount = int.parse(amountTextEditController.text);
    details.title = titleTextEditController.text.trim();
    details.type = transactionType2;
    state.dispatch(editRecordWithThunk(details));
    Navigator.pop(context);
  }
}
