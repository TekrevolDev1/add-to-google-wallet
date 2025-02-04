import 'dart:ui' as ui;

import 'package:add_to_google_wallet/add_to_google_wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

const double _buttonRadius = 24.5;
const String _defaultLanguageCode = 'en';
const String _defaultCountryCode = 'US';
const String _packagePrefix = 'packages/add_to_google_wallet/';
const String _buttonPathPrefix = 'assets/svg/buttons/';
const String _buttonPathSuffix = '_add_to_google_wallet_wallet-button.svg';

class AddToGoogleWalletButton extends StatelessWidget {
  /// [Generic pass JSON Object](https://developers.google.com/wallet/generic/android#1_create_a_passes_object)
  ///
  /// [Google codelab example](https://codelabs.developers.google.com/add-to-wallet-android#5)
  final String pass;

  /// Locale of the [AddToGoogleWalletButton].
  ///
  /// In case this field is null, current locale of the device will be used.
  /// In case [locale] is not supported, [Locale('en', 'US')] will be set as default.
  ///
  /// Supported locales: [ar, az, bg, br, bs, by, ca, cz, de, dk, en_AU, en_CA, en_GB, en_IN, en_SG, en_US, en_ZA, es419, es_ES, es_US, et, fl, fp, fr_CA, fr_FR, gr, he, hr, hu, hy, id, is, it, jp, ka, kk, ky, lt, lv, mk, my, nl, no, pl, pt, ro, ru, se, sk, sl, sq, sr, th, tr, uk, uz, vi, zh_HK, zh_TW]
  final Locale? locale;

  /// Called when an error was thrown while adding a pass to the Google Wallet
  final Function(Object)? onError;

  /// Called when a pass was successfully added to the Google Wallet
  final VoidCallback? onSuccess;

  /// Called when a user canceled process of adding a pass to the Google Wallet
  final VoidCallback? onCanceled;

  const AddToGoogleWalletButton({
    this.locale, this.onError, this.onSuccess, this.onCanceled,
    // this.locale,
    // this.onError,
    // this.onSuccess,
    // this.onCanceled,
    required this.pass,
  });

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          FutureBuilder(
            future: _getButtonAssetPath(context),
            builder: (context, dynamic snapshot) {
              if (snapshot.hasData) {
                return SvgPicture.asset(
                  snapshot.data!.toString(),
                  package: 'add_to_google_wallet',
                );
              }

              return SvgPicture.asset(
                _getPath(_defaultLanguageCode + _defaultCountryCode),
                package: 'add_to_google_wallet',
              );
            },
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _onAddToGoogleWalletTap,
                borderRadius:
                    const BorderRadius.all(Radius.circular(_buttonRadius)),
              ),
            ),
          ),
        ],
      );

  void _onAddToGoogleWalletTap() => AddToGoogleWallet().saveLoyaltyPass(
        pass: pass,
        onError: onError,
        onSuccess: onSuccess,
        onCanceled: onCanceled,
      );

  Future<String> _getButtonAssetPath(BuildContext context) async {
    final String languageCode =
        locale?.languageCode.toLowerCase() ?? ui.window.locale.languageCode;
    final String? countryCode =
        locale?.countryCode?.toUpperCase() ?? ui.window.locale.countryCode;

    if (countryCode != null) {
      final String? fullCodePath =
          await _validateAndReturnPath(languageCode + countryCode);

      if (fullCodePath != null) {
        return fullCodePath;
      }
    }

    final String? languageCodePath = await _validateAndReturnPath(languageCode);

    if (languageCodePath != null) {
      return languageCodePath;
    }

    switch (languageCode) {
      case 'en':
        const code = 'enUS';
        final path = await _validateAndReturnPath(code);
        if (path == null) continue defaultPath;
        return _getPath(code);
      case 'fr':
        const code = 'frFR';
        final path = await _validateAndReturnPath(code);
        if (path == null) continue defaultPath;
        return _getPath(code);
      case 'es':
        const code = 'esES';
        final path = await _validateAndReturnPath(code);
        if (path == null) continue defaultPath;
        return _getPath(code);
      case 'zh':
        const code = 'zhHK';
        final path = await _validateAndReturnPath(code);
        if (path == null) continue defaultPath;
        return _getPath(code);
      defaultPath:
      default:
        return _getPath(_defaultLanguageCode + _defaultCountryCode);
    }
  }

  Future<String?> _validateAndReturnPath(String code) async {
    try {
      final String path = _getPath(code);
      await rootBundle.load('$_packagePrefix$path');
      return path;
    } catch (_) {
      return null;
    }
  }

  String _getPath(String code) => '$_buttonPathPrefix$code$_buttonPathSuffix';
}
