import 'package:flutter/material.dart';
import 'package:fanbae/utils/pusher_beams_service.dart';

/// Test screen for Pusher Beams notifications
/// Run this to verify your Pusher Beams setup
class PusherBeamsTestScreen extends StatefulWidget {
  const PusherBeamsTestScreen({Key? key}) : super(key: key);

  @override
  State<PusherBeamsTestScreen> createState() => _PusherBeamsTestScreenState();
}

class _PusherBeamsTestScreenState extends State<PusherBeamsTestScreen> {
  String _status = 'Not initialized';
  List<String> _interests = [];

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      final interests = await PusherBeamsService().getInterests();
      setState(() {
        _interests = interests?.toList() ?? [];
        _status = 'Initialized ✅';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _subscribeToHello() async {
    try {
      await PusherBeamsService().addInterest('hello');
      await _checkStatus();
      _showMessage('Subscribed to "hello" channel');
    } catch (e) {
      _showMessage('Error: $e');
    }
  }

  Future<void> _subscribeToGeneral() async {
    try {
      await PusherBeamsService().addInterest('general');
      await _checkStatus();
      _showMessage('Subscribed to "general" channel');
    } catch (e) {
      _showMessage('Error: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusher Beams Test'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Instance Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Instance ID: ${PusherBeamsService.instanceId}'),
                    const SizedBox(height: 8),
                    Text('Status: $_status'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subscribed Interests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_interests.isEmpty)
                      const Text('No interests subscribed yet')
                    else
                      ..._interests.map((interest) => Chip(
                            label: Text(interest),
                            backgroundColor: Colors.green.shade100,
                          )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _subscribeToHello,
              icon: const Icon(Icons.add),
              label: const Text('Subscribe to "hello"'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _subscribeToGeneral,
              icon: const Icon(Icons.add),
              label: const Text('Subscribe to "general"'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _checkStatus,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Status'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📱 Testing Instructions:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('1. Make sure you\'re subscribed to "hello"'),
                  Text('2. Go to Pusher Beams Dashboard'),
                  Text('3. Click "Debug Console"'),
                  Text('4. Select "Publish to Interests"'),
                  Text('5. Enter "hello" as the interest'),
                  Text('6. Send a test notification'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
