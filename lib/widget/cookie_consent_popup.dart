import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:url_launcher/url_launcher.dart';

class CookieConsentPopup extends StatefulWidget {
  const CookieConsentPopup({super.key});

  @override
  State<CookieConsentPopup> createState() => _CookieConsentPopupState();
}

class _CookieConsentPopupState extends State<CookieConsentPopup>
    with SingleTickerProviderStateMixin {
  bool _showPopup = false;
  bool _showManageOptions = false;
  static const String _consentKey = 'cookie_consent_given';

  // Cookie preferences
  bool _essentialCookies = true; // Always enabled
  bool _analyticsCookies = false;
  bool _marketingCookies = false;
  bool _functionalCookies = false;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _checkConsent();
  }

  Future<void> _checkConsent() async {
    // Only show on web platform
    if (!kIsWeb) return;

    final prefs = await SharedPreferences.getInstance();
    final hasConsent = prefs.getBool(_consentKey) ?? false;

    if (!hasConsent) {
      setState(() {
        _showPopup = true;
      });
      _animationController.forward();
    }
  }

  Future<void> _saveConsent({
    required bool essential,
    required bool analytics,
    required bool marketing,
    required bool functional,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, true);
    await prefs.setBool('cookie_essential', essential);
    await prefs.setBool('cookie_analytics', analytics);
    await prefs.setBool('cookie_marketing', marketing);
    await prefs.setBool('cookie_functional', functional);

    await _animationController.reverse();
    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) {
      setState(() {
        _showPopup = false;
      });
    }
  }

  Future<void> _acceptAll() async {
    await _saveConsent(
      essential: true,
      analytics: true,
      marketing: true,
      functional: true,
    );
  }

  Future<void> _rejectAll() async {
    await _saveConsent(
      essential: true,
      analytics: false,
      marketing: false,
      functional: false,
    );
  }

  Future<void> _savePreferences() async {
    await _saveConsent(
      essential: true,
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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showPopup) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.6),
      body: Stack(
        children: [
          // Semi-transparent backdrop (provided by scaff background)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {}, // Prevent closing by tapping backdrop
            ),
          ),

          // Cookie popup
          SlideTransition(
            position: _slideAnimation,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                color: colorPrimaryDark,
                borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.width > 800 ? 16 : 0,
                ),
                elevation: 8,
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.width > 800 ? 20 : 0,
                    left: MediaQuery.of(context).size.width > 800 ? 20 : 0,
                    right: MediaQuery.of(context).size.width > 800 ? 20 : 0,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width > 800
                        ? 600
                        : double.infinity,
                  ),
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Icon(
                                Icons.cookie,
                                color: colorPrimary,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _showManageOptions
                                      ? 'Manage Cookie Preferences'
                                      : 'We Value Your Privacy',
                                  style: TextStyle(
                                    color: white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (!_showManageOptions) ...[
                            // Main message
                            Text(
                              'We use cookies to enhance your browsing experience, serve personalized content, and analyze our traffic. '
                              'By clicking "Accept All", you consent to our use of cookies.',
                              style: TextStyle(
                                color: white.withOpacity(0.9),
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Cookie Policy links
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: _openCookiePolicy,
                                  child: Text(
                                    'Read our Cookie Policy',
                                    style: TextStyle(
                                      color: colorPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '|',
                                    style: TextStyle(
                                      color: white.withOpacity(0.5),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _openCookieConsentBanner,
                                  child: Text(
                                    'Cookie Consent Banner',
                                    style: TextStyle(
                                      color: colorPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Action buttons
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Accept All button
                                ElevatedButton(
                                  onPressed: _acceptAll,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorPrimary,
                                    foregroundColor: white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Accept All',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Reject All button
                                OutlinedButton(
                                  onPressed: _rejectAll,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: white,
                                    side: BorderSide(
                                        color: white.withOpacity(0.3)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Reject All',
                                    style: TextStyle(fontSize: 15),
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
                                    foregroundColor: colorPrimary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Manage Preferences',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(Icons.settings, size: 18),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            // Manage cookies options
                            Text(
                              'Choose which cookies you want to accept. Essential cookies are always enabled as they are necessary for the website to function.',
                              style: TextStyle(
                                color: white.withOpacity(0.9),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Cookie toggles
                            _buildCookieToggle(
                              title: 'Essential Cookies',
                              description:
                                  'Required for the website to function properly. Cannot be disabled.',
                              value: _essentialCookies,
                              enabled: false,
                              onChanged: null,
                            ),

                            _buildCookieToggle(
                              title: 'Analytics Cookies',
                              description:
                                  'Help us understand how visitors interact with our website.',
                              value: _analyticsCookies,
                              enabled: true,
                              onChanged: (value) {
                                setState(() {
                                  _analyticsCookies = value;
                                });
                              },
                            ),

                            _buildCookieToggle(
                              title: 'Marketing Cookies',
                              description:
                                  'Used to deliver personalized advertisements.',
                              value: _marketingCookies,
                              enabled: true,
                              onChanged: (value) {
                                setState(() {
                                  _marketingCookies = value;
                                });
                              },
                            ),

                            _buildCookieToggle(
                              title: 'Functional Cookies',
                              description:
                                  'Remember your preferences and provide enhanced features.',
                              value: _functionalCookies,
                              enabled: true,
                              onChanged: (value) {
                                setState(() {
                                  _functionalCookies = value;
                                });
                              },
                            ),

                            const SizedBox(height: 20),

                            // Action buttons for manage view
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ElevatedButton(
                                  onPressed: _savePreferences,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorPrimary,
                                    foregroundColor: white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
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
                                const SizedBox(height: 10),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _showManageOptions = false;
                                    });
                                  },
                                  child: Text(
                                    'Back',
                                    style: TextStyle(
                                      color: white.withOpacity(0.7),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCookieToggle({
    required String title,
    required String description,
    required bool value,
    required bool enabled,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorPrimaryDark.withOpacity(0.5),
        border: Border.all(
          color: white.withOpacity(0.1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: white.withOpacity(0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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
