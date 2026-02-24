import 'package:url_launcher/url_launcher.dart';

import 'supabase_service.dart';

class StripeService {
  StripeService._();

  /// Creates a Stripe Checkout session via Supabase Edge Function.
  /// Returns the checkout session URL.
  static Future<String> createCheckoutSession({
    required String userId,
    required String plan,
    required String interval,
  }) async {
    final response = await SupabaseService.client.functions.invoke(
      'create-stripe-session',
      body: {
        'user_id': userId,
        'plan': plan,
        'interval': interval,
      },
    );

    final data = response.data as Map<String, dynamic>;
    return data['session_url'] as String;
  }

  /// Opens Stripe billing portal for managing subscriptions.
  static Future<void> openBillingPortal(String customerId) async {
    final response = await SupabaseService.client.functions.invoke(
      'create-billing-portal',
      body: {'customer_id': customerId},
    );

    final data = response.data as Map<String, dynamic>;
    final url = data['portal_url'] as String;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  /// Opens a Stripe checkout URL in a new browser tab.
  static Future<void> openCheckoutUrl(String sessionUrl) async {
    await launchUrl(Uri.parse(sessionUrl), mode: LaunchMode.externalApplication);
  }
}
