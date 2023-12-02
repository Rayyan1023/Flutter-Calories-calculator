import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'food.dart';

class DatabaseHelper {
  static Database? _database;

  // Getter for the database instance, initializing if null
  Future<Database> get database async {
    return _database ??= await initDatabase();
  }

  // Initialize the database
  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'food_database.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create database tables and insert initial food items
  void _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE foods(id INTEGER PRIMARY KEY, name TEXT, calories INTEGER, date TEXT)',
    );
    await _insertInitialFoodItems(db);
  }

  // Handle database upgrades if needed
  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades if needed.
  }

  // Initialize database with food
  Future<void> _insertInitialFoodItems(Database db) async {
    final foodItems = [
      {'name': 'Peanuts (1 oz)', 'calories': 150},
      {'name': 'Orange (medium)', 'calories': 75},
      {'name': 'Chicken Thighs (cooked, 3 oz)', 'calories': 195},
      {'name': 'Eggplant (1 cup, chopped)', 'calories': 50},
      {'name': 'White Tuna (cooked, 3 oz)', 'calories': 115},
      {'name': 'Mac and Cheese (1 cup, cooked)', 'calories': 230},
      {'name': 'Red Tomato (medium)', 'calories': 60},
      {'name': 'Coke Zero', 'calories': 0},
      {'name': 'Egg (large)', 'calories': 83},
      {'name': 'Baked Potatoes (medium)', 'calories': 127},
      {'name': 'Lettuce (50g)', 'calories': 22},
      {'name': 'Plain Yogurt (1 cip)', 'calories': 69},
      {'name': 'Apple (medium)', 'calories': 61},
      {'name': 'Onions (1 cup, chopped)', 'calories': 41},
      {'name': 'White Rice (cooked, 1 cup)', 'calories': 215},
      {'name': 'Milk 2% (12 oz)', 'calories': 240},
      {'name': 'Lean Ground Beef (cooked, 3 oz)', 'calories': 320},
      {'name': 'Cream Cheese (2 tbsp)', 'calories': 135},
      {'name': 'Peach (medium)', 'calories': 40},
      {'name': 'Whole Wheat Bread (2 slice)', 'calories': 180},
    ];

    for (final foodItem in foodItems) {
      await db.insert(
        'foods',
        foodItem,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Add food to the database
  Future<void> insertFood(String name, int calories, String date) async {
    final db = await database;
    await db
        .insert('foods', {'name': name, 'calories': calories, 'date': date});
  }

  // Retrieve all foods from the database
  Future<List<Map<String, dynamic>>> getFoods() async {
    final db = await database;
    return db.query('foods');
  }

  // Get all food plans for a specific date
  Future<List<Food>> getMealPlanForDate(String date) async {
    final db = await database;
    final result =
        await db.query('foods', where: 'date = ?', whereArgs: [date]);
    return result.map((map) => Food.fromMap(map)).toList();
  }

  // Update food in the database
  Future<void> updateFood(
      int id, String name, int calories, String date) async {
    final db = await database;
    await db.update(
      'foods',
      {'name': name, 'calories': calories, 'date': date},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete food from the database
  Future<void> deleteFood(int id) async {
    final db = await database;
    await db.delete('foods', where: 'id = ?', whereArgs: [id]);
  }
}
