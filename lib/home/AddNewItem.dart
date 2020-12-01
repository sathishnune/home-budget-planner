import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:home_budget_app/home/BudgetDetails.dart';
import 'package:home_budget_app/home/redux/BudgetAppState.dart';
import 'package:home_budget_app/home/redux/ThunkActions.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:uuid/uuid.dart';

Uuid uuid = new Uuid();

class AddRecord extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text("Add record"),
            shadowColor: Colors.lightBlueAccent,
            //actions: [],
          ),
          body: AddRecordForm(),
        )
      ],
    );
  }
}

class AddRecordForm extends StatefulWidget {
  @override
  AddRecordFormState createState() {
    return AddRecordFormState();
  }
}

class AddRecordFormState extends State<AddRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final titleTextController = TextEditingController();
  final amountTextController = TextEditingController();
  bool _validTitleText = true;
  bool _validAmount = true;

  String transactionType = "Credit";

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    titleTextController.dispose();
    amountTextController.dispose();
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
              controller: titleTextController,
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
              controller: amountTextController,
              decoration: InputDecoration(
                  icon: Icon(
                    MdiIcons.currencyInr,
                  ),
                  hintText: 'Enter Amount',
                  labelText: 'Amount',
                  errorText: !_validAmount ? 'Amount can\'t be Empty' : null),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Radio(
                      value: "Credit",
                      groupValue: transactionType,
                      onChanged: (value) => {
                        setState(() {
                          transactionType = value;
                        })
                      },
                    ),
                    new Text(
                      'Credit',
                      style: new TextStyle(fontSize: 18.0),
                    ),
                    new Radio(
                        value: "Debit",
                        groupValue: transactionType,
                        onChanged: (value) => {
                              setState(() {
                                transactionType = value;
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
                        titleTextController.text.trim().isEmpty
                            ? _validTitleText = false
                            : _validTitleText = true;

                        amountTextController.text.trim().isEmpty
                            ? _validAmount = false
                            : _validAmount = true;

                        if (_validTitleText && _validAmount) {
                          _readTheValues();
                        }
                      });
                    },
                    child: Text(
                      "ADD",
                      style: TextStyle(
                          //  color: Colors.black12,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _readTheValues() {
    var state = StoreProvider.of<BudgetAppState>(context);
    final BudgetDetails details = BudgetDetails();
    details.amount = int.parse(amountTextController.text);
    details.title = titleTextController.text.trim();
    details.type = transactionType;
    details.id = uuid.v4();
    state.dispatch(addNewRecordWithThunk(details));

    Navigator.pop(context);
  }
}
