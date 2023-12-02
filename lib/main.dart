import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'food_database.dart';
import 'meal_plan_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calories Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Database helper instance for CRUD operations
  final dbHelper = DatabaseHelper();

  // Variables for the app
  int targetCalories = 0;
  DateTime selectedDate = DateTime.now();
  int totalConsumedCalories = 0;
  TextEditingController foodController = TextEditingController();
  int calories = 0;
  bool usePredefinedList = true;

  @override
  void initState() {
    super.initState();
    // Load the initial total consumed calories when the app starts
    _loadTotalConsumedCalories();
  }

  // Custom function to pick a date
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      // If a date is picked, update the selected date and reload total consumed calories
      setState(() {
        selectedDate = picked;
        _loadTotalConsumedCalories();
      });
    }
  }

  // Custom function to load total consumed calories after food items are added
  void _loadTotalConsumedCalories() async {
    final consumedFoods =
        await dbHelper.getMealPlanForDate(_formatDate(selectedDate));
    int totalCalories =
        consumedFoods.fold(0, (sum, food) => sum + food.calories);
    setState(() {
      totalConsumedCalories = totalCalories;
    });
  }

  // Format a date to 'yyyy-MM-dd' string
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Custom function to show a dialog box with a list of foods
  Future<void> _showFoodSelectionDialog() async {
    List<Map<String, dynamic>> foods = await dbHelper.getFoods();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Food'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text('Use Predefined List'),
                Column(
                  children: foods.map((food) {
                    return ListTile(
                      title: Text(food['name']),
                      onTap: () {
                        if (food['name'] != null && food['name'].isNotEmpty) {
                          // If a food is selected, update the text field and calories
                          setState(() {
                            foodController.text = food['name'];
                            calories = food['calories'];
                          });
                        }
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Custom function to add food to the meal plan
  void _addFood() async {
    // Check if a date is selected
    if (selectedDate == null) {
      _showSnackBar('Please select a date.');
      return;
    }

    // Check if target calories is inputted
    if (targetCalories == 0) {
      _showSnackBar('Please enter target calories');
      return;
    }

    await _showFoodSelectionDialog();

    if (calories > 0) {
      // Check if calories is greater than 0 before adding to total.
      if (totalConsumedCalories + calories > targetCalories) {
        _showSnackBar('Exceeding Target Calories!');
        return;
      }

      // Insert food item to the database
      await dbHelper.insertFood(
        foodController.text,
        calories,
        _formatDate(selectedDate),
      );

      // Update total calories
      _loadTotalConsumedCalories();

      // Reset state
      setState(() {
        foodController.text = '';
        calories = 0;
      });
    }
  }

  // Custom function to remove food
  void _deleteFood(int calories) {
    // Remove food calories from the state
    setState(() {
      totalConsumedCalories -= calories;
    });
  }

  // Custom function to navigate to the meal plan screen
  void _viewMealPlan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealPlanScreen(
          selectedDate: selectedDate,
          onDeleteFood: _deleteFood,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calories Calculator'),
      ),
      body: Column(
        children: [
          _buildTargetCaloriesInput(),
          _buildSelectedDateRow(),
          _buildAddFoodButton(),
          _buildTotalConsumedCaloriesText(),
          if (totalConsumedCalories > targetCalories)
            _buildExceedingCaloriesWarning(),
          _buildViewMealPlanButton(),
        ],
      ),
    );
  }

  // Widget for the target calories input
  Widget _buildTargetCaloriesInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Target Calories:'),
            SizedBox(height: 10),
            Container(
              width: 100,
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  // Update target calories when the input changes
                  setState(() {
                    targetCalories = int.parse(value);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for the selected date row
  Widget _buildSelectedDateRow() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Selected Date: ${_formatDate(selectedDate)}'),
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget for the add food button
  Widget _buildAddFoodButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _addFood,
                child: Text('Add Food'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget for displaying total consumed calories
  Widget _buildTotalConsumedCaloriesText() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          'Total Consumed Calories: $totalConsumedCalories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Widget for displaying a warning if calories exceed the target
  Widget _buildExceedingCaloriesWarning() {
    return Text(
      'Warning: Exceeding Target Calories!',
      style: TextStyle(color: Colors.red),
    );
  }

  // Widget for the view meal plan button
  Widget _buildViewMealPlanButton() {
    return ElevatedButton(
      onPressed: _viewMealPlan,
      child: Text('View Meal Plan'),
    );
  }

  // Function to show a snackbar with a message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 5),
      ),
    );
  }
}
