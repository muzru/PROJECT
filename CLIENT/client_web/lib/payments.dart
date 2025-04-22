import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentGatewayPage extends StatefulWidget {
  final double amount;
  final String workName;
  final int workRequestId; // Added to identify the work request
  final Function onPaymentSuccess;

  const PaymentGatewayPage({
    super.key,
    required this.amount,
    required this.workName,
    required this.workRequestId, // Required parameter for the work request ID
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentGatewayPage> createState() => _PaymentGatewayPageState();
}

class _PaymentGatewayPageState extends State<PaymentGatewayPage> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = true;
  OutlineInputBorder? border;
  late final GlobalKey<FormState> formKey; // Moved to initState
  final supabase = Supabase.instance.client; // Supabase client instance

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>(); // Initialize a new key for each instance
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.7),
        width: 2.0,
      ),
      borderRadius: BorderRadius.circular(8),
    );
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) return 'Card number is required';
    if (!RegExp(r'^\d{16}$').hasMatch(value.replaceAll(' ', ''))) {
      return 'Enter a valid 16-digit card number';
    }
    return null;
  }

  String? _validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) return 'Expiry date is required';
    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(value)) {
      return 'Enter a valid MM/YY date';
    }
    return null;
  }

  String? _validateCvv(String? value) {
    if (value == null || value.isEmpty) return 'CVV is required';
    if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
      return 'Enter a valid 3-4 digit CVV';
    }
    return null;
  }

  String? _validateCardHolder(String? value) {
    if (value == null || value.isEmpty) return 'Cardholder name is required';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Enter a valid name';
    }
    return null;
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  Future<void> _processPayment() async {
    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF2E6F40)),
                SizedBox(height: 20),
                Text(
                  'Processing Payment...',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Log the workRequestId for debugging
      print("Updating workRequestId: ${widget.workRequestId}");

      // Fetch the work_id associated with the workrequest_id
      final workRequestResponse = await supabase
          .from('tbl_workrequest')
          .select('work_id')
          .eq('workrequest_id', widget.workRequestId)
          .single();

      final workId = workRequestResponse['work_id'] as int;

      // Update workrequest_status to 5 in tbl_workrequest
      final workRequestUpdate = await supabase
          .from('tbl_workrequest')
          .update({'workrequest_status': 5})
          .eq('workrequest_id', widget.workRequestId)
          .select();

      if (workRequestUpdate.isEmpty) {
        throw Exception(
            'No rows updated in tbl_workrequest - check workRequestId or permissions');
      }

      // Update work_status to 1 in tbl_work
      final workUpdate = await supabase
          .from('tbl_work')
          .update({'work_status': 1}) // Assuming 1 means active/completed
          .eq('work_id', workId)
          .select();

      if (workUpdate.isEmpty) {
        throw Exception(
            'No rows updated in tbl_work - check workId or permissions');
      }

      print(
          "Update responses: workRequest: $workRequestUpdate, work: $workUpdate");

      if (mounted) Navigator.pop(context);

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Payment Successful',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E6F40),
                ),
              ),
              content: Text(
                'Your payment of \$${widget.amount.toStringAsFixed(2)} for ${widget.workName} has been processed successfully.',
                style: GoogleFonts.poppins(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    if (mounted) widget.onPaymentSuccess();
                  },
                  child: Text(
                    'OK',
                    style: GoogleFonts.poppins(color: const Color(0xFF2E6F40)),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e')),
        );
        print("Error during payment: $e"); // Log the error for debugging
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    return Material(
      color: const Color(0xFFF5F7F5),
      child: Stack(
        children: [
          // Background design for desktop
          if (isDesktop)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: screenWidth * 0.4,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF68BA7F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: -100,
                      left: -100,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    // Content
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/newlogo.png", // Replace with your logo asset
                              height: 120,
                              width: 120,
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              "Skill Connect",
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Connect with top freelancers and clients worldwide",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: Colors.white),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "Find quality freelancers for your projects",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: Colors.white),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "Secure payments and project management",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: Colors.white),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "24/7 support for all your needs",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Payment Form
          Align(
            alignment: isDesktop ? Alignment.centerRight : Alignment.center,
            child: Container(
              width: isDesktop ? screenWidth * 0.6 : double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? screenWidth * 0.1 : 20,
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    width: isDesktop ? 450 : double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (!isDesktop)
                          Image.asset(
                            "assets/newlogo.png", // Replace with your logo asset
                            height: 100,
                            width: 100,
                          ),
                        const SizedBox(height: 20),
                        const Text(
                          "Payment Gateway",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E6F40),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Pay \$${widget.amount.toStringAsFixed(2)} for ${widget.workName}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          height: 180,
                          child: CreditCardWidget(
                            cardBgColor: const Color(0xFF2E6F40),
                            glassmorphismConfig: useGlassMorphism
                                ? Glassmorphism(
                                    blurX: 8.0,
                                    blurY: 8.0,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.grey.withOpacity(0.1),
                                        Colors.white.withOpacity(0.1),
                                      ],
                                      stops: const [0.3, 0.7],
                                    ),
                                  )
                                : null,
                            cardNumber: cardNumber,
                            expiryDate: expiryDate,
                            cardHolderName: cardHolderName,
                            cvvCode: cvvCode,
                            showBackView: isCvvFocused,
                            obscureCardNumber: true,
                            obscureCardCvv: true,
                            isHolderNameVisible: true,
                            isSwipeGestureEnabled: true,
                            onCreditCardWidgetChange:
                                (CreditCardBrand creditCardBrand) {},
                            customCardTypeIcons: <CustomCardTypeIcon>[
                              CustomCardTypeIcon(
                                cardType: CardType.mastercard,
                                cardImage: Image.network(
                                  'https://raw.githubusercontent.com/SimformSolutionsPvtLtd/flutter_credit_card/master/example/assets/mastercard.png',
                                  height: 32,
                                  width: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: CreditCardForm(
                            key: formKey, // Use the instance-specific key
                            obscureCvv: true,
                            obscureNumber: true,
                            cardNumber: cardNumber,
                            cvvCode: cvvCode,
                            isHolderNameVisible: true,
                            isCardNumberVisible: true,
                            isExpiryDateVisible: true,
                            cardHolderName: cardHolderName,
                            expiryDate: expiryDate,
                            onCreditCardModelChange: onCreditCardModelChange,
                            cardNumberValidator: _validateCardNumber,
                            expiryDateValidator: _validateExpiryDate,
                            cvvValidator: _validateCvv,
                            cardHolderValidator: _validateCardHolder,
                            formKey: formKey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _processPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              "Pay Now",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
