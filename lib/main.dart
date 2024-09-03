import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that everything is initialized before running the app
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int savedCounter = prefs.getInt('counter') ?? 0; // Load the saved counter value
  List<String> savedTextFields = prefs.getStringList('textFields') ?? []; // Load the saved text fields
  runApp(MyApp(savedCounter: savedCounter, savedTextFields: savedTextFields));
}

class MyApp extends StatelessWidget {
  final int savedCounter;
  final List<String> savedTextFields;

  const MyApp({super.key, required this.savedCounter, required this.savedTextFields});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 183, 58, 154)),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', savedCounter: savedCounter, savedTextFields: savedTextFields),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final int savedCounter;
  final List<String> savedTextFields;

  const MyHomePage({super.key, required this.title, required this.savedCounter, required this.savedTextFields});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int _counter;
  late List<TextEditingController> _controllers;
  late List<String> _textFields;

  @override
  void initState() {
    super.initState();
    _counter = widget.savedCounter; // Initialize the counter with the saved value
    _textFields = widget.savedTextFields; // Initialize the text fields with saved values
    _controllers = _textFields.map((text) => TextEditingController(text: text)).toList();
  }

  void _incrementCounter() async {
    setState(() {
      _counter++;
      _controllers.add(TextEditingController()); // Add a new text controller
    });
    _saveData();
  }

  void _decrementCounter() async {
    if (_controllers.isNotEmpty) {
      setState(() {
        _counter--;
        _controllers.removeLast(); // Remove the last text controller (LIFO)
      });
      _saveData();
    }
  }

  void _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('counter', _counter); // Save the updated counter value
    _textFields = _controllers.map((controller) => controller.text).toList();
    prefs.setStringList('textFields', _textFields); // Save the updated text field values
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have this tasks to do'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _controllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _controllers[index],
                      onChanged: (text) => _saveData(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter text ${index + 1}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Add Text Field',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _decrementCounter,
            tooltip: 'Remove Text Field',
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
