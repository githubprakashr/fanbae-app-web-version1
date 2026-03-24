import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:url_launcher/url_launcher.dart';

class CookieConsentSettingsPage extends StatefulWidget {
  const CookieConsentSettingsPage({super.key});

  @override
  State<CookieConsentSettingsPage> createState() =>
      _CookieConsentSettingsPageState();
}

class _CookieConsentSettingsPageState extends State<CookieConsentSettingsPage> {
  bool _essentialCookies = true;
  bool _analyticsCookies = false;
  bool _marketingCookies = false;
  bool _functionalCookies = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _analyticsCookies = prefs.getBool('cookie_analytics') ?? false;
      _marketingCookies = prefs.getBool('cookie_marketing') ?? false;
      _functionalCookies = prefs.getBool('cookie_functional') ?? false;
      _loading = false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cookie_consent_given', true);
    await prefs.setBool('cookie_analytics', _analyticsCookies);
    await prefs.setBool('cookie_marketing', _marketingCookies);
    await prefs.setBool('cookie_functional', _functionalCookies);

    if (mounted) {
      Utils().showSnackBar(context, 'Cookie preferences saved', true);
    }
  }

  Future<void> _openCookiePolicy() async {
    String baseUrl = Constant().baseurl.replaceAll('/api/', '/');
    final Uri url = Uri.parse('${baseUrl}pages/cookie-policy');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        Utils().showSnackBar(context, 'Could not open Cookie Policy', false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, color: white, size: 22),
        ),
        title: MyText(
          text: 'Cookie Consent Settings',
          color: white,
          multilanguage: false,
          fontwaight: FontWeight.w600,
          fontsizeNormal: 18,
        ),
      ),
      body: Utils().pageBg(
        context,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorPrimaryDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.cookie, color: colorPrimary, size: 32),
                              const SizedBox(width: 12),
                              Expanded(
                                child: MyText(
                                  text: 'Manage Your Cookies',
                                  color: white,
                                  multilanguage: false,
                                  fontwaight: FontWeight.bold,
                                  fontsizeNormal: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          MyText(
                            text:
                                'Control which cookies you want to allow. Essential cookies are required for the website to function and cannot be disabled.',
                            color: white.withOpacity(0.8),
                            multilanguage: false,
                            fontsizeNormal: 14,
                            maxline: 10,
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _openCookiePolicy,
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: colorPrimary, size: 18),
                                const SizedBox(width: 8),
                                MyText(
                                  text: 'View Full Cookie Policy',
                                  color: colorPrimary,
                                  multilanguage: false,
                                  fontwaight: FontWeight.w600,
                                  fontsizeNormal: 14,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Cookie Options
                    _buildCookieOption(
                      title: 'Essential Cookies',
                      description:
                          'These cookies are necessary for the website to function and cannot be switched off in our systems. They are usually only set in response to actions made by you which amount to a request for services.',
                      value: _essentialCookies,
                      enabled: false,
                      icon: Icons.check_circle,
                      onChanged: null,
                    ),
                    const SizedBox(height: 16),

                    _buildCookieOption(
                      title: 'Analytics Cookies',
                      description:
                          'These cookies allow us to count visits and traffic sources so we can measure and improve the performance of our site. They help us know which pages are the most and least popular.',
                      value: _analyticsCookies,
                      enabled: true,
                      icon: Icons.analytics,
                      onChanged: (value) {
                        setState(() => _analyticsCookies = value);
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildCookieOption(
                      title: 'Marketing Cookies',
                      description:
                          'These cookies may be set through our site by our advertising partners. They may be used to build a profile of your interests and show you relevant adverts on other sites.',
                      value: _marketingCookies,
                      enabled: true,
                      icon: Icons.campaign,
                      onChanged: (value) {
                        setState(() => _marketingCookies = value);
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildCookieOption(
                      title: 'Functional Cookies',
                      description:
                          'These cookies enable the website to provide enhanced functionality and personalization. They may be set by us or by third party providers whose services we have added to our pages.',
                      value: _functionalCookies,
                      enabled: true,
                      icon: Icons.settings,
                      onChanged: (value) {
                        setState(() => _functionalCookies = value);
                      },
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _savePreferences();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrimary,
                          foregroundColor: white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: MyText(
                          text: 'Save Preferences',
                          color: white,
                          multilanguage: false,
                          fontwaight: FontWeight.bold,
                          fontsizeNormal: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
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
    required IconData icon,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorPrimaryDark,
        border: Border.all(
          color: value ? colorPrimary : white.withOpacity(0.2),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: colorPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MyText(
                  text: title,
                  color: white,
                  multilanguage: false,
                  fontwaight: FontWeight.w600,
                  fontsizeNormal: 16,
                ),
              ),
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
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: MyText(
              text: description,
              color: white.withOpacity(0.7),
              multilanguage: false,
              fontsizeNormal: 13,
              maxline: 10,
            ),
          ),
          if (!enabled)
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: MyText(
                  text: 'Always Active',
                  color: colorPrimary,
                  multilanguage: false,
                  fontsizeNormal: 11,
                  fontwaight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
