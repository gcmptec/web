import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    return web; // Web-only deployment
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAIa0maBQvJiJiFhroOEdBmlpXcSmjPZgs',
    appId: '1:1006466693807:web:d3d682e2e5479fa87bf25a',
    messagingSenderId: '1006466693807',
    projectId: 'gcmpvoice',
    authDomain: 'gcmpvoice.firebaseapp.com',
    storageBucket: 'gcmpvoice.firebasestorage.app',
    measurementId: 'G-78ZDRN7SC4',
  );
}
