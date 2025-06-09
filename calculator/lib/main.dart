// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

//import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'dart:math' as math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CalculatorState(),
      child: MaterialApp(
        title: 'Calculator',
        theme: ThemeData.dark(),
        home: MyCalculator(),
        debugShowCheckedModeBanner: false,
      ),
      );
  }
}



class CalculatorState extends ChangeNotifier {
  String _display = '0';
  String _previousDisplay = '';
  double _num1 = 0;
  double _num2 = 0;
  String _operator = '';
  bool _previousDisplayVisible = false;
  bool _displayVisible = false;
  bool _num = false; // false means it lies on _num1, _num2 otherwise
  // bool _calculated = false; //used to check if the last operation was "="

  String get display => _display;
  String get previousDisplay => _previousDisplay;
  bool get displayVisible => _displayVisible;

  void _onButtonPressed(String buttonText) {
    //del enable when the button pressed is not = 
    //and the display is not empty
    _displayVisible = true;
    if (_previousDisplayVisible && buttonText != '=') {
      _clearMem(); //Only clear the memory when the previous display is visible aka have calculated something, else we only care about the current number (num1)
    }
    if (buttonText == 'AC') {
      _clear(); //reset everything
    } else if (buttonText == '+/-') {
      //case when we have -x, it will trigger the - and turn into x
      if (!_num) {
        _display = _toggleSign(_display);
        _num1 = double.parse(_display);
      } else {
        String sub = _format(_num1.toString()) + _operator;
        _display = sub + _toggleSign(_display.substring(sub.length));
      }
    } else if (buttonText == '%') {
      if (!_num) {
        _display = _percentage(_display);
        _num1 = double.parse(_display);
      } else {
        String sub = _format(_num1.toString()) + _operator;
        _display = sub + _percentage(_display.substring(sub.length));
      }
    } else if (['+', '-', '×', '÷'].contains(buttonText)) {
      _setOperator(buttonText);
    } else if (buttonText == '=') {
      _calculate();
    } else if (buttonText == '.') {
      _addDecimal();
    } else if (buttonText == 'Del') {
      //may make a function for it
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _clear();
      }

      if(!['+', '-', '×', '÷'].contains(_display.substring(1))) {
        _num = false;
        _num1 = double.parse(_display);
      } else {
        _num = true;
      }
    } else {
      _addNumber(buttonText);
    }
    notifyListeners();
  }

  void _clear() {
    _display = '0';
    _previousDisplay = '';
    _num1 = 0;
    _num2 = 0;
    _operator = '';
    _previousDisplayVisible = false;
    _displayVisible = false;
    _num = false;
    //notifyListeners();
  }

  void _clearMem() {
    _previousDisplay = '';
    _previousDisplayVisible = false;
    _num = false;
  }

  String _toggleSign( String numString) {
    // it should be something like (-x) instead of -x like at the moment
    //to make it easier, I am gonna just consider change x to -x and reverse
    if (numString != '0') {
        numString = (numString.startsWith('-')) ? numString.substring(1) : '-$numString'; 
      }
    return numString;
  }

  //do the same as the toggle sign - not done
  String _percentage(String string) {
    double value = double.parse(string);
    string = (value / 100).toString();
    string = _format(string);
    return string;                    
  }

  //gonna make it turn to function of 2 num at a time
  //can turn the num and operator into a list (future features)
  void _setOperator(String op) {
    String numString = '';

  if (_display.isNotEmpty && ['+', '-', '×', '÷'].contains(_display[_display.length - 1]) && op == '-') {
    // The last character of _display is an minus operator, we want to check if there is an operator (that is not minus)
    //before it, if so, we keep that, else ignore it
    numString = _display.substring(0, _display.length - 1);
    _num1 = double.parse(numString);
    if (_display[_display.length - 2] == '-') {
      // If the previous operator is also a minus, we ignore it
    } else {
      // Otherwise, we keep the previous operator and add the new one
      numString = _display;
      //_operator = op; dont change operator here
      _display = numString + op;
      //_calculated = false;
      _num = true;
      notifyListeners();   
      return;
    }
  } else if (_display.isNotEmpty && ['+', '-', '×', '÷'].contains(_display[_display.length - 1])) {
    // The last character of _display is an operator, we want to change depend on it
    numString = _display.substring(0, _display.length - 1);
    _num1 = double.parse(numString);
  } else {
    int opIndex = _display[0] == '-' ? (_display.substring(1).indexOf(RegExp(r'[+\-×÷]'))) : _display.indexOf(RegExp(r'[+\-×÷]')); // If the first character is a minus, we ignore it
    numString = opIndex == -1 ? _display : _display.substring(0, opIndex);
    if (_num1 == 0) {
      _num1 = double.parse(numString);
    }
    if (_display.substring(numString.length).length > 1) {
      _num = true;
      _calculate();
      _previousDisplayVisible = false; //Done represent it on the previous display
      _previousDisplay = '';
      numString = _display;
    }
  }
    _operator = op;
    _display = numString + _operator;
    //_calculated = false;
    _num = true;
    notifyListeners();                    
    
  }

  void _calculate() {
    if (_operator.isEmpty) return;
    if (_previousDisplayVisible) {
      // Keep entering the '=' operator
    } else if (_num){
      String temp = _format(_num1.toString()) + _operator;
      _num2 = double.parse(_display.substring(temp.length));
    }
    _display = _format(_num1.toString()) + _operator + _format(_num2.toString());
    double result = 0;
    

    switch (_operator) {
      case '+':
        result = _num1 + _num2;
      case '-':
        result = _num1 - _num2;
      case '×':
        result = _num1 * _num2;
      case '÷':
        if (_num2 != 0) {
          result = _num1 / _num2;
        } else {
          _display = 'Error';
          return;
        }
    }
    _previousDisplay = _display;
    _display = result.toString();
    _num1 = result;
    //_num2 = 0;   
    //_operator = '';
    _display = _format(_display);
    _previousDisplayVisible = true;
    //_calculated = true;
    _num = false;

    notifyListeners();
  }

    void _addNumber(String number) {
    if ( _display == '0') {
      _display = number;
    } else {
      _display += number;
    }
    if (!_num) {
      _num1 = double.parse(_display);
      //print("Num1: $_num1, Num2: $_num2, Operator: $_operator");
    } //have to update _num1 
  }

  // also, the 64-bit double precision problem, still good at the moment 
  void _addDecimal() {
    if (_display.isNotEmpty && !_display[_display.length - 1].contains('.')) { // Check if the last character is not a dot
      _display += '.';
    } else if (_display.isEmpty) {
      _display = '0.'; // If the display is empty, start with 0.
    }
    notifyListeners();
  }

  String _format(String number) {
    double value = double.parse(number);
  // Round to 2 decimal places
  double rounded = double.parse(value.toStringAsFixed(7));
  
  // If it's a whole number, return as integer
  if (rounded == rounded.toInt()) {
    return rounded.toInt().toString();
  }

  return rounded.toStringAsFixed(7).replaceAll(RegExp(r'0*$'), '');
  }
}

class MyCalculator extends StatefulWidget {
  @override
  State<MyCalculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<MyCalculator> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;

    switch (selectedIndex) {
      case 0:
        page = CalculatorButtons();
      case 1:
        // Future feature: Showing history of calculations
        page = Placeholder();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    var mainArea = ColoredBox(
      color: colorScheme.onPrimary,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
        ),
      );

      return Scaffold(
        appBar: AppBar(
          title: Text('Calculator'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16.0),
                alignment: Alignment.bottomRight,
                child: Consumer<CalculatorState>(
                  builder: (context, calculatorState, child) {
                    return Opacity(
                      opacity: 0.5,
                      child: Text(
                        calculatorState.previousDisplay,
                        style: TextStyle(fontSize: 32.0),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16.0),
                alignment: Alignment.centerRight,
                child: Consumer<CalculatorState>(
                  builder: (context, calculatorState, child) {
                    return Text(
                      calculatorState.display,
                      style: TextStyle(fontSize: 64.0),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: mainArea,
            ),
          ],
        ),
      );
  }
}

// Add this widget to represent the calculator buttons
class CalculatorButtons extends StatelessWidget {
  final List<List<String>> buttons = [
    ['AC', '+/-', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6','-' ],
    ['1', '2', '3', '+' ],
    ['Del', '0', '.', '='],
  ];

  @override
  Widget build(BuildContext context) {
    final calculatorState = Provider.of<CalculatorState>(context, listen: false);

    return Column(
      children: buttons.map((row) {
        return Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: row.map((buttonText) {
              return Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      calculatorState._onButtonPressed(buttonText);
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        buttonText,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}