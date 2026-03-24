import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:url_launcher/url_launcher.dart';

class CookieSplashPage extends StatefulWidget {
  final VoidCallback onConsentComplete;

  const CookieSplashPage({
    super.key,
    required this.onConsentComplete,
  });

  @override
  State<CookieSplashPage> createState() => _CookieSplashPageState();
}

class _CookieSplashPageState extends State<CookieSplashPage> {
  bool _showManageOptions = false;
  static const String _consentKey = 'cookie_consent_given';

  // Cookie preferences
  bool _essentialCookies = true;
  bool _analyticsCookies = false;
  bool _marketingCookies = false;
  bool _functionalCookies = false;

  @override
  void initState() {
    super.initState();
    _checkExistingConsent();
  }

  Future<void> _checkExistingConsent() async {
    // Only show on web
    if (!kIsWeb) {
      widget.onConsentComplete();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final hasConsent = prefs.getBool(_consentKey) ?? false;

    if (hasConsent) {
      // User already gave consent, proceed to app
      widget.onConsentComplete();
    }
    // If no consent, this page stays visible
  }

  Future<void> _saveConsent({
    required bool analytics,
    required bool marketing,
    required bool functional,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, true);
    await prefs.setBool('cookie_analytics', analytics);
    await prefs.setBool('cookie_marketing', marketing);
    await prefs.setBool('cookie_functional', functional);

    widget.onConsentComplete();
  }

  Future<void> _acceptAll() async {
    await _saveConsent(
      analytics: true,
      marketing: true,
      functional: true,
    );
  }

  Future<void> _rejectAll() async {
    await _saveConsent(
      analytics: false,
      marketing: false,
      functional: false,
    );
  }

  Future<void> _savePreferences() async {
    await _saveConsent(
      analytics: _analyticsCookies,
      marketing: _marketingCookies,
      functional: _functionalCookies,
    );
  }

  Future<void> _openCookiePolicy() async {
    String baseUrl = Constant().baseurl.replaceAll('/api/', '/');
    final Uri url = Uri.parse('${baseUrl}pages/cookie');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Fail silently
    }
  }

  Future<void> _openCookieConsentBanner() async {
    String baseUrl = Constant().baseurl.replaceAll('/api/', '/');
    final Uri url = Uri.parse('${baseUrl}pages/cookie-consent-banner');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Fail silently
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: Center(
        child: Container(
          width: isWideScreen ? 500 : MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: colorPrimaryDark,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Icon(
                  Icons.cookie,
                  size: 60,
                  color: colorPrimary,
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  'We Value Your Privacy',
                  style: TextStyle(
                    color: white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Description
                Text(
                  'We use cookies to enhance your browsing experience, serve personalized content, and analyze our traffic.',
                  style: TextStyle(
                    color: white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Content
                if (!_showManageOptions) ...[
                  // Main view with buttons
                  // View Policy links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _openCookiePolicy,
                        child: Text(
                          'View Our Cookie Policy',
                          style: TextStyle(
                            color: colorPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '|',
                          style: TextStyle(
                            color: white.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _openCookieConsentBanner,
                        child: Text(
                          'Cookie Consent Banner',
                          style: TextStyle(
                            color: colorPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Accept All button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _acceptAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorPrimary,
                        foregroundColor: white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Accept All Cookies',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Reject All button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _rejectAll,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: white,
                        side: BorderSide(
                          color: white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Reject All',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Manage Preferences button
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showManageOptions = true;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.settings, color: colorPrimary, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Customize Preferences',
                          style: TextStyle(
                            color: colorPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Manage preferences view
                  Text(
                    'Cookie Preferences',
                    style: TextStyle(
                      color: white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choose which cookies you want to allow.',
                    style: TextStyle(
                      color: white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _buildCookieOption(
                    title: 'Essential Cookies',
                    description: 'Required for website to function',
                    value: _essentialCookies,
                    enabled: false,
                    onChanged: null,
                  ),
                  const SizedBox(height: 12),
                  _buildCookieOption(
                    title: 'Analytics Cookies',
                    description: 'Help us understand user behavior',
                    value: _analyticsCookies,
                    enabled: true,
                    onChanged: (value) {
                      setState(() => _analyticsCookies = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildCookieOption(
                    title: 'Marketing Cookies',
                    description: 'Show personalized advertisements',
                    value: _marketingCookies,
                    enabled: true,
                    onChanged: (value) {
                      setState(() => _marketingCookies = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildCookieOption(
                    title: 'Functional Cookies',
                    description: 'Remember your preferences',
                    value: _functionalCookies,
                    enabled: true,
                    onChanged: (value) {
                      setState(() => _functionalCookies = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  // Save preferences button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _savePreferences,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorPrimary,
                        foregroundColor: white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save Preferences',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Back button
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showManageOptions = false;
                      });
                    },
                    child: Text(
                      'Back',
                      style: TextStyle(
                        color: white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCookieOption({
    required String title,
    required String description,
    required bool value,
    required bool enabled,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorPrimaryDark.withOpacity(0.6),
        border: Border.all(
          color: value ? colorPrimary : white.withOpacity(0.2),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    color: white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: colorPrimary,
            inactiveThumbColor:
                enabled ? white.withOpacity(0.5) : white.withOpacity(0.3),
            inactiveTrackColor:
                enabled ? white.withOpacity(0.2) : white.withOpacity(0.1),
          ),
        ],
      ),
    );
  }
}
