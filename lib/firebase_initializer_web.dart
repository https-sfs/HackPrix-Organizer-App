import 'package:firebase_core/firebase_core.dart';

Future<void> initializeFirebase() {
  return Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAGF0pe4n9DARa3-h91aZvierWlozsSJbo',
      appId: '1:289441248174:web:hackprix_checkin_web',
      messagingSenderId: '289441248174',
      projectId: 'hackprix-checkin',
      authDomain: 'hackprix-checkin.firebaseapp.com',
      storageBucket: 'hackprix-checkin.firebasestorage.app',
    ),
  );
}
