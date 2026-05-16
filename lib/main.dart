import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'seat_screen.dart';
import 'admin_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background message: ${message.notification?.title}");
}


Future<void> initNotifications() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;


  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print("Permission: ${settings.authorizationStatus}");

  // ✅ Get device token
  String? token = await messaging.getToken();
  print("🔥 DEVICE TOKEN: $token");

  // ✅ Save token in Firestore
  if (token != null) {
    await FirebaseFirestore.instance.collection('users').doc(token).set({
      "token": token,
    });
  }

  // ✅ Foreground notification listener
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Foreground message: ${message.notification?.title}");
  });
}

/// 🔥 MAIN FUNCTION
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ✅ Background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ Initialize all notification setup
  await initNotifications();

  runApp(const HackprixApp());
}

/// 🔥 APP ROOT
class HackprixApp extends StatelessWidget {
  const HackprixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hackprix',
      theme: ThemeData.dark(),
      home: DashboardScreen(),
    );
  }
}

/// 🔥 DASHBOARD SCREEN
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Hackprix"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('seats').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var seats = snapshot.data!.docs;

          int totalSeats = seats.length;
          int occupied = seats.where((s) => s['status'] == 'occupied').length;
          int available = seats.where((s) => s['status'] == 'available').length;

          Set teams = {};
          for (var seat in seats) {
            if (seat.data().containsKey('team')) {
              teams.add(seat['team']);
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6A00F4), Color(0xFF00D4FF)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      "Hackprix 2026",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    statCard("Total", totalSeats),
                    statCard("Occupied", occupied),
                    statCard("Available", available),
                    statCard("Teams", teams.length),
                  ],
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      buildCard("Seat Allotment", context),
                      buildCard("Schedule", context),
                      buildCard("Notifications", context),
                      buildCard("Admin Panel", context),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildCard(String title, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == "Seat Allotment") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SeatScreen()),
          );
        } else if (title == "Admin Panel") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminScreen()),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(child: Text(title)),
      ),
    );
  }

  Widget statCard(String title, int value) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
