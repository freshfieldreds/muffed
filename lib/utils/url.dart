/// If there is no 'https://' or 'http://' on the start on the string it will
/// append 'https://'
String ensureProtocolSpecified(String url) {
  if (url.contains(RegExp('https?://'))) {
    return url;
  } else {
    return 'https://$url';
  }
}