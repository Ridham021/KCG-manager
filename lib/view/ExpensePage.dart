import 'dart:collection';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class ExpensePage extends StatefulWidget {
  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final databaseRef = FirebaseDatabase.instance.reference();

  String heading = '';
  String description = '';
  double amount = 0.0;
  DateTime selectedDate = DateTime.now();
  TextEditingController _dateController = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(DateTime.now()));
  TextEditingController _headingController = TextEditingController(text: '');
  TextEditingController _descriptionController =
      TextEditingController(text: '');
  TextEditingController _amountController = TextEditingController(text: '');

  List<Map<dynamic, dynamic>> expenseList = [];

  @override
  void initState() {
    super.initState();

    // Fetch the expense data when the widget is initialized
    _fetchExpenses();
  }

  void _fetchExpenses() {
    databaseRef.child('expenses').once().then((DatabaseEvent snapshot) {
      DataSnapshot dataSnapshot = snapshot.snapshot;

      // Clear the existing expense list
      expenseList.clear();

      // Retrieve the data from the snapshot and add it to the expense list
      Object? expenses = dataSnapshot.value;
      if (expenses != null) {
        (expenses as Map<dynamic, dynamic>).forEach((key, value) {
          expenseList.add({
            'key': key,
            'heading': value['heading'],
            'description': value['description'],
            'amount': value['amount'],
            'date': value['date'],
          });
        });
      }

      // Update the widget state
      setState(() {});
    });
  }

  void _addExpense() {
    // Create a unique key for the expense entry
    var newExpenseRef = databaseRef.child('expenses').push();

    // Save the expense data to Firebase
    newExpenseRef.set({
      'heading': heading,
      'description': description,
      'amount': amount,
      'date': selectedDate.toString(),
    });

    // Clear the form fields
    setState(() {
      heading = '';
      description = '';
      amount = 0.0;
      selectedDate = DateTime.now();
    });
    _fetchExpenses();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2024),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Rebuild called");
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Show the modal dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Add Expense'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'Heading'),
                      controller: _headingController,
                      onChanged: (value) {
                        setState(() {
                          heading = value;
                        });
                      },
                    ),
                    TextField(
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      controller: _descriptionController,
                      onChanged: (value) {
                        setState(() {
                          description = value;
                        });
                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Amount'),
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          amount = double.parse(value);
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    // ElevatedButton(
                    //   onPressed: () async {
                    //     // Show the date picker
                    //     final DateTime? picked = await showDatePicker(
                    //       context: context,
                    //       initialDate: selectedDate,
                    //       firstDate: DateTime(2021),
                    //       lastDate: DateTime(2024),
                    //     );
                    //     if (picked != null && picked != selectedDate) {
                    //       setState(() {
                    //         selectedDate = picked;
                    //       });
                    //     }
                    //   },
                    //   child: Text('Date: ${selectedDate.toString()}'),
                    // ),
                    GestureDetector(
                      onTap: () async {
                        DateTime initialDate = DateTime.now();
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: DateTime(1600),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            this._dateController.text =
                                DateFormat('dd-MM-yyyy').format(selectedDate);
                          });
                        }
                      },
                      child: TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: 'Expense Date',
                          suffixIcon:
                              Icon(Icons.calendar_today, color: Colors.blue),
                        ),
                        enabled: false, // Disable user editing
                      ),
                    )
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      // Add expense to Firebase
                      _addExpense();

                      // Close the modal dialog
                      Navigator.of(context).pop();
                    },
                    child: const Text('Add'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Clear the form fields
                      setState(() {
                        heading = '';
                        description = '';
                        amount = 0.0;
                        selectedDate = DateTime.now();
                        _headingController.clear();
                        _descriptionController.clear();
                        _amountController.clear();
                        _dateController.text =
                            DateFormat('dd-MM-yyyy').format(DateTime.now());
                      });
                      print("Reset Called");
                    },
                    child: const Text('Reset'),
                  ),
                ],
              );
            },
          );
        },
      ),
      appBar: AppBar(
        title: const Text('Expense Page'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: expenseList.length,
                itemBuilder: (context, index) {
                  Map<dynamic, dynamic> expense = expenseList[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(expense['heading']),
                        subtitle: Text(expense['description']),
                        trailing: Text('\$${expense['amount']}'),
                        onTap: () {
                          // Handle tapping on an expense item
                          // You can navigate to a detail page or perform any other action
                          print('Tapped on expense: ${expense['key']}');
                        },
                      ),
                      const Divider(height: 2, thickness: 2),
                      // Add a horizontal line divider
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
