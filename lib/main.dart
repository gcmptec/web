import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:gcmp_web/b2b_section.dart';
import 'package:gcmp_web/faq_section.dart';
import 'package:gcmp_web/firebase_options.dart';
import 'package:gcmp_web/footer.dart';
import 'package:gcmp_web/hero.dart';
import 'package:gcmp_web/how_and_features.dart';
import 'package:gcmp_web/navbar.dart';
import 'package:gcmp_web/shared.dart';
import 'package:gcmp_web/theme.dart';
import 'package:gcmp_web/video_section.dart';
import 'package:gcmp_web/who_and_pilot.dart';


void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterNativeSplash.remove();
  runApp(const GcmpWebApp());
}

class GcmpWebApp extends StatelessWidget {
  const GcmpWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GCMP Security — Emergency Response Intelligence',
      debugShowCheckedModeBanner: false,
      theme: GcmpTheme.theme,
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _scrollCtrl = ScrollController();
  bool _scrolled = false;

  final _howKey = GlobalKey();
  final _featuresKey = GlobalKey();
  final _whoKey = GlobalKey();
  final _b2bKey = GlobalKey();
  final _pilotKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final scrolled = _scrollCtrl.offset > 10;
    if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GcmpColors.bg,
      body: Column(
        children: [
          NavBar(
            scrollController: _scrollCtrl,
            scrolled: _scrolled,
            howKey: _howKey,
            featuresKey: _featuresKey,
            whoKey: _whoKey,
            b2bKey: _b2bKey,
            pilotKey: _pilotKey,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              child: Column(
                children: [
                  HeroSection(
                    onPilotTap: () {
                      FirebaseAnalytics.instance.logEvent(name: 'hero_pilot_cta_tap');
                      _scrollTo(_pilotKey);
                    },
                    onHowTap: () => _scrollTo(_howKey),
                  ),

                  const GcmpDivider(),

                  KeyedSubtree(key: _howKey, child: const HowItWorksSection()),

                  const GcmpDivider(),

                  const VideoSection(),

                  const GcmpDivider(),

                  KeyedSubtree(key: _featuresKey, child: const FeaturesSection()),

                  const GcmpDivider(),

                  KeyedSubtree(key: _whoKey, child: const WhoSection()),

                  const GcmpDivider(),

                  KeyedSubtree(
                    key: _b2bKey,
                    child: B2bSection(onPartnerTap: () {
                      FirebaseAnalytics.instance.logEvent(name: 'partner_cta_tap');
                      _scrollTo(_pilotKey);
                    }),
                  ),

                  const GcmpDivider(),

                  const FaqSection(),

                  const GcmpDivider(),

                  KeyedSubtree(key: _pilotKey, child: const PilotSection()),

                  const FooterSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
