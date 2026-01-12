import 'package:share_plus/share_plus.dart';
import '../../features/quotes/domain/entities/quote.dart';

class ShareHelper {
  static Future<void> shareQuote(Quote quote) async {
    final text = '"${quote.text}" — ${quote.author}';
    await Share.share(text);
  }
}

