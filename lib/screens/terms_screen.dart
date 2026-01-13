import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TermsScreen extends StatefulWidget {
  static const routeName = '/terms';
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _accepted = false;
  static const _prefsKey = 'nexora_terms_accepted';

  @override
  void initState() {
    super.initState();
    _loadAccepted();
  }

  Future<void> _loadAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _accepted = prefs.getBool(_prefsKey) ?? false);
  }

  Future<void> _setAccepted(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, v);
    if (mounted) setState(() => _accepted = v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms and Conditions')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                r'''Nexora – Terms and Conditions
Last updated: January 11, 2026 → January 11, 2026
These Terms and Conditions govern your access to and use of Nexora , including our mobile application, website, and related services.
By accessing or using the Service, you agree to these Terms. If you do not agree, do not use the Service.
1. Eligibility
You must be at least 13 years old (or the minimum age required in your country) to use the Service. If you are using the Service on behalf of an organization, you represent that you have authority to bind that organization to these Terms.
2. Account Registration and Security
You may need an account to use certain features.
You agree to provide accurate information and keep it up to date.
You are responsible for all activity under your account and for keeping your login credentials confidential.
You must notify us promptly of any unauthorized use of your account.
3. Using the Service
You agree to use the Service only for lawful purposes and in accordance with these Terms. You must not:
Violate any applicable law or regulation.
Reverse engineer, decompile, or attempt to extract source code except where permitted by law.
Interfere with or disrupt the Service, including by transmitting malware or conducting attacks.
Access or use the Service in a way that could damage, disable, overburden, or impair it.
Use the Service to infringe, misappropriate, or otherwise violate anyone else’s rights.
4.1 Your Content
"Your Content" means any content you submit, upload, or make available through the Service.
You retain ownership of Your Content.
You grant Nexora a non-exclusive, worldwide, royalty-free license to host, store, reproduce, modify (for technical purposes, such as formatting), and display Your Content solely to operate and provide the Service.
You represent you have the rights needed to grant this license.
4.2 Prohibited Content
You agree not to submit content that is illegal, harmful, harassing, defamatory, obscene, or that infringes intellectual property or privacy rights.
5. Third-Party Services and Links
The Service may integrate with or link to third-party services. We do not control and are not responsible for third-party services. Your use of third-party services is subject to their terms and policies.
6. Intellectual Property
The Service, including software, design, text, graphics, and trademarks, is owned by Nexora or its licensors and is protected by applicable intellectual property laws.
We grant you a limited, non-exclusive, non-transferable, revocable license to use the Service for your personal or internal business purposes, subject to these Terms.
No rights are granted except as expressly stated.
7. Feedback
If you provide suggestions or feedback, you grant Nexora the right to use it without restriction or compensation.
8. Termination
You may stop using the Service at any time.
We may suspend or terminate your access to the Service if:
You violate these Terms.
We reasonably believe your use creates risk or legal exposure.
We are required to do so by law.
Upon termination, your right to use the Service stops immediately.
9. Disclaimer of Warranties
The Service is provided “as is” and “as available.” To the fullest extent permitted by law, Nexora disclaims all warranties, express or implied, including implied warranties of merchantability, fitness for a particular purpose, and non-infringement.
We do not guarantee that the Service will be uninterrupted, secure, or error-free.
10. Limitation of Liability
To the fullest extent permitted by law:
Nexora will not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits, revenue, data, or goodwill.
Nexora’s total liability for any claim relating to the Service will not exceed the amount you paid to Nexora for the Service in the 12 months before the event giving rise to the claim, or $100 if you have not paid anything.
Some jurisdictions do not allow certain limitations, so some of the above may not apply to you.
11. Indemnification
You agree to indemnify and hold harmless Nexora and its affiliates, officers, employees, and agents from any claims, liabilities, damages, and expenses (including reasonable attorneys’ fees) arising out of:
Your use of the Service.
Your violation of these Terms.
Your violation of any rights of another party.
12. Privacy
Our collection and use of personal information is described in our Privacy Policy. If you do not have a Privacy Policy yet, you should publish one and link it here.
13. Changes to These Terms
We may update these Terms from time to time. If we make material changes, we will take reasonable steps to notify you (for example, by posting an update in the Service). Your continued use of the Service after changes become effective means you accept the updated Terms.
14. Governing Law and Dispute Resolution
These Terms are governed by the laws of the jurisdiction where Nexora is established, excluding conflict-of-law rules.
Any dispute arising out of or relating to these Terms or the Service will be resolved in the courts located in that jurisdiction, unless applicable law requires otherwise.
15. Contact Us
Questions about these Terms?
Email: nexora291802@gmail.com

''',
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
            child: CheckboxListTile(
              title: const Text('I agree to the Terms and Conditions'),
              value: _accepted,
              onChanged: (v) => _setAccepted(v ?? false),
            ),
          ),
        ],
      ),
    );
  }
}
