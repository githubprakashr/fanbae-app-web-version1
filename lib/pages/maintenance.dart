import 'package:fanbae/pages/splash.dart';
import 'package:fanbae/utils/app_gate_service.dart';
import 'package:fanbae/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key, required this.decision});

  final AppGateDecision decision;

  Future<void> _openContact() async {
    final String raw = decision.supportContact.trim();
    if (raw.isEmpty) return;
    final String urlString =
        raw.contains('@') && !raw.startsWith('http') ? 'mailto:$raw' : raw;
    final Uri? uri = Uri.tryParse(urlString);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/Fanbae_logo_RGB.png',
                      height: 110,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      height: 96,
                      width: 96,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB020).withOpacity(0.16),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.build_circle_outlined,
                        color: Color(0xFFFFB020),
                        size: 52,
                      ),
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
                  if (decision.etaText.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB020).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: Color(0xFFFFB020),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Back by ${decision.etaText}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFFFB020),
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Splash(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorPrimary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Refresh'),
                    ),
                  ),
                  if (decision.supportContact.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton.icon(
                        onPressed: _openContact,
                        icon: Icon(
                          decision.supportContact.contains('@')
                              ? Icons.email_outlined
                              : Icons.open_in_new_rounded,
                          size: 18,
                          color: const Color(0xffcfd6ea),
                        ),
                        label: const Text(
                          'Contact support',
                          style: TextStyle(
                            color: Color(0xffcfd6ea),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
