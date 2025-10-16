import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // For mobile storage

void main() {
  runApp(const CGPAApp());
}

class CGPAApp extends StatelessWidget {
  const CGPAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CGPA Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4B39EF)), // Purple-Blue Accent
        scaffoldBackgroundColor: const Color(0xFFF2F3F7),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> courseControllers = [];
  final List<TextEditingController> creditControllers = [];
  final List<TextEditingController> gradeControllers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'courses': courseControllers.map((e) => e.text).toList(),
      'credits': creditControllers.map((e) => e.text).toList(),
      'grades': gradeControllers.map((e) => e.text).toList(),
    };
    prefs.setString('cgpaData', jsonEncode(data));
  }

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('cgpaData');
    if (stored != null) {
      final data = jsonDecode(stored);
      final courses = List<String>.from(data['courses']);
      final credits = List<String>.from(data['credits']);
      final grades = List<String>.from(data['grades']);
      setState(() {
        for (int i = 0; i < courses.length; i++) {
          courseControllers.add(TextEditingController(text: courses[i]));
          creditControllers.add(TextEditingController(text: credits[i]));
          gradeControllers.add(TextEditingController(text: grades[i]));
        }
      });
    }
  }

  void _addSubject() {
    setState(() {
      courseControllers.add(TextEditingController());
      creditControllers.add(TextEditingController());
      gradeControllers.add(TextEditingController());
    });
  }

  void _calculateCGPA() {
    double totalPoints = 0;
    double totalCredits = 0;

    for (int i = 0; i < creditControllers.length; i++) {
      final credit = double.tryParse(creditControllers[i].text) ?? 0;
      final grade = double.tryParse(gradeControllers[i].text) ?? 0;
      totalPoints += credit * grade;
      totalCredits += credit;
    }

    double cgpa = totalCredits == 0 ? 0 : totalPoints / totalCredits;

    _saveData();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultDisplayScreen(cgpa: cgpa),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '✨ CGPA Calculator ✨',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: accentColor,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: courseControllers.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: courseControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Course Name',
                                prefixIcon:
                                Icon(Icons.book, color: accentColor),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: creditControllers[index],
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Credit Hours',
                                      prefixIcon:
                                      Icon(Icons.timer, color: accentC<caret>olor),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: gradeControllers[index],
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Grade Points',
                                      prefixIcon:
                                      Icon(Icons.grade, color: accentColor),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () {
                                    setState(() {
                                      courseControllers.removeAt(index);
                                      creditControllers.removeAt(index);
                                      gradeControllers.removeAt(index);
                                    });
                                    _saveData();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _addSubject,
                      icon: const Icon(Icons.add),
                      label: const Text("Add Course"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _calculateCGPA,
                      icon: const Icon(Icons.calculate),
                      label: const Text("Calculate CGPA"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ResultDisplayScreen extends StatelessWidget {
  final double cgpa;

  const ResultDisplayScreen({super.key, required this.cgpa});

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: accentColor,
      appBar: AppBar(
        title: const Text('🎓 Your Result'),
        backgroundColor: accentColor,
      ),
      body: Center(
        child: Card(
          color: Colors.white,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Text(
              'Your CGPA is: \${cgpa.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
