import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signal Visualizer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SignalScreen(),
    );
  }
}

class SignalScreen extends StatefulWidget {
  const SignalScreen({super.key});

  @override
  _SignalScreenState createState() => _SignalScreenState();
}

class _SignalScreenState extends State<SignalScreen> {
  String _selectedSignal = "x1"; // Default signal
  Uint8List? _imageData;

  Future<void> fetchSignal() async {
    final url = Uri.parse(
      "http://192.168.43.130:5000/get_signal",
    ); // Update with Render URL if deployed
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"signal_id": _selectedSignal}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _imageData = base64Decode(data["image"]);
      });
    } else {
      setState(() {
        _imageData = null;
      });
      print("Error: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signal Visualizer")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropdownButton<String>(
            value: _selectedSignal,
            items:
                ["x1", "x2", "x3", "x4", "x5", "x6", "x7", "x8"].map((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text("Signal $value"),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedSignal = newValue!;
              });
            },
          ),
          ElevatedButton(onPressed: fetchSignal, child: Text("Fetch Signal")),
          _imageData != null
              ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.memory(_imageData!),
              )
              : Text("No Image Yet"),
        ],
      ),
    );
  }
}
