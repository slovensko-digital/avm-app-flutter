import 'package:flutter/widgets.dart';

import 'l10n/app_localizations.dart';
import 'l10n/app_localizations_sk.dart';

/// Access to [AppLocalizations] from [BuildContext].
extension StringsContext on BuildContext {
  static final _default = AppLocalizationsSk();

  /// Gets the [AppLocalizations].
  AppLocalizations get strings {
    return AppLocalizations.of(this) ?? _default;
  }
}
