import 'package:flutter/material.dart';
import 'package:flutter_app/theme/theme.dart';
import 'package:flutter_app/widgets/glass_card.dart';
import '../service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  // Logout function
  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(gradient: AppTheme.gradient),
          child: ListView(
            children: [
              DrawerHeader(
                child: Text(
                  "Menu",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              ListTile(
                title: Text("Settings", style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                title: Text("About Us", style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                title: Text("Logout", style: TextStyle(color: Colors.redAccent)),
                onTap: logout,
              ),
            ],
          ),
        ),
      ),

      appBar: AppBar(title: Text("Dashboard")),

      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10),

                    // 🔥 System Status Card
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: GlassCard(
                        child: Column(
                          children: [
                            Text(
                              "System Status",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.security, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  "Monitoring Active",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text(
                              alerts.isNotEmpty
                                  ? "Last alert: ${alerts[0]['createdAt'] ?? ''}"
                                  : "No alerts yet",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 🔥 Grid Options
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _card(context, "Live Camera", '/camera'),
                        _card(context, "Alert History", '/alerts'),
                        _card(context, "Intruder Photos", '/alerts'),
                      ],
                    ),

                    SizedBox(height: 10),

                    // 🔥 Recent Alerts
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Recent Alerts",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: alerts.length > 3 ? 3 : alerts.length,
                      itemBuilder: (context, index) {
                        final alert = alerts[index];

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: GlassCard(
                            child: ListTile(
                              leading: Icon(Icons.warning, color: Colors.red),
                              title: Text(
                                "Motion Detected",
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                alert['createdAt'] ?? '',
                                style: TextStyle(color: Colors.white70),
                              ),
                              onTap: () {
                                Navigator.pushNamed(context, '/alerts');
                              },
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _card(BuildContext context, String title, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: GlassCard(
          child: Center(
            child: Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}