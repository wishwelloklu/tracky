import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tracky_mobile/features/official/screens/verification_screen.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _screenOpened = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.camera_front),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Scanner
          MobileScanner(controller: cameraController, onDetect: _foundBarcode),

          // Overlay with instructions
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),

          // Scanning frame
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Instructions overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black.withValues(alpha: 0.7),
              child: Column(
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Position QR Code within the frame',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The scanner will automatically detect the QR code',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Bottom instructions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Colors.black.withValues(alpha: 0.7),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionButton(
                        icon: Icons.flash_on,
                        label: 'Flash',
                        onPressed: () => cameraController.toggleTorch(),
                      ),
                      _ActionButton(
                        icon: Icons.camera_front,
                        label: 'Flip',
                        onPressed: () => cameraController.switchCamera(),
                      ),
                      _ActionButton(
                        icon: Icons.keyboard,
                        label: 'Manual',
                        onPressed: _navigateToManualEntry,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Can\'t scan? Use manual entry instead',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _foundBarcode(BarcodeCapture capture) {
    if (_screenOpened) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String code = barcodes.first.rawValue ?? '';
      if (code.isNotEmpty) {
        _screenOpened = true;
        _navigateToVerification(code);
      }
    }
  }

  void _navigateToVerification(String tagId) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => VerificationScreen(tagId: tagId)),
    );
  }

  void _navigateToManualEntry() {
    Navigator.of(context).pop();
    // This would navigate to manual entry screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manual entry screen would open')),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white, size: 32),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
