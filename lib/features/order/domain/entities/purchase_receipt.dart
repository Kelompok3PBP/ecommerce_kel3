import 'package:ecommerce/features/product/domain/entities/product.dart';

class PurchaseReceipt extends Product {
  final String _orderId;
  final String _orderDate;
  final String _customerName;
  final String _customerEmail;
  final String _customerPhone;
  final String _shippingAddress;
  final List<dynamic> _items;
  final double _subtotal;
  final double _shippingCost;
  final double _tax;
  final double _discount;
  final double _totalAmount;
  final String _paymentMethod;
  final String _paymentStatus;
  final String _purchaseStructure;
  final int _installmentMonths;
  final double _installmentAmount;

  PurchaseReceipt({
    required int id,
    required String title,
    required double price,
    required String description,
    required String category,
    required String image,
    required double rating,
    required int ratingCount,
    // PurchaseReceipt specific fields
    required String orderId,
    required String orderDate,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String shippingAddress,
    required List<dynamic> items,
    required double subtotal,
    required double shippingCost,
    required double tax,
    required double discount,
    required double totalAmount,
    required String paymentMethod,
    required String paymentStatus,
    required String purchaseStructure,
    required int installmentMonths,
    required double installmentAmount,
  }) : _orderId = orderId,
       _orderDate = orderDate,
       _customerName = customerName,
       _customerEmail = customerEmail,
       _customerPhone = customerPhone,
       _shippingAddress = shippingAddress,
       _items = items,
       _subtotal = subtotal,
       _shippingCost = shippingCost,
       _tax = tax,
       _discount = discount,
       _totalAmount = totalAmount,
       _paymentMethod = paymentMethod,
       _paymentStatus = paymentStatus,
       _purchaseStructure = purchaseStructure,
       _installmentMonths = installmentMonths,
       _installmentAmount = installmentAmount,
       super(
         id: id,
         title: title,
         price: price,
         description: description,
         category: category,
         image: image,
         rating: rating,
         ratingCount: ratingCount,
       );

  // Getters - controlled access to private fields (ENCAPSULATION)
  String get orderId => _orderId;
  String get orderDate => _orderDate;
  String get customerName => _customerName;
  String get customerEmail => _customerEmail;
  String get customerPhone => _customerPhone;
  String get shippingAddress => _shippingAddress;
  List<dynamic> get items => List.unmodifiable(_items);
  double get subtotal => _subtotal;
  double get shippingCost => _shippingCost;
  double get tax => _tax;
  double get discount => _discount;
  double get totalAmount => _totalAmount;
  String get paymentMethod => _paymentMethod;
  String get paymentStatus => _paymentStatus;
  String get purchaseStructure => _purchaseStructure;
  int get installmentMonths => _installmentMonths;
  double get installmentAmount => _installmentAmount;

  /// Override validateData from parent class - POLYMORPHISM
  /// Validates both product data and purchase-specific data
  /// More lenient than parent for purchase receipt context
  @override
  bool validateData() {
    // For PurchaseReceipt, we validate receipt-specific fields
    // Parent validation can be more strict, but we relax here for receipts
    return _orderId.isNotEmpty &&
        _customerName.isNotEmpty &&
        _customerEmail.isNotEmpty &&
        _totalAmount >= 0;
  }

  /// POLYMORPHISM - Override to provide PurchaseReceipt-specific display name
  @override
  String getDisplayName() =>
      'Struk Pembelian - ${_orderId.isNotEmpty ? _orderId : title}';

  /// POLYMORPHISM - Override to calculate final price including tax and shipping
  @override
  double calculateFinalPrice() => _totalAmount;

  /// POLYMORPHISM - Override to identify this as a purchase receipt product type
  @override
  String getProductType() => 'PURCHASE_RECEIPT';

  /// Calculate remaining installment balance - specialized method
  double getRemainingBalance(int paidMonths) {
    if (paidMonths < 0 || paidMonths > _installmentMonths) {
      throw ArgumentError('Invalid paid months');
    }
    return _totalAmount - (_installmentAmount * paidMonths);
  }

  /// Check if purchase is completed
  bool isPurchaseCompleted() {
    return _paymentStatus.toLowerCase() == 'completed' ||
        _paymentStatus.toLowerCase() == 'paid';
  }

  factory PurchaseReceipt.fromJson(Map<String, dynamic> json) {
    String _s(String a, String b) => (json[a] ?? json[b] ?? '').toString();
    double _d(String a, String b) {
      final v = json[a] ?? json[b] ?? 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    int _i(String a, String b) {
      final v = json[a] ?? json[b] ?? 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    List<dynamic> _l(String a, String b) =>
        (json[a] ?? json[b] ?? []) as List<dynamic>;

    final ratingData = json['rating'] ?? {};

    return PurchaseReceipt(
      // Product parent fields
      id: json['id'] ?? json['product_id'] ?? 0,
      title: json['title'] ?? json['product_title'] ?? 'Produk Tanpa Nama',
      price: _d('price', 'product_price'),
      description: json['description'] ?? json['product_description'] ?? '',
      category: json['category'] ?? json['product_category'] ?? 'Uncategorized',
      image:
          json['image'] ??
          json['product_image'] ??
          "https://cdn-icons-png.flaticon.com/512/869/869636.png",
      rating: (ratingData['rate'] ?? 0).toDouble(),
      ratingCount: ratingData['count'] ?? 0,
      // PurchaseReceipt specific fields
      orderId: _s('orderId', 'order_id'),
      orderDate: _s('orderDate', 'order_date'),
      customerName: _s('customerName', 'customer_name'),
      customerEmail: _s('customerEmail', 'customer_email'),
      customerPhone: _s('customerPhone', 'customer_phone'),
      shippingAddress: _s('shippingAddress', 'shipping_address'),
      items: _l('items', 'items'),
      subtotal: _d('subtotal', 'subtotal'),
      shippingCost: _d('shippingCost', 'shipping_cost'),
      tax: _d('tax', 'tax'),
      discount: _d('discount', 'discount'),
      totalAmount: _d('totalAmount', 'total_amount'),
      paymentMethod: _s('paymentMethod', 'payment_method'),
      paymentStatus: _s('paymentStatus', 'payment_status'),
      purchaseStructure: _s('purchaseStructure', 'purchase_structure'),
      installmentMonths: _i('installmentMonths', 'installment_months'),
      installmentAmount: _d('installmentAmount', 'installment_amount'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      // Parent Product fields
      ...super.toJson(),
      // PurchaseReceipt specific fields
      'orderId': _orderId,
      'orderDate': _orderDate,
      'customerName': _customerName,
      'customerEmail': _customerEmail,
      'customerPhone': _customerPhone,
      'shippingAddress': _shippingAddress,
      'items': _items,
      'subtotal': _subtotal,
      'shippingCost': _shippingCost,
      'tax': _tax,
      'discount': _discount,
      'totalAmount': _totalAmount,
      'paymentMethod': _paymentMethod,
      'paymentStatus': _paymentStatus,
      'purchaseStructure': _purchaseStructure,
      'installmentMonths': _installmentMonths,
      'installmentAmount': _installmentAmount,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PurchaseReceipt &&
        super == other &&
        other._orderId == _orderId;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, _orderId.hashCode);
}
