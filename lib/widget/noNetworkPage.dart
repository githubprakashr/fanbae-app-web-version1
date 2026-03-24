import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fanbae/main.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:provider/provider.dart';
import '../pages/mydownloads.dart';
import '../provider/networkProvider.dart';
import '../utils/constant.dart';
import '../utils/sharedpre.dart';

class NoInternetSheet extends StatefulWidget {
  const NoInternetSheet({super.key});

  @override
  State<NoInternetSheet> createState() => _NoInternetSheetState();
}

class _NoInternetSheetState extends State<NoInternetSheet> {
  bool _isLoading = false;
  bool showDownloads = false;
  final SharedPre sharedpre = SharedPre();

  @override
  void initState() {
    super.initState();
    _loadIsBuy();
  }

  Future<void> _loadIsBuy() async {
    print(await sharedpre.read("userIsBuy") ?? '0');
    final storedIsBuy = await sharedpre.read("userIsBuy") ?? '0';
    print('storedIsBuy :$storedIsBuy');
    if (mounted) {
      setState(() {
        showDownloads = storedIsBuy == '1';
      });
    }
    print(
        "✅ Loaded isBuy from shared pref: $storedIsBuy → showDownloads: $showDownloads");
  }

  Future<void> _retryConnection(BuildContext context) async {
    setState(() => _isLoading = true);
    final networkProvider =
        Provider.of<NetworkProvider>(context, listen: false);
    await networkProvider.checkConnection();
    if (networkProvider.isConnected && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Still no internet connection")),
      );
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _openDownloads() {
    print('Opening downloads page...');
    final networkProvider =
        Provider.of<NetworkProvider>(context, listen: false);
    networkProvider.setNavigatingToDownloads(true);
    if (Navigator.canPop(context)) Navigator.pop(context);
    navigatorKey.currentState
        ?.push(
          MaterialPageRoute(
            settings: const RouteSettings(name: 'MyDownloads'),
            builder: (_) => const MyDownloads(),
          ),
        )
        .then((_) => networkProvider.setNavigatingToDownloads(false));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: black,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, color: Colors.red, size: 100),
              const SizedBox(height: 20),
              const Text(
                "No Internet Connection",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Please check your connection and try again.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 48,
                width: 160,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : () => _retryConnection(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Retry",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                ),
              ),
              if (showDownloads) ...[
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: _openDownloads,
                  child: const Text(
                    'View Downloads',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
