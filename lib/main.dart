import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:taskapp/views/screens/home_screen.dart';
import 'package:taskapp/services/storage_service.dart';
import 'package:taskapp/services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize local storage
  final storageService = StorageService();
  await storageService.init();

  // Initialize sync service
  final syncService = SyncService(
    storageService: storageService,
    firestore: FirebaseFirestore.instance,
    connectivity: Connectivity(),
  );
  syncService.init();
  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<SyncService>.value(value: syncService),
        Provider<Uuid>.value(value: Uuid()),
      ],
      child: SafetyApp(),
    ),
  );
}

class SafetyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safety App',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6750A4),
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: const Color(0xFFF6F6F6),
        useMaterial3: true,

      ),
      home: HomeScreen(
        storageService: StorageService(),
        syncService: SyncService(
          storageService: StorageService(),
          firestore: FirebaseFirestore.instance,
          connectivity: Connectivity(),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

}