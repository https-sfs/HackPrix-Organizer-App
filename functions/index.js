const admin = require("firebase-admin");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");

admin.initializeApp();

const categoryTitles = {
  general: "General Update",
  food: "Food Update",
  mentoring: "Mentoring Update",
  workshop: "Workshop Update",
  results: "Results Update",
  emergency: "Emergency Alert",
  transport: "Transport Update",
};

exports.sendNotification = onDocumentCreated(
    "notifications/{notificationId}",
    async (event) => {
      const notification = event.data.data();
      const category = notification.category || "general";

      const usersSnapshot = await admin.firestore()
          .collection("users")
          .get();

      const tokens = [];

      usersSnapshot.forEach((doc) => {
        const token = doc.data().fcmToken;
        if (token) {
          tokens.push(token);
        }
      });

      if (tokens.length === 0) {
        console.log("No FCM tokens found");
        return;
      }

      const message = {
        notification: {
          title: categoryTitles[category] || categoryTitles.general,
          body: notification.message,
        },
        data: {
          category: category,
          message: notification.message,
          title: categoryTitles[category] || categoryTitles.general,
        },
        tokens: tokens,
      };

      const response = await admin.messaging()
          .sendEachForMulticast(message);

      console.log(
          `Sent ${response.successCount} notifications successfully`,
      );
    },
);
