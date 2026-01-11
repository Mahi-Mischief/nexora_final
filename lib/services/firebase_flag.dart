/// Simple runtime flag to indicate whether Firebase init succeeded.
class FirebaseFlag {
  static bool configured = false;
  static void setConfigured(bool v) => configured = v;
}
