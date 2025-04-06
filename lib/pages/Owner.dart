class Owner {
  int id;
  String name;
  int numImm;
  int numApp;
  double amount; // Montant total à payer
  double paidAmount = 0; // Montant déjà réglé
  String phone;
  String email;
  DateTime contractDate;
  List<Map<String, String>> payments = [];

  Owner({
    required this.id,
    required this.name,
    required this.numImm,
    required this.numApp,
    required this.amount,
    required this.phone,
    required this.email,
    required this.contractDate,
  });

  double get remainingAmount => amount - paidAmount;

  void updatePayments(double amountPaid) {
    paidAmount += amountPaid;
  }
  void addPayment(Map<String, String> payment) {
    payments.add(payment);
    updatePayments(double.parse(payment["montant"]!.split(" ")[0])); // Met à jour le montant payé
  }
}
