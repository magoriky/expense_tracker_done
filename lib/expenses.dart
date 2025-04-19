import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});
  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends State<Expenses> {
  late Box<Expense> _expenseBox;
  @override
  void initState() {
    super.initState();
    _expenseBox = Hive.box<Expense>('expenses');
  }
  // final List<Expense> _registeredExpenses = [
  //   Expense(
  //     title: "Flutter Course",
  //     amount: 19.99,
  //     date: DateTime.now(),
  //     category: Category.work,
  //   ),
  //   Expense(
  //     title: "Cinema",
  //     amount: 15.69,
  //     date: DateTime.now(),
  //     category: Category.leisure,
  //   )
  // ];

  void _addExpense(Expense expense) {
    _expenseBox.add(expense);
    // setState(() {
    //   _registeredExpenses.add(expense);
    // });
  }

  void _removeExpense(int index) {
    //final expenseIndex = _registeredExpenses.indexOf(expense);
    final expense = _expenseBox.getAt(index);
    if (expense == null) return;
    _expenseBox.deleteAt(index);

    // setState(() {
    //   _registeredExpenses.remove(expense);
    // });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("expense Deleted"),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            _expenseBox.putAt(index, expense);
            // setState(() {
            //   _registeredExpenses.insert(expenseIndex, expense);
            // });
          },
        ),
      ),
    );
  }

  void _openAddExpenseOverlay() {
    //* This is quite interesting because it kind of opens a new screen without having to change the widget
    //* Search about showModalBottomSheet if you forgot, this is quite useful
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(onAddExpense: _addExpense),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    //print(MediaQuery.of(context).size.height);
    print("height: $height");
    print("width: $width");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter ExpenseTracker'),
        actions: [
          IconButton(
            onPressed: _openAddExpenseOverlay,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _expenseBox.listenable(),
        builder: (context, Box<Expense> box, _) {
          final expenses = box.values.toList();

          Widget mainContent = const Center(
            child: Text("No expenses found. Start adding some!"),
          );

          if (expenses.isNotEmpty) {
            mainContent = ExpensesList(
              onRemoveExpense: _removeExpense,
              expenses: expenses,
            );
          }

          return Column(
            children: [Chart(expenses: expenses), Expanded(child: mainContent)],
          );
        },
      ),
    );
  }
}
