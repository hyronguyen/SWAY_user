import 'package:flutter/material.dart';

class TripTracking extends StatefulWidget {
  @override
  _TripTrackingState createState() => _TripTrackingState();
}

class _TripTrackingState extends State<TripTracking> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Tracking'),
      ),
      body: Center(
        child: Text('Tracking your trip...'),
      ),
    );
  }
}