import 'package:flutter/material.dart';

class ViewRecipePage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const ViewRecipePage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> ingredients =
        (recipe['ingredients'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList() ??
            [];

    const Color peach = Color(0xFFFFCBA4);
    const Color peachDark = Color(0xFFFFA86F);

    return Scaffold(
    backgroundColor: Colors.grey[100],
    appBar: AppBar(
    backgroundColor: peach,
    foregroundColor: Colors.white,
    title: Text(recipe['name'] ?? 'Recette'),
    ),
    body: Padding(
    padding: const EdgeInsets.all(16.0),
    child: ListView(
    children: [
    // Description
    Card(
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12)),
    color: Colors.white,
    child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text('Description',
    style: TextStyle(
    fontWeight: FontWeight.bold, fontSize: 18)),
    const SizedBox(height: 8),
    Text(recipe['description'] ?? '',
    style: TextStyle(fontSize: 16)),
    ],
    ),
    ),
    ),
    const SizedBox(height: 16),

    // Time Preparation & Baking
    Row(
    children: [
    Expanded(
    child: Card(
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12)),
    color: peach.withOpacity(0.3),
    child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    children: [
    Icon(Icons.timer, color: peachDark),
    const SizedBox(height: 8),
    Text('Préparation',
    style: TextStyle(fontWeight: FontWeight.bold)),
    Text('${recipe['time_preparation'] ?? 0} min'),
    ],
    ),
    ),
    ),
    ),
    const SizedBox(width: 16),
    Expanded(
    child: Card(
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12)),
    color: peach.withOpacity(0.3),
    child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    children: [
    Icon(Icons.local_fire_department, color: peachDark),
    const SizedBox(height: 8),
    Text('Cuisson',
    style: TextStyle(fontWeight: FontWeight.bold)),
    Text('${recipe['time_baking'] ?? 0} min'),
    ],
    ),
    ),
    ),
    ),
    ],
    ),
    const SizedBox(height: 16),

    // Instructions
    Card(
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12)),
    color: Colors.white,
    child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text('Instructions',
    style: TextStyle(
    fontWeight: FontWeight.bold, fontSize: 18)),
    const SizedBox(height: 8),
    Text(recipe['instructions'] ?? '',
    style: TextStyle(fontSize: 16)),
    ]),
    ),
    ),
    const SizedBox(height: 16),

    // Ingredients
    Text('Ingrédients',
    style: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: peachDark)),
    const SizedBox(height: 8),
    if (ingredients.isEmpty)
    const Text('Aucun ingrédient.',
    style: TextStyle(color: Colors.grey))
    else
    ...ingredients.map((ing) => Card(
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8)),
    color: Colors.white,
    child: ListTile(
    leading: Icon(Icons.food_bank, color: peach),
    title: Text(ing['name'] ?? 'Ingrédient'),
    subtitle: ing['barcode'] != null
    ? Text('Code-barres : ${ing['barcode']}')
        : null,
    ),
    )),
    ],
    ),
    ),
    );


  }
}
