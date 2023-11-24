import 'package:flutter/material.dart';

const kAppbarText = TextStyle(fontWeight: FontWeight.w500, fontSize: 17.0, height: 1.4, color: Colors.white);
const kForecastPanel = TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0, height: 1.4, color: Colors.white);

const kDateStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: 36.0, height: 1.4, color: Colors.white);

const kTempStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: 120, color: Colors.white);

const kLinearGradientPurple = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xff391d4c), Color(0xff2c236d), Color(0xff391d4c)],
    stops: [0.0, 0.5, 1.0]);
