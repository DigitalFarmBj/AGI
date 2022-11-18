
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'validator.dart';

class InputValidatorPage extends StatefulWidget {
  const InputValidatorPage(
      {Key? key,
      required this.title,
      required this.decoration,
      required this.textStyle,
      required this.submitText,
      required this.keyboardType,
      required this.submitValidator,
      required this.onSubmit,
      required this.textAlign,
      required this.inputFormatter})
      : super(key: key);
  final String title;
  final InputDecoration decoration;
  final TextStyle textStyle;
  final TextAlign textAlign;

  final String submitText;
  final TextInputType keyboardType;
  final TextInputFormatter inputFormatter;
  final StringValidator submitValidator;
  final ValueChanged<String> onSubmit;

  @override
  State<InputValidatorPage> createState() => _InputValidatorPageState();
}

class _InputValidatorPageState extends State<InputValidatorPage> {
  FocusNode _focusNode = FocusNode();
  String _value = "";
  void submit() async {
    bool valid = widget.submitValidator.isValid(_value);
    if (valid) {
      _focusNode.unfocus();
      widget.onSubmit(_value);
    } else {
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 24.0),
        ),
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildTextField() {
    return TextField(
      decoration: widget.decoration,
      style: widget.textStyle,
      textAlign: widget.textAlign,
      keyboardType: widget.keyboardType,
      autofocus: true,
      textInputAction: TextInputAction.done,
      inputFormatters: [widget.inputFormatter],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 80.0),
          child: _buildTextField(),
        ),
        Expanded(child: Container()),
        //_buildDoneButton(context),
      ],
    );
  }
}
