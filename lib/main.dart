import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Replace with your design screen size
      builder: (_, child) {
        return MaterialApp(
          home: HomePage(),
          debugShowCheckedModeBanner: false,
        );
      },
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
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator', style: TextStyle(fontSize: 28.sp, color: Colors.black)),
      ),
      body: Column(
        children: [
          // Display area (1 part)
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(left: w * 0.04, right: w * 0.04),
              alignment: Alignment.bottomRight,
              child: TextField(
                controller: _controller,
                showCursor: false,
                readOnly: true, // Makes it uneditable by typing
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 55.sp,
                  color: Colors.black,
                ),
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
          ),

          // Button area (3 parts)
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(left: w * 0.04, right: w * 0.04),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: w * 0.02),
                    child: Row(
                      children: <Widget>[
                        OutlinedButton(
                          onPressed: () => btnClicked("<"),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.all(w * 0.06),
                            backgroundColor: Colors.black38,
                            foregroundColor: Colors.white,
                          ),
                          child: Icon(
                            Icons.backspace_outlined,
                            size: 28.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: h * 0.02),
                  buttonRow(["7", "8", "9", "+"], w),
                  SizedBox(height: h * 0.02),
                  buttonRow(["4", "5", "6", "-"], w),
                  SizedBox(height: h * 0.02),
                  buttonRow(["1", "2", "3", "*"], w),
                  SizedBox(height: h * 0.02),
                  buttonRow(["C", "0", "=", "/"], w),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buttonRow(List<String> buttons, double w) {
    return Padding(
      padding: EdgeInsets.only(left: w * 0.001),
      child: Row(
        children: buttons.map((btnText) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: w * 0.022),
              child: OutlinedButton(
                onPressed: () => btnClicked(btnText),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.all(w * 0.05),
                  backgroundColor: Colors.black38,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  btnText,
                  style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void btnClicked(String btnText) {
    // Check if the input is an operator
    bool isOperator = btnText == "+" || btnText == "-" || btnText == "*" || btnText == "/";

    // If the button is an operator and the current text is empty, show an error
    if (isOperator && text.isEmpty) {
      return;
    }

    // If the button is "C", clear the text and expression
    if (btnText == "C") {
      text = "";
      expression.clear();
      setState(() {
        _controller.text = text;
      });
    }
    // If the button is "<", remove the last character
    else if (btnText == "<") {
      if (text.isNotEmpty) {
        setState(() {
          text = text.substring(0, text.length - 1); // Remove last character
          _controller.text = text;
          if (expression.isNotEmpty) {
            expression.removeLast(); // Remove last entry from expression
          }
        });
      }
    }
    // If the button is "=", calculate the result
    else if (btnText == "=") {
      calculateResult();
    }
    // For other buttons (numbers or operators)
    else {
      // If the last character is an operator, replace it with the new operator
      if (isOperator && text.isNotEmpty && (text.endsWith("+") || text.endsWith("-") || text.endsWith("*") || text.endsWith("/"))) {
        text = text.substring(0, text.length - 1) + btnText; // Replace last operator
        expression[expression.length - 1] = btnText; // Update the expression
      }
      // If the last character is not an operator, add the new button text to the expression
      else {
        expression.add(btnText);
        text += btnText; // Append button text to the displayed text
      }
      setState(() {
        _controller.text = text; // Update the displayed text in the TextField
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
        // Check if the result is infinite
        if (eval.isInfinite) {
          setState(() {
            text = "Error";
            _controller.text = text;
          });
          Future.delayed(Duration(milliseconds: 200), () {
            setState(() {
              text = "";
              _controller.text = text;
            });
          });
          // Display "Error" for infinite values
        }else {
          // Convert to string, then remove unnecessary trailing zeros and the decimal point if not needed
          text = eval.toStringAsFixed(15).replaceAll(
              RegExp(r'([.]*0+)(?!.*\d)'), '');
          if (text.endsWith('.')) {
            text = text.substring(0,
                text.length - 1); // Remove the decimal point if it's at the end
          }
        }
        _controller.text = text;
        expression = [text];
      });
    } catch (e) {
      setState(() {
        text = "Error";
        _controller.text = text;
      });
      Future.delayed(Duration(milliseconds: 200), () {
        setState(() {
          text = "";
          _controller.text = text;
        });
      });
      expression.clear();
    }
  }
}
