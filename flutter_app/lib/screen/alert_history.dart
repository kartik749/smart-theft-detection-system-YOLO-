import 'package:flutter/material.dart';
import 'package:flutter_app/theme/theme.dart';
import 'package:flutter_app/widgets/glass_card.dart';
import 'package:flutter_app/config.dart';
import '../service/api_service.dart';

class AlertHistoryScreen extends StatefulWidget {
  @override
  _AlertHistoryScreenState createState() => _AlertHistoryScreenState();
}

class _AlertHistoryScreenState extends State<AlertHistoryScreen> {
  List alerts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAlerts();
  }

  // Fetch alerts from backend
  void fetchAlerts() async {
    List data = await ApiService.getAlerts();

    setState(() {
      alerts = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Alert History")),

      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : alerts.isEmpty
                ? Center(
                    child: Text(
                      "No Alerts Found",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: alerts.length,
                    itemBuilder: (context, index) {
                      final alert = alerts[index];

                      return Padding(
                        padding: EdgeInsets.all(10),
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🔥 Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  "${Config.baseUrl.replaceAll('/api', '')}/${alert['imagePath']}",
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 180,
                                      color: Colors.black26,
                                      child: Center(
                                        child: Text(
                                          "Image not available",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              SizedBox(height: 10),

                              // 🔥 Status
                              Text(
                                "🚨 Motion Detected",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 5),

                              // 🔥 Time
                              Text(
                                alert['createdAt'] ?? '',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}