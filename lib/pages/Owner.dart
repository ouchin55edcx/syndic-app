class Owner {
  final String id;
  final String name;
  final int numImm;
  final int numApp;
  final double amount;
  final String phone;
  final String email;
  final DateTime contractDate;
  final double remainingAmount;
  final double paidAmount;
  final List<Map<String, dynamic>> payments;

  Owner({
    required this.id,
    required this.name,
    required this.numImm,
    required this.numApp,
    required this.amount,
    required this.phone,
    required this.email,
    required this.contractDate,
    this.remainingAmount = 0.0,
    this.paidAmount = 0.0,
    List<Map<String, dynamic>>? payments,
  }) : this.payments = payments ?? [];

  void addPayment(Map<String, dynamic> payment) {
    payments.add(payment);
  }
}
