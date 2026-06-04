import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  FLAYR — App Identity
// ─────────────────────────────────────────────
const String appName = "FLAYR";
const String appTagline = "Show your flayr";
const String baseURL = "https://admin.flayr.buzz/";
const String itemBaseURL = "";
const String apiURL = "${baseURL}api/";
const String termsURL = "${baseURL}termsOfUse";
const String privacyURL = "${baseURL}privacyPolicy";
const String helpURL = "https://www.flayr.buzz";
const String notificationTopic = "flayr";

// ── Stripe Subscriptions (replaces RevenueCat) ──────────
// Set your Stripe publishable key here
const String stripePublishableKey = 'pk_live_your_stripe_publishable_key';
// Plan price IDs from your Stripe Dashboard
const String stripePriceMonthly = 'price_your_monthly_price_id';
const String stripePriceYearly = 'price_your_yearly_price_id';

const String agoraAppId = 'agora_app_id';
const String agoraCustomerId = 'agora_customer_id';
const String agoraCustomerSecret = 'agora_customer_secret';

class Limits {
  static int username = 30;
  static int roomDescCount = 120;
  static int bioCount = 120;
  static int interestCount = 5;
  static int pagination = 20;
  static int storyDuration = 3;
  static int sightEngineCropSec = 5;
  static double imageSize = 720;
  static int quality = 50;
}

const List<String> storyQuickReplyEmojis = ['😂', '😮', '😍', '😢', '👏', '🔥'];
const List<int> secondsForMakingReel = [15, 30];

extension O on String {
  String addBaseURL() {
    return itemBaseURL + this;
  }
}

// ─────────────────────────────────────────────
//  FLAYR Design System — Dark Neon Vibrant
// ─────────────────────────────────────────────

// Backgrounds
const fBG = Color(0xFF080808); // main background
const fSurface = Color(0xFF111111); // card / sheet surface
const fSurface2 = Color(0xFF1A1A1A); // elevated surface
const fBorder = Color(0xFF2A2A2A); // subtle border

// Brand Gradient  (#FFB800 gold → #FF4D00 orange → #FF006E hot-pink)
const fGradStart = Color(0xFFFFB800);
const fGradMid = Color(0xFFFF4D00);
const fGradEnd = Color(0xFFFF006E);

// Accent colors
const fNeonBlue = Color(0xFF3A86FF);
const fNeonGreen = Color(0xFF00C896);
const fNeonPurple = Color(0xFF8338EC);

// Text on dark
const fTextPrimary = Color(0xFFF8F8F8);
const fTextSecondary = Color(0xFFA0A0A0);
const fTextMuted = Color(0xFF555555);

// Vibe Score colors
const fVibeFireColor = Color(0xFFFF4D00);
const fVibeChillColor = Color(0xFF3A86FF);
const fVibeWildColor = Color(0xFFCF00FF);
const fVibeDeepColor = Color(0xFFFFB800);

// ─── Gradient shortcuts ──────────────────────
const LinearGradient flayrGradient = LinearGradient(
  colors: [fGradStart, fGradMid, fGradEnd],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

const LinearGradient flayrGradientVertical = LinearGradient(
  colors: [fGradStart, fGradEnd],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

// Glassmorphism decoration helper
BoxDecoration flayrGlassDecoration({
  double radius = 20,
  Color? borderColor,
  List<BoxShadow>? shadows,
}) {
  return BoxDecoration(
    color: fSurface.withValues(alpha: 0.65),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: borderColor ?? fBorder, width: 0.8),
    boxShadow: shadows,
  );
}

// Neon glow shadow
List<BoxShadow> neonGlow(Color color, {double blur = 18, double spread = 0}) =>
    [
      BoxShadow(
          color: color.withValues(alpha: 0.5),
          blurRadius: blur,
          spreadRadius: spread),
      BoxShadow(
          color: color.withValues(alpha: 0.2),
          blurRadius: blur * 2.5,
          spreadRadius: spread),
    ];

// ─────────────────────────────────────────────
//  Legacy colors — kept for backward compat
//  (screens we haven't redesigned yet still use them)
// ─────────────────────────────────────────────
const cPrimary = Color(0xFFFFB800); // FLAYR gold (was green)
const cPulsing = Color(0xFFFF8C42);
const cHashtagColor = Color(0xFF3A86FF);
const cWhite = Colors.white;
const cBlack = Color(0xFF080808); // = fBG
const cBlackSheetBG = Color(0xFF111111); // = fSurface
const cMainText = Color(0xFFF8F8F8);
const cLightText = Color(0xFFA0A0A0);
const cLightIcon = Color(0xFF666666);
const cDarkText = Color(0xFFD0D0D0);
const cLightBg = Color(0xFF111111); // dark surface now
const cDarkBG = Color(0xFF1A1A1A);
const cBG = Color(0xFF080808);
const cGreen = Color(0xFF00C896);
const cDarkGreen = Color(0xFF003D2D);
const cBlueTick = Color(0xFF3A86FF);
const cRed = Color(0xFFFF3939);

const cAudioSpaceBG = Color(0xFF111111);
const cAudioSpaceDarkBG = Color(0xFF0D0D0D);
const cAudioSpaceLightBG = Color(0xFF1A1A1A);
const cAudioSpaceText = Color(0xFFF8F8F8);

const refreshIndicatorColor = fGradStart;
const refreshIndicatorBgColor = fBG;

// Corner Radius-Smoothing
const cornerSmoothing = 1.0;
