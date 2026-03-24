import 'package:fanbae/pages/splash.dart';
import 'package:fanbae/utils/app_gate_service.dart';
import 'package:fanbae/utils/color.dart';
import 'package:flutter/material.dart';

class AppUpdateScreen extends StatelessWidget {
  const AppUpdateScreen({super.key, required this.decision});

  final AppGateDecision decision;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 88,
                    width: 88,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0EB1FC).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.system_update_alt_rounded,
                      color: Color(0xFF0EB1FC),
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    decision.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    AppGateService.buildScreenMessage(decision),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xffcfd6ea),
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        await AppGateService.openUpdate(decision.updateUrl);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorPrimary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(decision.updateButtonLabel),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Splash(),
                        ),
                      );
                    },
                    child: const Text(
                      'I have updated, check again',
                      style: TextStyle(color: Color(0xffcfd6ea)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
