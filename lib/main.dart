import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String text = ""; // Text to display
  String result = ""; // Result of calculation
  List<String> expression = []; // Store the expression

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator', style: TextStyle(fontSize: 28)),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10),
              alignment: Alignment.bottomRight,
              height: 180,
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 60,
                  color: Colors.black54,
                ),
              ),
            ),
            // Delete button row
            Padding(
              padding: EdgeInsets.only(top: 90, left: 16.0, right: 16.0),
              child: Row(
                children: <Widget>[
                  OutlinedButton(
                    onPressed: () => btnClicked("<"),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.all(24),
                      backgroundColor: Colors.black38,
                      foregroundColor: Colors.white,
                    ),
                    child: Icon(
                      Icons.backspace_outlined,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: <Widget>[
                  customOutlinedButton("9"),
                  SizedBox(width: 10),
                  customOutlinedButton("8"),
                  SizedBox(width: 10),
                  customOutlinedButton("7"),
                  SizedBox(width: 10),
                  customOutlinedButton("+"),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: <Widget>[
                  customOutlinedButton("6"),
                  SizedBox(width: 10),
                  customOutlinedButton("5"),
                  SizedBox(width: 10),
                  customOutlinedButton("4"),
                  SizedBox(width: 10),
                  customOutlinedButton("-"),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: <Widget>[
                  customOutlinedButton("3"),
                  SizedBox(width: 10),
                  customOutlinedButton("2"),
                  SizedBox(width: 10),
                  customOutlinedButton("1"),
                  SizedBox(width: 10),
                  customOutlinedButton("*"),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: <Widget>[
                  customOutlinedButton("C"),
                  SizedBox(width: 10),
                  customOutlinedButton("0"),
                  SizedBox(width: 10),
                  customOutlinedButton("="),
                  SizedBox(width: 10),
                  customOutlinedButton("/"),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget customOutlinedButton(String val) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => btnClicked(val),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.all(24),
          backgroundColor: Colors.black38,
          foregroundColor: Colors.white,
        ),
        child: Text(
          val,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void btnClicked(String btnText) {
    if ((btnText == "+" || btnText == "-" || btnText == "*" || btnText == "/") && text.isEmpty) {
      setState(() {
        text = "Invalid input";
      });
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          text = "";
        });
      });
      return;
    }

    if (btnText == "C") {
      text = "";
      result = "";
      expression.clear();
      setState(() {
        text = "";
      });
    } else if (btnText == "<") {
      if (text.isNotEmpty) {
        setState(() {
          text = text.substring(0, text.length - 1);
          if (expression.isNotEmpty) {
            expression.removeLast();
          }
        });
      }
    } else if (btnText == "+" || btnText == "-" || btnText == "*" || btnText == "/") {
      if (expression.isNotEmpty && isOperator(expression.last)) {
        expression.removeLast();
        text = text.substring(0, text.length - 1);
      }
      expression.add(btnText);
      setState(() {
        text += btnText;
        if (text.length > 24) {
          text = text.substring(0, 24);
        }
      });
    } else if (btnText == "=") {
      calculateResult();
    } else {
      expression.add(btnText);
      setState(() {
        text += btnText;
      });
    }
  }

  bool isOperator(String char) {
    return char == "+" || char == "-" || char == "*" || char == "/";
  }

  void calculateResult() {
    try {
      String expressionStr = expression.join();
      result = evaluateExpression(expressionStr).toString();

      setState(() {
        text = result;
        expression = [result];
      });
    } catch (e) {
      setState(() {
        text = "Error";
      });
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          text = "";
        });
      });
      expression.clear();
    }
  }

  double evaluateExpression(String expression) {
    List<String> tokens = expression.split(RegExp(r'(?<=[-+*/])|(?=[-+*/])'));
    List<double> values = [];
    List<String> ops = [];

    for (String token in tokens) {
      if (double.tryParse(token) != null) {
        values.add(double.parse(token));
      } else if (isOperator(token)) {
        while (ops.isNotEmpty && precedence(ops.last) >= precedence(token)) {
          double b = values.removeLast();
          double a = values.removeLast();
          values.add(applyOp(ops.removeLast(), a, b));
        }
        ops.add(token);
      }
    }

    while (ops.isNotEmpty) {
      double b = values.removeLast();
      double a = values.removeLast();
      values.add(applyOp(ops.removeLast(), a, b));
    }

    return values.last;
  }

  int precedence(String op) {
    switch (op) {
      case "+":
      case "-":
        return 1;
      case "*":
      case "/":
        return 2;
      default:
        return 0;
    }
  }

  double applyOp(String op, double a, double b) {
    switch (op) {
      case "+":
        return a + b;
      case "-":
        return a - b;
      case "*":
        return a * b;
      case "/":
        return a / b;
    }
    return 0;
  }
}
