import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

String? apiURL = dotenv.env['API_URL'];

void main() async {
  await dotenv.load();
  runApp(MuteCallsApp());
}

class MuteCallsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Request Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        cupertinoOverrideTheme: CupertinoThemeData(
          primaryColor: Colors.blue,
        ),
      ),
      home: HomePage(title: 'API Request Demo'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _responseText = '';
  bool _isLoading = false;

  Future<void> _makeApiRequest() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse('$apiURL/SendKeys'));

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      setState(() {
        _responseText = responseJson['title'];
      });
    } else {
      setState(() {
        _responseText = 'Error: ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isLoading)
              CupertinoActivityIndicator()
            else
              Text(
                _responseText,
                style: TextStyle(fontSize: 24),
              ),
            SizedBox(height: 32),
            CupertinoButton.filled(
              onPressed: _makeApiRequest,
              child: Text('Make API Request'),
            ),
          ],
        ),
      ),
    );
  }
}
