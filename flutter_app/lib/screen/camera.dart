import 'package:flutter/material.dart';
import 'package:flutter_app/config.dart';

class CameraScreen extends StatelessWidget {

  // Remove /api and change port to 5001
  final String streamUrl =
      "${Config.baseUrl.replaceAll('/api', '').replaceAll(':5000', ':5001')}/video";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Live Camera Feed")),

      body: Column(
        children: [
          Expanded(
            child: Image.network(
              streamUrl,
              fit: BoxFit.cover,

              // 🔥 Better loading UI
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Center(child: CircularProgressIndicator());
              },

              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    "⚠️ Unable to load stream\nCheck IP & server",
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 10),

          Text(
            "Live Feed from Laptop Camera",
            style: TextStyle(fontSize: 16),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }
}