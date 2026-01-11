// Conditional export: use mobile implementation by default, web will override.
export 'google_signin_mobile.dart'
    if (dart.library.html) 'google_signin_web.dart';

