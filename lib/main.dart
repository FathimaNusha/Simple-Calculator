import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

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
  List<String> expression = []; // Store the expression

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;


    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator', style: TextStyle(fontSize: 28)),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: h * 0.03),
              alignment: Alignment.topRight,
              height: h * 0.20,
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 55,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: h * 0.1),

            // Delete button row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget> [OutlinedButton(
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
            SizedBox(height: h * 0.02),
            buttonRow(["9", "8", "7", "+"]),
            SizedBox(height: h * 0.02),
            buttonRow(["6", "5", "4", "-"]),
            SizedBox(height: h * 0.02),
            buttonRow(["3", "2", "1", "*"]),
            SizedBox(height: h * 0.02),
            buttonRow(["C", "0", "=", "/"]),
          ],
        ),
      ),
    );
  }

  Widget buttonRow(List<String> buttons) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: buttons.map((btnText) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0), // Horizontal space between buttons
              child: OutlinedButton(
                onPressed: () => btnClicked(btnText),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.all(20),
                  backgroundColor: Colors.black38,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  btnText,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void btnClicked(String btnText) {
    if (text.length >= 24 && btnText != "C" && btnText != "<" && btnText != "=") {
      // Show popup message when the maximum length is reached
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Can only enter up to 24 digits."),
          duration: Duration(seconds: 2),
        ),
      );
      return; // Prevent further input if 24 characters reached
    }

    if ((btnText == "+" || btnText == "-" || btnText == "*" || btnText == "/") && text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Invalid Input."),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (btnText == "C") {
      text = "";
      expression.clear();
      setState(() {
        text = "";
      });
    } else if (btnText == "<") {
      if (text.isNotEmpty) {
        setState(() {
          text = text.substring(0, text.length - 1); // Remove last character
          if (expression.isNotEmpty) {
            expression.removeLast(); // Remove last entry from expression
          }
        });
      }
    } else if (btnText == "=") {
      calculateResult();
    } else {
      expression.add(btnText);
      setState(() {
        text += btnText;
      });
    }
  }

  void calculateResult() {
    try {
      String expressionStr = expression.join();
      Parser parser = Parser();
      Expression exp = parser.parse(expressionStr);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      setState(() {
        text = eval.toStringAsPrecision(15); // Limit the precision for display
        expression = [text];
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
}
