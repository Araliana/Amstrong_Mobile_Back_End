import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class CollapsibleBannerAd extends StatefulWidget {
  const CollapsibleBannerAd({super.key});

  @override
  State<CollapsibleBannerAd> createState() => _CollapsibleBannerAdState();
}

class _CollapsibleBannerAdState extends State<CollapsibleBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() async {
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQueryData.fromView(
        WidgetsBinding.instance.window,
      ).size.width.truncate(),
    );

    if (size == null) return;

    final adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/2014213617' // test Android
        : 'ca-app-pub-3940256099942544/2934735716'; // test iOS

    final ad = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(extras: {'collapsible': 'bottom'}),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          debugPrint('Failed to load ad: $err');
        },
      ),
    );

    await ad.load();
  }

  void _closeAd() {
    _bannerAd?.dispose();
    setState(() {
      _isLoaded = false;
      _bannerAd = null;
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              color: Colors.transparent,
              child: AdWidget(ad: _bannerAd!),
            ),
            // Tombol close di pojok kanan atas banner
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: _closeAd,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
