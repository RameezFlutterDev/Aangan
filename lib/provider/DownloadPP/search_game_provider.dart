import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xupstore/services/firestore_dashboard_services.dart';

class GameProvider extends ChangeNotifier {
  final FirestoreDashboardServices _firestoreServices =
      FirestoreDashboardServices();
  String _searchQuery = '';
  List<Map<String, dynamic>> _games = [];
  bool _isLoading = true;
  StreamSubscription<List<Map<String, dynamic>>>? _gamesSubscription;

  String get searchQuery => _searchQuery;
  List<Map<String, dynamic>> get games => _games;
  bool get isLoading => _isLoading;

  GameProvider() {
    // Initial fetch of games without a search query
    _subscribeToGamesStream();
  }

  // Method to update the search query and fetch new results
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _subscribeToGamesStream();
  }

  void _subscribeToGamesStream() {
    _isLoading = true;
    notifyListeners();

    // Cancel any existing stream subscription
    _gamesSubscription?.cancel();

    // Start listening to the games stream with the current search query
    _gamesSubscription =
        _firestoreServices.searchGames(_searchQuery).listen((gamesList) {
      _games = gamesList;
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _gamesSubscription
        ?.cancel(); // Clean up the subscription when provider is disposed
    super.dispose();
  }
}
