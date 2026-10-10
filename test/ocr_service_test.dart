import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/services/ocr_service.dart';
import 'package:ocr_expense_tracker/models/transaction.dart';

void main() {
  late OcrService ocrService;

  setUp(() {
    ocrService = OcrService();
  });

  group('OcrService Text Parsing Tests', () {
    test('Extract amount, date, merchant and ENTERTAINMENT category for CGV Cinema ticket', () {
      const cgvTicketSample = '''
CGV
CJ CGV VIETNAM
CGV HÙNG VƯƠNG PLAZA
Đ/C: Tầng 7, Hùng Vương Plaza, 126 Hồng Bàng, Q.5, TP.HCM
Hotline: 1900 6017
Giờ in: 18:45 - 10/10/2026
VÉ VÀO PHÒNG CHIẾU
(MOVIE TICKET)
Phim: ĐẤT RỪNG PHƯƠNG NAM (2D)
Phòng chiếu (Auditorium): CINEMA 3
Ngày (Date): 10/10/2026 (Thứ Bảy)
Giờ chiếu (Showtime): 19:30 ~ 21:40
Ghế (Seat): H11, H12 (Standard)
Vé 2D Standard (2x) 220,000đ
Combo 1 Bắp 2 Nước 115,000đ
Tổng cộng (Total): 335,000đ
Khuyến mãi/Giảm giá: 0đ
Khách thanh toán: 335,000đ
(Đã bao gồm 10% VAT)
Phương thức: Thẻ ngân hàng (Visa/Master)
Mã giao dịch / Mã vé:
Booking No: 84729104
||||||||||||||||||||||||||||||||
354729141
Chúc quý khách xem phim vui vẻ!
Vui lòng giữ vé để kiểm tra khi vào phòng chiếu.
Website: www.cgv.vn
''';
      final receipt = ocrService.parseText(cgvTicketSample);
      expect(receipt.amount, equals(335000.0));
      expect(receipt.merchant, contains('CGV'));
      expect(receipt.category, equals(ExpenseCategory.entertainment)); // MUST be Entertainment!
      expect(receipt.date.day, equals(10));
      expect(receipt.date.month, equals(10));
      expect(receipt.date.year, equals(2026));
    });

    test('Extract amount and merchant from Milk Tea receipt (TRA SUA SA)', () {
      const milkTeaSample = '''
SA
Đơn giá
gọi bán: Tra Sua SA
Ngày bán: 11:30 01/10 / 2018
Khách hang:
63,000
TRÀ SỮA SA
HOÁ ĐƠN BÁN HÀNG
Đ/C: Đường D1, Mỹ Phước 1, Bến Cát, Bình Dương
Hotline: 0909692314-0938800722
Cộng tiền hàng:
Chiết khấu: 0
Tổng cộng: 2,646,000
HD001882 Ban 1[A]
Sữa tươi trân châu đường đen
SL: 42
Thành tiền: 1,260,000
2,646,000
''';
      final receipt = ocrService.parseText(milkTeaSample);
      expect(receipt.amount, equals(2646000.0));
      expect(receipt.merchant, contains('Tra Sua SA'));
      expect(receipt.category, equals(ExpenseCategory.food));
      expect(receipt.date.day, equals(1));
      expect(receipt.date.month, equals(10));
      expect(receipt.date.year, equals(2018));
    });

    test('Extract amount when formatted as Tổng cộng: 80.000 without currency', () {
      const sample = '''
HIGHLANDS COFFEE
Dia chi: 123 Nguyen Van Linh
Ngay: 10/10/2026
Tra sen vang: 45.000
Phin sua da: 35.000
Tong cong: 80.000
Tien mat: 100.000
Tien thua: 20.000
''';
      final receipt = ocrService.parseText(sample);
      expect(receipt.amount, equals(80000.0));
      expect(receipt.merchant, contains('Highlands'));
      expect(receipt.category, equals(ExpenseCategory.food));
    });

    test('Extract amount from Vietnamese VAT e-invoice (HÓA ĐƠN GTGT NQ)', () {
      const vatInvoiceSample = '''
CÔNG TY TNHH DỊCH VỤ ĐẦU TƯ NQ
Mã số thuế: 0111158747
Địa chỉ: Lô 24 Khu TT Xí Nghiệp Máy Bay, Hà Nội
HÓA ĐƠN GIÁ TRỊ GIA TĂNG
Ngày 08 tháng 02 năm 2026
Số: 00000708
1. NƯỚC NGỌT COCA-COLA 140.000,00
2. SUẤT BUFFET 498K 1.992.000,00
Thuế suất 8%: 1.992.000,00 159.360,00 2.151.360,00
Thuế suất 10%: 140.000,00 14.000,00 154.000,00
Tổng cộng: 2.132.000,00 173.360,00 2.305.360,00
Số tiền viết bằng chữ: Hai triệu ba trăm linh năm nghìn ba trăm sáu mươi đồng chẵn.
''';
      final receipt = ocrService.parseText(vatInvoiceSample);
      expect(receipt.amount, equals(2305360.0));
      expect(receipt.date.day, equals(8));
      expect(receipt.date.month, equals(2));
      expect(receipt.date.year, equals(2026));
      expect(receipt.merchant, contains('CÔNG TY TNHH DỊCH VỤ ĐẦU TƯ NQ'));
      expect(receipt.category, equals(ExpenseCategory.food));
    });

    test('Extract amount when label is on one line and value is on next line', () {
      const sample = '''
PHÚC LONG COFFEE & TEA
HD: 0012948
TỔNG CỘNG
125.000
Cảm ơn quý khách
''';
      final receipt = ocrService.parseText(sample);
      expect(receipt.amount, equals(125000.0));
      expect(receipt.category, equals(ExpenseCategory.food));
    });

    test('Extract amount with Thanh toán and comma separator', () {
      const sample = '''
WINMART+
Ngay 15/09/2026
Thanh toan: 437,000
Cam on quy khach
''';
      final receipt = ocrService.parseText(sample);
      expect(receipt.amount, equals(437000.0));
      expect(receipt.category, equals(ExpenseCategory.food));
    });

    test('Extract amount with currency symbol đ or VND', () {
      const sample = '''
GRAB VIETNAM
Chuyen xe GrabBike
Thanh toan: 45.000 đ
''';
      final receipt = ocrService.parseText(sample);
      expect(receipt.amount, equals(45000.0));
      expect(receipt.category, equals(ExpenseCategory.travel));
    });

    test('Extract amount with fallback largest formatted number when no total keyword', () {
      const sample = '''
CUA HANG TAP HOA
12/03/2026
Banh mi: 15.000
Nuoc ngot: 20.000
35.000
''';
      final receipt = ocrService.parseText(sample);
      expect(receipt.amount, equals(35000.0));
    });

    test('Filter noise lines like "Please Scan to share" or "Ma HD" for merchant', () {
      const sample = '''
Please Scan to share
Ma HD: 4BY6Y
THE COFFEE HOUSE
Tong tien: 65.000
''';
      final receipt = ocrService.parseText(sample);
      expect(receipt.merchant, contains('The Coffee House'));
      expect(receipt.amount, equals(65000.0));
    });
  });
}
