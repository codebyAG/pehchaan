import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pehchaan/core/api/api_config.dart';

/// The single "buy plan / create more" action (§9.3). There's no in-app
/// payment; exact behaviour is pending product sign-off, so it lives here
/// as one function. For now: WhatsApp the sales number with a prefilled
/// message, falling back to a phone call. No analytics event yet.
Future<void> contactSales(
  BuildContext context, {
  String? planName,
  String? shopName,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final phone = ApiConfig.salesPhone;
  if (phone.isEmpty) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Hamari team jaldi aapko call karegi.')),
    );
    return;
  }

  final message = [
    'Namaste, mujhe Pehchaan',
    if (planName != null) '"$planName" plan',
    'ke baare mein jaankari chahiye.',
    if (shopName != null) 'Shop: $shopName',
  ].join(' ');

  final whatsapp = Uri.parse(
    'https://wa.me/91$phone?text=${Uri.encodeComponent(message)}',
  );
  try {
    if (await launchUrl(whatsapp, mode: LaunchMode.externalApplication)) return;
  } catch (_) {}
  try {
    if (await launchUrl(Uri(scheme: 'tel', path: '+91$phone'))) return;
  } catch (_) {}
  messenger.showSnackBar(
    SnackBar(content: Text('Humein call karein: +91 $phone')),
  );
}
