import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkProvider with ChangeNotifier {
  bool _isConnected = true;
  bool get isConnected => _isConnected;
  bool _isNavigatingToDownloads = false;


  late StreamSubscription _subscription;
  bool get isNavigatingToDownloads => _isNavigatingToDownloads;

  NetworkProvider() {
    _monitorNetwork();
  }

  void setNavigatingToDownloads(bool value) {
    _isNavigatingToDownloads = value;
    notifyListeners();
  }

  void _monitorNetwork() {
    _subscription = Connectivity().onConnectivityChanged.listen((result) async {
      bool connected = result.isNotEmpty &&
          result.first != ConnectivityResult.none &&
          await InternetConnection().hasInternetAccess;

      if (connected != _isConnected) {
        _isConnected = connected;
        notifyListeners();
      }
    });
  }

  Future<void> checkConnection() async {
    final connectivity = await Connectivity().checkConnectivity();
    bool connected = connectivity.isNotEmpty &&
        connectivity.first != ConnectivityResult.none &&
        await InternetConnection().hasInternetAccess;

    _isConnected = connected;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
