import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

List months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

class DateObject extends StatefulWidget {
  const DateObject({super.key});

  @override
  State<DateObject> createState() => _DateObjectState();
}

class _DateObjectState extends State<DateObject> {
  final DateTime now = DateTime.now();

  String returnMonth() {
    var currentMth = now.month;
    months[currentMth - 1];
    return months[currentMth - 1];
  }

  String updatedValue() {
    var yearData = DateFormat('yyyy/MM/dd').format(DateTime.parse('${now.year}-${now.month}-${now.day}'));
    var timeData = DateFormat.jm().format(DateFormat('hh:mm').parse('${now.hour}:${now.minute}'));
    String data = "$yearData $timeData";
    return data;
  }

  @override
  void initState() {
    updatedValue();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("${returnMonth()} ${now.day}", style: kDateStyle),
        Text(
          'Updated ${updatedValue()}',
          style: kAppbarText.copyWith(fontSize: 16, fontWeight: FontWeight.w300),
        ),
      ],
    );
  }
}
