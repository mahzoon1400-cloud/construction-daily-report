import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shamsi_date/shamsi_date.dart';

void main() => runApp(const App());

const Map<int, int> blocks = {
  1: 14, 2: 12, 3: 20, 4: 18,
  5: 20, 6: 24, 7: 12, 8: 21,
};

const activities = [
  'نماکاری', 'دیوارچینی', 'سرامیک‌کاری', 'گچ‌کاری',
  'کاشی‌کاری', 'سنگ‌کاری', 'نقاشی', 'کناف',
  'تأسیسات مکانیکی', 'تأسیسات برقی', 'عایق‌کاری', 'سایر',
];

String today() {
  final j = Jalali.now();
  return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0757A6)),
        scaffoldBackgroundColor: const Color(0xFFF3F6FB),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: Home(),
      ),
    );
  }
