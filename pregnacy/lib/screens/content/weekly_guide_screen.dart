import 'package:flutter/material.dart';

class WeeklyGuideScreen extends StatelessWidget {
  final int week;

  const WeeklyGuideScreen({super.key, required this.week});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Week $week Guide')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Center(
          // TODO: load medically reviewed weekly guide via ContentService.getWeeklyGuide
          child: Text('Weekly Guide — Coming Soon'),
        ),
      ),
    );
  }
}
