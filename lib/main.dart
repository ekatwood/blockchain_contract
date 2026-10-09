import 'package:flutter/material.dart';

void main() {
  runApp(const CryptoApp());
}

class CryptoApp extends StatelessWidget {
  const CryptoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web3 Contract Portal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainContractFormPage(),
      routes: {
        '/transaction-details': (context) => const TransactionDetailsPage(),
      },
    );
  }
}

// ==========================================
// 1. MAIN PAGE (FORM & SELECTORS)
// ==========================================

class MainContractFormPage extends StatefulWidget {
  const MainContractFormPage({super.key});

  @override
  State<MainContractFormPage> createState() => _MainContractFormPageState();
}

class _MainContractFormPageState extends State<MainContractFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Blockchain Selection
  String _selectedBlockchain = 'Ethereum';
  final List<String> _blockchains = [
    'Ethereum',
    'Arbitrum',
    'Optimism',
    'Avalanche',
    'Polygon'
  ];

  // Contract Action Selection
  String _selectedAction = 'Mint Token';
  final List<String> _actions = [
    'Mint Token',
    'Instantiate NFT',
    'Set Price Swap',
  ];

  // Form Controllers
  // Mint Token fields
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // Instantiate NFT fields
  final TextEditingController _nftNameController = TextEditingController();
  final TextEditingController _nftSymbolController = TextEditingController();
  final TextEditingController _baseUriController = TextEditingController();

  // Set Price Swap fields
  final TextEditingController _tokenInController = TextEditingController();
  final TextEditingController _tokenOutController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _nftNameController.dispose();
    _nftSymbolController.dispose();
    _baseUriController.dispose();
    _tokenInController.dispose();
    _tokenOutController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onSignPressed() async {
    if (_formKey.currentState!.validate()) {
      // 1. Show Splash / Loading Screen
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const SplashLoadingDialog();
        },
      );

      // Simulate network / blockchain transaction delay (e.g., 3 seconds)
      await Future.delayed(const Duration(seconds: 3));

      // Close Splash Dialog
      if (!mounted) return;
      Navigator.of(context).pop();

      // Gather transaction payload details to pass to the next screen
      final transactionData = {
        'blockchain': _selectedBlockchain,
        'action': _selectedAction,
        'txHash': '0x7f8a...3b21', // Simulated Tx Hash
        'timestamp': DateTime.now().toString(),
        'details': _getTransactionDetailsMap(),
      };

      // 2. Navigate to Transaction Details screen
      Navigator.pushNamed(
        context,
        '/transaction-details',
        arguments: transactionData,
      );
    }
  }

  Map<String, String> _getTransactionDetailsMap() {
    switch (_selectedAction) {
      case 'Mint Token':
        return {
          'Recipient': _recipientController.text,
          'Amount': _amountController.text,
        };
      case 'Instantiate NFT':
        return {
          'NFT Name': _nftNameController.text,
          'Symbol': _nftSymbolController.text,
          'Base URI': _baseUriController.text,
        };
      case 'Set Price Swap':
        return {
          'Token In': _tokenInController.text,
          'Token Out': _tokenOutController.text,
          'Price': _priceController.text,
        };
      default:
        return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web3 Smart Contract Interface'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Text(
                      'Configure Transaction',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Blockchain Selector Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedBlockchain,
                      decoration: const InputDecoration(
                        labelText: 'Select Blockchain',
                        border: OutlineInputBorder(),
                      ),
                      items: _blockchains.map((String chain) {
                        return DropdownMenuItem<String>(
                          value: chain,
                          child: Text(chain),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedBlockchain = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Smart Contract Action Selector Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedAction,
                      decoration: const InputDecoration(
                        labelText: 'Select Contract Action',
                        border: OutlineInputBorder(),
                      ),
                      items: _actions.map((String action) {
                        return DropdownMenuItem<String>(
                          value: action,
                          child: Text(action),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedAction = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Dynamic Form Fields Based on Selected Action
                    if (_selectedAction == 'Mint Token') ...[
                      TextFormField(
                        controller: _recipientController,
                        decoration: const InputDecoration(
                          labelText: 'Recipient Address',
                          hintText: '0x...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter recipient address'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount to Mint',
                          hintText: '100',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter an amount'
                            : null,
                      ),
                    ] else if (_selectedAction == 'Instantiate NFT') ...[
                      TextFormField(
                        controller: _nftNameController,
                        decoration: const InputDecoration(
                          labelText: 'NFT Collection Name',
                          hintText: 'CryptoArt',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a collection name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nftSymbolController,
                        decoration: const InputDecoration(
                          labelText: 'Token Symbol',
                          hintText: 'ART',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a symbol'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _baseUriController,
                        decoration: const InputDecoration(
                          labelText: 'Base URI',
                          hintText: 'ipfs://...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a base URI'
                            : null,
                      ),
                    ] else if (_selectedAction == 'Set Price Swap') ...[
                      TextFormField(
                        controller: _tokenInController,
                        decoration: const InputDecoration(
                          labelText: 'Token In Address',
                          hintText: '0x...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter Token In address'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tokenOutController,
                        decoration: const InputDecoration(
                          labelText: 'Token Out Address',
                          hintText: '0x...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter Token Out address'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Target Swap Price',
                          hintText: '1.5',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a price'
                            : null,
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Sign Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _onSignPressed,
                      child: const Text(
                        'Sign & Broadcast',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. SPLASH / LOADING SCREEN DIALOG
// ==========================================

class SplashLoadingDialog extends StatelessWidget {
  const SplashLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text(
                'Broadcasting Transaction...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please wait while your wallet signs the contract.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. TRANSACTION DETAILS SCREEN
// ==========================================

class TransactionDetailsPage extends StatelessWidget {
  const TransactionDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final String blockchain = args['blockchain'];
    final String action = args['action'];
    final String txHash = args['txHash'];
    final String timestamp = args['timestamp'];
    final Map<String, String> details = args['details'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green, size: 32),
                      SizedBox(width: 12),
                      Text(
                        'Transaction Successful!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  ListTile(
                    title: const Text('Blockchain'),
                    trailing: Text(
                      blockchain,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    title: const Text('Action Type'),
                    trailing: Text(
                      action,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    title: const Text('Transaction Hash'),
                    subtitle: Text(txHash),
                  ),
                  ListTile(
                    title: const Text('Timestamp'),
                    subtitle: Text(timestamp),
                  ),
                  const Divider(height: 32),
                  const Text(
                    'Form Parameters:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...details.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key,
                              style: const TextStyle(color: Colors.grey)),
                          Text(entry.value,
                              style:
                              const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(
                          context, (route) => route.isFirst);
                    },
                    child: const Text('Back to Home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}