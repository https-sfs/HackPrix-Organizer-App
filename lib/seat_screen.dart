import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SeatScreen extends StatelessWidget {
  const SeatScreen({super.key});

  // 🔥 Dialog to assign team
  void assignTeam(BuildContext context) {
    TextEditingController teamController = TextEditingController();
    TextEditingController sizeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Assign Team"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: teamController,
                decoration: InputDecoration(labelText: "Team Name"),
              ),
              TextField(
                controller: sizeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Team Size"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String teamName = teamController.text;

                if (teamName.isEmpty || sizeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please fill all fields")),
                  );
                  return;
                }

                int? size = int.tryParse(sizeController.text);

                if (size == null || size <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Enter valid team size")),
                  );
                  return;
                }

                await assignSeats(context, teamName, size);

                Navigator.pop(context);
              },
              child: Text("Assign"),
            ),
          ],
        );
      },
    );
  }

  // 🔥 Core Logic: Adjacent seat allocation
  Future<void> assignSeats(
    BuildContext context,
    String teamName,
    int size,
  ) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('seats')
        .orderBy(FieldPath.documentId)
        .get();

    var seats = snapshot.docs;

    List<QueryDocumentSnapshot> availableSeats = [];

    // Step 1: filter available seats
    for (var seat in seats) {
      if (seat['status'] == 'available') {
        availableSeats.add(seat);
      }
    }

    // Step 2: find consecutive seats
    List<QueryDocumentSnapshot> selectedSeats = [];

    for (int i = 0; i <= availableSeats.length - size; i++) {
      selectedSeats.clear();

      for (int j = 0; j < size; j++) {
        String currentId = availableSeats[i + j].id;
        String expectedId =
            "A${int.parse(availableSeats[i].id.substring(1)) + j}";

        if (currentId == expectedId) {
          selectedSeats.add(availableSeats[i + j]);
        } else {
          break;
        }
      }

      if (selectedSeats.length == size) break;
    }

    // ❌ No adjacent seats found
    if (selectedSeats.length < size) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No adjacent seats available")),
      );
      return;
    }

    // ✅ Assign seats
    for (var seat in selectedSeats) {
      await FirebaseFirestore.instance
          .collection('seats')
          .doc(seat.id)
          .update({
        "status": "occupied",
        "team": teamName,
        "timestamp": FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Seat Allotment")),
      body: Column(
        children: [
          // 🔥 Assign button
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                assignTeam(context);
              },
              child: Text("Assign Team"),
            ),
          ),

          // 🔥 Seats Grid
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('seats')
                  .orderBy(FieldPath.documentId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var seats = snapshot.data!.docs;

                return GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: seats.length,
                  itemBuilder: (context, index) {
                    var seat = seats[index];
                    String status = seat['status'];

                    Color color;
                    if (status == "available") {
                      color = Colors.green;
                    } else if (status == "reserved") {
                      color = Colors.orange;
                    } else {
                      color = Colors.red;
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            seat.id,
                            style: TextStyle(color: Colors.white),
                          ),

                          // 🔥 Show team name
                          if (seat.data().containsKey('team'))
                            Text(
                              seat['team'],
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}