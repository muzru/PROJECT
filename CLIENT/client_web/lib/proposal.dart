import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class ProposalsPage extends StatefulWidget {
  final VoidCallback? onProposalAccepted;

  const ProposalsPage({super.key, this.onProposalAccepted});

  @override
  State<ProposalsPage> createState() => _ProposalsPageState();
}

class _ProposalsPageState extends State<ProposalsPage> {
  final List<Map<String, dynamic>> proposals = [
    {
      "freelancer": "John Doe",
      "proposal": "I can complete this project within a week.",
      "price": 500,
      "status": "pending"
    },
    {
      "freelancer": "Jane Smith",
      "proposal": "Experienced developer with a proven track record.",
      "price": 750,
      "status": "pending"
    },
    {
      "freelancer": "David Lee",
      "proposal": "Can deliver high-quality work within the deadline.",
      "price": 600,
      "status": "pending"
    },
  ];

  late Razorpay _razorpay;
  int selectedProposalIndex = -1;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful: ${response.paymentId}")),
    );
    setState(() {
      proposals[selectedProposalIndex]["status"] = "Accepted";
    });

    // Notify the parent widget (ClientDashboard) about the accepted proposal
    widget.onProposalAccepted?.call();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("External Wallet Selected: ${response.walletName}")),
    );
  }

  void _startPayment(int index) {
    selectedProposalIndex = index;

    var options = {
      'key': 'rzp_test_yourapikey', // Replace with your Razorpay API key
      'amount': proposals[index]["price"] * 100,
      'name': 'Skill Connect',
      'description': 'Payment for Freelancer Proposal',
      'prefill': {'contact': '9876543210', 'email': 'client@example.com'},
    };

    _razorpay.open(options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Proposals"),
        backgroundColor: const Color(0xFF2E6F40),
      ),
      body: ListView.builder(
        itemCount: proposals.length,
        itemBuilder: (context, index) {
          final proposal = proposals[index];

          return Card(
            margin: const EdgeInsets.all(10),
            elevation: 4,
            child: ListTile(
              title: Text(proposal["freelancer"] ?? "Unknown"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(proposal["proposal"] ?? "No details provided"),
                  const SizedBox(height: 5),
                  Text("\$${proposal["price"]}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                    "Status: ${proposal["status"]}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: proposal["status"] == "Accepted"
                          ? Colors.green
                          : proposal["status"] == "Rejected"
                              ? Colors.red
                              : Colors.black,
                    ),
                  ),
                ],
              ),
              trailing: proposal["status"] == "pending"
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle,
                              color: Colors.green),
                          onPressed: () => _startPayment(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              proposals[index]["status"] = "Rejected";
                            });
                          },
                        ),
                      ],
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
