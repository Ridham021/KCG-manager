import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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
        (expenses as Map<dynamic,dynamic>).forEach((key, value) {

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Page'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton.icon(
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
                            onChanged: (value) {
                              setState(() {
                                heading = value;
                              });
                            },
                          ),
                          TextField(
                            decoration:
                            const InputDecoration(labelText: 'Description'),
                            onChanged: (value) {
                              setState(() {
                                description = value;
                              });
                            },
                          ),
                          TextField(
                            decoration: const InputDecoration(labelText: 'Amount'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                amount = double.parse(value);
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () async {
                              // Show the date picker
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
                            },
                            child: Text('Date: ${selectedDate.toString()}'),
                          ),
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
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            ),

            // Display the expense data
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
                      const Divider(height: 2,thickness: 2), // Add a horizontal line divider
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
