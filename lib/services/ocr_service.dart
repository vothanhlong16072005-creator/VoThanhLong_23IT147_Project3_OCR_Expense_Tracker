import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/transaction.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  // Auto-Categorization Dictionary
  final Map<String, ExpenseCategory> _categoryRules = {
    'highlands': ExpenseCategory.food,
    'phúc long': ExpenseCategory.food,
    'phuc long': ExpenseCategory.food,
    'starbucks': ExpenseCategory.food,
    'the coffee house': ExpenseCategory.food,
    'trà sữa': ExpenseCategory.food,
    'tra sua': ExpenseCategory.food,
    'cà phê': ExpenseCategory.food,
    'ca phe': ExpenseCategory.food,
    'kfc': ExpenseCategory.food,
    'lotteria': ExpenseCategory.food,
    'jollibee': ExpenseCategory.food,
    'pizza': ExpenseCategory.food,
    'winmart': ExpenseCategory.food,
    'bách hóa': ExpenseCategory.food,
    'bach hoa': ExpenseCategory.food,
    'circle k': ExpenseCategory.food,
    'family mart': ExpenseCategory.food,
    'familymart': ExpenseCategory.food,
    'gs25': ExpenseCategory.food,
    'ministop': ExpenseCategory.food,
    '7-eleven': ExpenseCategory.food,
    'cơm': ExpenseCategory.food,
    'bún': ExpenseCategory.food,
    'phở': ExpenseCategory.food,
    'buffet': ExpenseCategory.food,
    'nhà hàng': ExpenseCategory.food,
    'nha hang': ExpenseCategory.food,
    'quán ăn': ExpenseCategory.food,
    'nước ngọt': ExpenseCategory.food,
    'sữa tươi': ExpenseCategory.food,
    'sua tuoi': ExpenseCategory.food,
    'nhà sách': ExpenseCategory.study,
    'nha sach': ExpenseCategory.study,
    'fahasa': ExpenseCategory.study,
    'nhà sách phương nam': ExpenseCategory.study,
    'văn phòng phẩm': ExpenseCategory.study,
    'học phí': ExpenseCategory.study,
    'đào tạo': ExpenseCategory.study,
    'cgv': ExpenseCategory.entertainment,
    'lotte cinema': ExpenseCategory.entertainment,
    'bhd': ExpenseCategory.entertainment,
    'galaxy': ExpenseCategory.entertainment,
    'karaoke': ExpenseCategory.entertainment,
    'billiards': ExpenseCategory.entertainment,
    'grab': ExpenseCategory.travel,
    'be': ExpenseCategory.travel,
    'xăng': ExpenseCategory.travel,
    'xang': ExpenseCategory.travel,
    'petrolimex': ExpenseCategory.travel,
    'giao hàng': ExpenseCategory.travel,
    'shopee express': ExpenseCategory.travel,
    'fpt': ExpenseCategory.gear,
    'thegioididong': ExpenseCategory.gear,
    'thế giới di động': ExpenseCategory.gear,
    'cellphones': ExpenseCategory.gear,
    'dienmayxanh': ExpenseCategory.gear,
    'điện máy xanh': ExpenseCategory.gear,
  };

  Future<ParsedReceipt> processImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    return parseText(recognizedText.text);
  }

  ParsedReceipt parseText(String rawText) {
    final lines = rawText
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final date = _extractDate(rawText);
    final amount = _extractAmount(rawText, lines);
    final merchant = _extractMerchant(rawText, lines);
    final category = _extractCategory(rawText, merchant);

    return ParsedReceipt(
      amount: amount,
      date: date,
      merchant: merchant,
      category: category,
      rawText: rawText,
    );
  }

  // 1. Extract Date
  DateTime _extractDate(String rawText) {
    DateTime parsedDate = DateTime.now();

    // Check Vietnamese format: "Ngày 08 tháng 02 năm 2026"
    final vnDatePattern = RegExp(r'Ngày\s*(\d{1,2})\s*tháng\s*(\d{1,2})\s*năm\s*(\d{4})', caseSensitive: false);
    final vnMatch = vnDatePattern.firstMatch(rawText);
    if (vnMatch != null) {
      try {
        int day = int.parse(vnMatch.group(1)!);
        int month = int.parse(vnMatch.group(2)!);
        int year = int.parse(vnMatch.group(3)!);
        if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          return DateTime(year, month, day);
        }
      } catch (_) {}
    }

    // Support flexible spacing around separators like "01/10 / 2018" or "10/10/2026"
    final dateRegexes = [
      RegExp(r'\b(\d{1,2})\s*[\/\-\.]\s*(\d{1,2})\s*[\/\-\.]\s*(\d{4})\b'),
      RegExp(r'\b(\d{4})\s*[\/\-\.]\s*(\d{1,2})\s*[\/\-\.]\s*(\d{1,2})\b'),
      RegExp(r'\b(\d{1,2})\s*[\/\-\.]\s*(\d{1,2})\s*[\/\-\.]\s*(\d{2})\b'),
    ];

    for (final reg in dateRegexes) {
      final match = reg.firstMatch(rawText);
      if (match != null) {
        try {
          if (reg == dateRegexes[1]) {
            int year = int.parse(match.group(1)!);
            int month = int.parse(match.group(2)!);
            int day = int.parse(match.group(3)!);
            if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
              return DateTime(year, month, day);
            }
          } else {
            int day = int.parse(match.group(1)!);
            int month = int.parse(match.group(2)!);
            int year = int.parse(match.group(3)!);
            if (year < 100) year += 2000;
            if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
              return DateTime(year, month, day);
            }
          }
        } catch (_) {}
      }
    }
    return parsedDate;
  }

  // 2. Extract Amount
  double _extractAmount(String rawText, List<String> lines) {
    final highPriorityKeywords = [
      'cộng tiền thanh toán', 'cong tien thanh toan',
      'khách thanh toán', 'khach thanh toan',
      'tổng cộng', 'tong cong', 'thanh toán', 'thanh toan',
      'tổng tiền', 'tong tien', 'thành tiền', 'thanh tien',
      'tổng thanh toán', 'tong thanh toan', 'tiền phải trả',
      'phải thanh toán', 'phai thanh toan', 'tiền thanh toán',
      'tổng phải trả', 'grand total', 'total due', 'amount due',
      'balance due', 'net total'
    ];

    final secondaryKeywords = [
      'tổng', 'tong', 'cộng tiền hàng', 'cong tien hang',
      'cộng tiền', 'cong tien',
      'tiền hàng', 'tien hang', 'cộng', 'cong', 'total',
      'phải trả', 'phai tra', 'amount', 'tiền mặt', 'tien mat'
    ];

    // PASS 1: Check high priority keywords line-by-line
    double? foundAmount = _searchAmountByKeywords(lines, highPriorityKeywords);
    if (foundAmount != null && foundAmount > 0) return foundAmount;

    // PASS 2: Check secondary keywords line-by-line
    foundAmount = _searchAmountByKeywords(lines, secondaryKeywords);
    if (foundAmount != null && foundAmount > 0) return foundAmount;

    // PASS 3: Search for numbers with explicit currency symbols (vnđ, vnd, đ, d)
    final currencyRegex = RegExp(
      r'((?:\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?|\d+))\s*(?:vnđ|vnd|đồng|dong|đ|d)\b',
      caseSensitive: false,
    );
    double maxCurrencyAmount = 0.0;
    for (final match in currencyRegex.allMatches(rawText)) {
      final val = _parseMoneyString(match.group(1));
      if (val != null && val > maxCurrencyAmount && _isValidAmount(val)) {
        maxCurrencyAmount = val;
      }
    }
    if (maxCurrencyAmount > 0) return maxCurrencyAmount;

    // PASS 4: Find largest formatted number (e.g. 150.000 or 150,000 or 2.305.360,00)
    final formattedNumberRegex = RegExp(r'\b\d{1,3}(?:[.,]\d{3})+(?:[.,]\d{2})?\b');
    double maxFormatted = 0.0;
    for (final match in formattedNumberRegex.allMatches(rawText)) {
      final val = _parseMoneyString(match.group(0));
      if (val != null && val > maxFormatted && _isValidAmount(val)) {
        maxFormatted = val;
      }
    }
    if (maxFormatted > 0) return maxFormatted;

    // PASS 5: Fallback to standalone integer number reasonable for VND (between 1,000 and 500,000,000)
    final intRegex = RegExp(r'\b\d{4,9}\b');
    double maxRaw = 0.0;
    for (final match in intRegex.allMatches(rawText)) {
      final rawStr = match.group(0)!;
      if (rawStr.startsWith('0') || (rawStr.length == 4 && rawStr.startsWith('20'))) continue;
      final val = double.tryParse(rawStr) ?? 0.0;
      if (val > maxRaw && _isValidAmount(val)) {
        maxRaw = val;
      }
    }
    return maxRaw;
  }

  double? _searchAmountByKeywords(List<String> lines, List<String> keywords) {
    for (int i = 0; i < lines.length; i++) {
      final lineLower = lines[i].toLowerCase();
      final hasKeyword = keywords.any((k) => lineLower.contains(k));
      if (!hasKeyword) continue;

      final amountInLine = _extractMoneyFromLine(lines[i]);
      if (amountInLine != null && amountInLine > 0) return amountInLine;

      if (i + 1 < lines.length) {
        final amountInNextLine = _extractMoneyFromLine(lines[i + 1]);
        if (amountInNextLine != null && amountInNextLine > 0) return amountInNextLine;
      }
    }
    return null;
  }

  double? _extractMoneyFromLine(String line) {
    final moneyPatterns = [
      RegExp(r'((?:\d{1,3}(?:[.,]\d{3})+(?:[.,]\d{2})?|\d+))\s*(?:vnđ|vnd|đồng|dong|đ|d)\b', caseSensitive: false),
      RegExp(r'\b(\d+)\s*[kK]\b'),
      RegExp(r'\b(\d{1,3}(?:[.,]\d{3})+(?:[.,]\d{2})?)\b'),
      RegExp(r'\b(\d{4,9})\b'),
    ];

    double maxLineMoney = 0.0;

    for (final pat in moneyPatterns) {
      final matches = pat.allMatches(line);
      for (final match in matches) {
        final numStr = (match.groupCount >= 1 ? match.group(1) : match.group(0)) ?? match.group(0)!;
        double? val;
        if (pat == moneyPatterns[1]) {
          val = (double.tryParse(numStr) ?? 0) * 1000;
        } else {
          val = _parseMoneyString(numStr);
        }
        if (val != null && _isValidAmount(val) && val > maxLineMoney) {
          maxLineMoney = val;
        }
      }
    }
    return maxLineMoney > 0 ? maxLineMoney : null;
  }

  double? _parseMoneyString(String? str) {
    if (str == null) return null;
    var clean = str.trim();
    if (clean.endsWith(',00') || clean.endsWith('.00')) {
      clean = clean.substring(0, clean.length - 3);
    } else if (clean.endsWith(',0') || clean.endsWith('.0')) {
      clean = clean.substring(0, clean.length - 2);
    }
    clean = clean.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(clean);
  }

  bool _isValidAmount(double amount) {
    return amount >= 500 && amount <= 500000000;
  }

  // 3. Extract Merchant
  String _extractMerchant(String rawText, List<String> lines) {
    // PASS 1: Check lines with explicit seller prefixes like "Người bán: Tra Sua SA" or "gọi bán: Tra Sua SA"
    final sellerPrefixRegex = RegExp(r'(?:người bán|nguoi ban|gọi bán|goi ban|bán hàng)\s*[:\-]\s*(.+)', caseSensitive: false);
    for (final line in lines) {
      final match = sellerPrefixRegex.firstMatch(line);
      if (match != null && match.group(1) != null) {
        final seller = match.group(1)!.trim();
        if (seller.length >= 3 && seller.length <= 40) {
          return seller;
        }
      }
    }

    // PASS 2: Check lines starting with store indicators (Trà sữa, Cà phê, Quán, Tiệm, v.v.)
    final storePrefixes = [
      'trà sữa', 'tra sua', 'cà phê', 'ca phe', 'coffee', 'tea',
      'quán', 'quan', 'tiệm', 'tiem', 'nhà hàng', 'nha hang',
      'công ty', 'cong ty', 'hộ kinh doanh', 'cửa hàng', 'cua hang',
      'bakery', 'shop', 'store'
    ];
    for (final line in lines.take(10)) {
      final lower = line.toLowerCase();
      for (final prefix in storePrefixes) {
        if (lower.startsWith(prefix) && line.length >= 4 && line.length <= 45) {
          return line;
        }
      }
    }

    // PASS 3: Check well-known brand names
    const recognizedBrands = [
      'cgv', 'lotte cinema', 'bhd', 'galaxy',
      'highlands', 'phúc long', 'phuc long', 'starbucks', 'the coffee house',
      'kfc', 'lotteria', 'jollibee', 'pizza hut', 'domino',
      'winmart', 'bách hóa xanh', 'circle k', 'family mart', 'familymart',
      'gs25', 'ministop', '7-eleven', 'fahasa',
      'grab', 'be', 'petrolimex', 'fpt shop', 'thegioididong', 'thế giới di động',
      'cellphones', 'điện máy xanh'
    ];

    final lowerRaw = rawText.toLowerCase();
    for (var brand in recognizedBrands) {
      if (lowerRaw.contains(brand)) {
        // Prefer exact line containing the brand
        for (var line in lines.take(8)) {
          final lLow = line.toLowerCase();
          if (lLow.contains(brand) && line.length >= 3 && line.length <= 40 && !lLow.contains('hóa đơn') && !lLow.contains('bill')) {
            return _formatBrandName(line);
          }
        }
        return _formatBrandName(brand);
      }
    }

    // Comprehensive blacklist of receipt table headers & invoice metadata
    final ignoreKeywords = [
      // Headers & invoice metadata
      'hóa đơn', 'hoa don', 'bill', 'receipt', 'vat', 'phiếu', 'phieu',
      'mã hd', 'ma hd', 'số hd', 'so hd', 'số:', 'so:', 'stt',
      'mã cqt', 'ký hiệu',
      'ngày', 'ngay', 'date', 'time', 'giờ', 'gio',
      'đt', 'dt', 'tel', 'phone', 'hotline',
      'địa chỉ', 'dia chi', 'address', 'chi nhánh', 'chinhanh',
      'khách hàng', 'khach hang', 'bàn', 'ban', 'thu ngân', 'thu ngan',
      'welcome', 'cảm ơn', 'cam on', 'thank you', 'thanks',
      'please', 'scan', 'wifi', 'password', 'pass', 'qr',

      // Table columns and money terms (Fixes "Đơn giá" bug!)
      'đơn giá', 'don gia', 'thành tiền', 'thanh tien', 'tiền hàng', 'tien hang',
      'số lượng', 'so luong', 'sl', 'chiết khấu', 'chiet khau', 'giảm giá', 'giam gia',
      'tên món', 'ten mon', 'tên hàng', 'ten hang', 'mặt hàng', 'mat hang',
      'cộng tiền', 'cong tien', 'tiền mặt', 'tien mat', 'tiền thối', 'tien thua', 'tiền thừa',
      'tổng cộng', 'tong cong', 'thanh toán', 'thanh toan', 'phải trả', 'phai tra'
    ];

    // PASS 4: Pick first clean header line from top
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (line.length < 3 || line.length > 50) continue;
      if (ignoreKeywords.any((k) => lower.contains(k))) continue;
      
      final lettersCount = line.replaceAll(RegExp(r'[^a-zA-ZÀ-ỹ]'), '').length;
      if (lettersCount < 3) continue;

      return _formatBrandName(line);
    }

    return "General Store";
  }

  String _formatBrandName(String key) {
    if (key.toLowerCase() == 'cgv') return 'CGV Cinema';
    return key.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // 4. Auto-Categorization (Prioritizes Merchant and Strong Entertainment Keywords)
  ExpenseCategory _extractCategory(String rawText, String merchant) {
    final lowerMerchant = merchant.toLowerCase();
    final lowerRaw = rawText.toLowerCase();

    // PRIORITY 1: Entertainment & Cinema (Overrides items like Bắp, Nước)
    final entertainmentBrands = [
      'cgv', 'cinema', 'galaxy', 'bhd', 'lotte cinema', 'karaoke', 'billiards', 'bowling', 'rạp chiếu', 'rap chieu'
    ];
    for (var b in entertainmentBrands) {
      if (lowerMerchant.contains(b) || lowerRaw.contains(b)) {
        return ExpenseCategory.entertainment;
      }
    }

    // PRIORITY 2: Movie ticket & showtime keywords
    final movieTicketKeywords = [
      'vé vào phòng chiếu', 've vao phong chieu', 'phòng chiếu', 'phong chieu',
      'movie ticket', 'auditorium', 'showtime', 'giờ chiếu', 'gio chieu', 'suất chiếu', 'suat chieu'
    ];
    for (var kw in movieTicketKeywords) {
      if (lowerRaw.contains(kw)) {
        return ExpenseCategory.entertainment;
      }
    }

    // PRIORITY 3: Education
    final studyKeywords = [
      'fahasa', 'nhà sách', 'nha sach', 'nhà sách phương nam', 'văn phòng phẩm',
      'học phí', 'hoc phi', 'giáo trình', 'giao trinh', 'đào tạo'
    ];
    for (var kw in studyKeywords) {
      if (lowerMerchant.contains(kw) || lowerRaw.contains(kw)) {
        return ExpenseCategory.study;
      }
    }

    // PRIORITY 4: Transportation
    final travelKeywords = [
      'grab', 'grabbike', 'grabcar', 'bebike', 'becar', 'xanh sm', 'petrolimex',
      'tiền xăng', 'đổ xăng', 'xăng', 'xang', 'vé xe', 'vé tàu', 'giao hàng'
    ];
    for (var kw in travelKeywords) {
      if (lowerMerchant.contains(kw) || lowerRaw.contains(kw)) {
        return ExpenseCategory.travel;
      }
    }

    // PRIORITY 5: Electronics & Gear
    final gearKeywords = [
      'fpt', 'thegioididong', 'thế giới di động', 'cellphones', 'dienmayxanh',
      'điện máy xanh', 'tai nghe', 'bàn phím', 'chuột', 'laptop'
    ];
    for (var kw in gearKeywords) {
      if (lowerMerchant.contains(kw) || lowerRaw.contains(kw)) {
        return ExpenseCategory.gear;
      }
    }

    // PRIORITY 6: Food & Dining
    for (var entry in _categoryRules.entries) {
      if (entry.value == ExpenseCategory.food) {
        if (lowerMerchant.contains(entry.key) || lowerRaw.contains(entry.key)) {
          return ExpenseCategory.food;
        }
      }
    }

    return ExpenseCategory.other;
  }

  void dispose() {
    _textRecognizer.close();
  }
}

class ParsedReceipt {
  final double amount;
  final DateTime date;
  final String merchant;
  final ExpenseCategory category;
  final String rawText;

  ParsedReceipt({
    required this.amount,
    required this.date,
    required this.merchant,
    required this.category,
    required this.rawText,
  });
}
