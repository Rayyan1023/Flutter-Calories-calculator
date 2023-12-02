class Food {
  // Parameters for food
  int id;
  String name;
  int calories;
  String date;

  // Constructor for the Food class
  Food({
    required this.id,
    required this.name,
    required this.calories,
    required this.date,
  });

  // Convert Food object to a map
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'calories': calories, 'date': date};
  }

  // Factory method to create a Food object from a map
  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'],
      name: map['name'],
      calories: map['calories'],
      date: map['date'],
    );
  }
}
