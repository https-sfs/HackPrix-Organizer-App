import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  // 🔥 RESET ALL SEATS
  Future<void> resetSeats(BuildContext context) async {
    var snapshot = await FirebaseFirestore.instance.collection('seats').get();

    for (var doc in snapshot.docs) {
      await FirebaseFirestore.instance.collection('seats').doc(doc.id).update({
        "status": "available",
        "team": FieldValue.delete(),
      });
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("All seats reset")));
  }

  // 🔥 CONFIRM RESET
  void confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Reset All Seats?"),
          content: Text("This will clear ALL seat data."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await resetSeats(context);
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  // 🔥 SEND NOTIFICATION
  void sendNotification(BuildContext context) {
    TextEditingController title = TextEditingController();
    TextEditingController message = TextEditingController();

    String type = "info";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Send Notification"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: title,
                    decoration: InputDecoration(labelText: "Title"),
                  ),
                  TextField(
                    controller: message,
                    decoration: InputDecoration(labelText: "Message"),
                  ),
                  SizedBox(height: 10),
                  DropdownButton<String>(
                    value: type,
                    items: ["info", "warning", "urgent"]
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        type = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (title.text.isEmpty || message.text.isEmpty) return;

                    await FirebaseFirestore.instance
                        .collection('notifications')
                        .add({
                          "title": title.text,
                          "message": message.text,
                          "type": type,
                          "timestamp": FieldValue.serverTimestamp(),
                        });

                    Navigator.pop(context);
                  },
                  child: Text("Send"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 🔥 STAT BOX UI
  Widget statBox(String title, int value) {
    return Container(
      width: 80,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Panel"), backgroundColor: Colors.black),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('seats').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var seats = snapshot.data!.docs;

            int total = seats.length;
            int occupied = seats.where((s) => s['status'] == 'occupied').length;
            int available = seats.where((s) => s['status'] == 'available').length;

            Set teams = {};
            for (var seat in seats) {
              if (seat.data().containsKey('team')) {
                teams.add(seat['team']);
              }
            }

            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).padding.bottom + 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 LIVE STATS
                  Text(
                    "Live Stats",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      statBox("Total", total),
                      statBox("Occupied", occupied),
                      statBox("Available", available),
                      statBox("Teams", teams.length),
                    ],
                  ),

                  SizedBox(height: 30),

                  // 🔥 CONTROLS
                  Text(
                    "Controls",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => confirmReset(context),
                    child: Text("Reset All Seats"),
                  ),

                  SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: () {
                      sendNotification(context);
                    },
                    child: Text("Send Notification"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
