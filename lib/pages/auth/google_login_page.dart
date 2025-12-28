import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/services/auth_service.dart';
import '../../core/constants/api_constants.dart';

class GoogleLoginScreen extends StatefulWidget {
  const GoogleLoginScreen({super.key});

  @override
  State<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
  final GlobalKey webViewKey = GlobalKey();
  // Construct the URL using the base URL from constants
  late final String authUrl;

  @override
  void initState() {
    super.initState();
    authUrl = "${ApiConstants.baseUrl}/oauth/google";
  }

  Future<void> _launchURL() async {
    final Uri url = Uri.parse(authUrl);
    // Use '_self' to open in the same tab, creating a seamless redirect flow
    if (!await launchUrl(url, webOnlyWindowName: '_self')) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign in with Google")),
      body: kIsWeb
          ? Center(
              child: ElevatedButton.icon(
                onPressed: _launchURL,
                icon: const Icon(Icons.open_in_browser),
                label: const Text("Continue to Google Sign In"),
              ),
            )
          : InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(
                url: WebUri(authUrl),
                headers: {"ngrok-skip-browser-warning": "true"},
              ),
              initialSettings: InAppWebViewSettings(
                userAgent:
                    "Mozilla/5.0 (Linux; Android 11; Pixel 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.91 Mobile Safari/537.36",
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: true,
              ),
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var uri = navigationAction.request.url;
                // 1. Check for Localhost Redirect (Token Handover from Backend)
                if (uri != null &&
                    uri.toString().startsWith("http://localhost")) {
                  String? token = uri.queryParameters['token'];
                  if (token != null) {
                    await AuthService().saveToken(token);
                    if (mounted) {
                      Navigator.pop(context, true);
                    }
                    return NavigationActionPolicy
                        .CANCEL; // Stop loading localhost
                  }
                }

                // 2. Check for Ngrok (Bypass Warning)
                if (uri != null &&
                    uri.host.contains('ngrok') &&
                    navigationAction
                            .request.headers?['ngrok-skip-browser-warning'] ==
                        null) {
                  // Inject Header bypass for Ngrok
                  controller.loadUrl(
                    urlRequest: URLRequest(
                      url: WebUri(uri.toString()),
                      headers: {"ngrok-skip-browser-warning": "true"},
                    ),
                  );
                  return NavigationActionPolicy.CANCEL;
                }
                return NavigationActionPolicy.ALLOW;
              },
              onLoadStop: (controller, url) async {
                if (url == null) return;
                // Check if we have reached the callback URL
                if (url.toString().contains('/oauth/google/callback')) {
                  // Get the HTML content (which is the JSON response from Laravel)
                  var html = await controller.evaluateJavascript(
                      source: "document.body.innerText");

                  if (html != null) {
                    try {
                      // html from innerText defines the content.
                      // If it is a string representing json, we parse it.
                      // jsonDecode returns Map<String, dynamic>
                      var data;
                      if (html is String) {
                        // Sometimes double decoding is needed if it's returned as a quoted string
                        try {
                          data = jsonDecode(html);
                        } catch (_) {
                          // If it fails, maybe it was not json string, or needs cleaning
                          data = jsonDecode(html.toString()); // Retry or check
                        }
                      } else {
                        data = html;
                      }

                      // If data is just the string, tries to decode it again if needed
                      if (data is String) {
                        data = jsonDecode(data);
                      }

                      if (data is Map && data['access_token'] != null) {
                        // SUCCESS: Token found
                        String token = data['access_token'];

                        // 1. Save Token
                        await AuthService().saveToken(token);

                        // 2. Close WebView and Return
                        if (mounted) {
                          Navigator.pop(context, true); // Return success
                        }
                      }
                    } catch (e) {
                      // print("Error parsing JSON: $e");
                    }
                  }
                }
              },
            ),
    );
  }
}
