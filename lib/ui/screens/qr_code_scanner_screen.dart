import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wakelock_plus/wakelock_plus.dart' show WakelockPlus;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../strings_context.dart';
import '../app_theme.dart';

/// QR code scanner screen.
///
/// Will return raw text in [Navigator] result.
class QRCodeScannerScreen extends StatefulWidget {
  const QRCodeScannerScreen({super.key});

  @override
  State<QRCodeScannerScreen> createState() => _QRCodeScannerScreenState();
}

class _QRCodeScannerScreenState extends State<QRCodeScannerScreen> {
  /// [MobileScannerController] to toggle torch.
  final MobileScannerController _controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );

  /// Lock to prevent multiple snackbars.
  bool _hasSnackBar = false;

  @override
  void initState() {
    super.initState();

    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = Stack(
      children: [
        // Scanner
        MobileScanner(
          controller: _controller,
          onDetect: _handleBarcode,
        ),

        // Back arrow
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: kScreenMargin.copyWith(
              top: MediaQuery.of(context).padding.top,
            ),
            child: Semantics(
              label: context.strings.qrCodeScannerBackSemantics,
              button: true,
              excludeSemantics: true,
              child: SquareButton(
                onPressed: () {
                  Navigator.maybePop(context);
                },
                child: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),

        // View finder
        const Align(
          alignment: Alignment.center,
          child: _ViewFinder(),
        ),

        // Toggle torch button
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: kScreenMargin.copyWith(bottom: 128),
            child: SquareButton(
              onPressed: () {
                _controller.toggleTorch();
              },
              child: ValueListenableBuilder<TorchState>(
                valueListenable: _controller.torchState,
                builder: (context, torchState, _) {
                  // TODO This icon is below info panel when text size is 2.0x
                  final icon = switch (torchState) {
                    TorchState.off => Icons.flashlight_on,
                    TorchState.on => Icons.flashlight_off,
                  };

                  final strings = context.strings;
                  final semanticsLabel = switch (torchState) {
                    TorchState.off => strings.qrCodeScannerTorchOnSemantics,
                    TorchState.on => strings.qrCodeScannerTorchOffSemantics,
                  };

                  return Semantics(
                    button: true,
                    label: semanticsLabel,
                    child: Icon(
                      icon,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // Bottom info panel
        const Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: kScreenMargin,
            child: _InfoPanel(),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: body,
    );
  }

  // ignore: non_constant_identifier_names
  Widget SquareButton({
    VoidCallback? onPressed,
    required Widget child,
  }) {
    final colors = Theme.of(context).colorScheme;
    const size = Size(kMinInteractiveDimension, kMinInteractiveDimension);

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: size,
        padding: EdgeInsets.zero,
        backgroundColor: colors.surface,
      ),
      child: child,
    );
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    final barcode = barcodes.barcodes.firstOrNull;

    if (barcode == null) {
      return;
    }

    if (!(barcode.type == BarcodeType.text ||
        barcode.type == BarcodeType.url)) {
      final strings = context.strings;
      final message = strings.qrCodeScannerUnsupportedContentErrorMessage;

      _showError(message);

      return;
    }

    // Stop camera and code scanner
    _controller.dispose();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Navigator.of(context).maybePop(barcode.rawValue);
  }

  void _showError(String message) {
    if (_hasSnackBar) {
      return;
    }

    _hasSnackBar = true;
    final snackBar = SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: context.strings.buttonOKLabel,
        onPressed: () {},
      ),
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(snackBar)
        .closed
        .then((value) => _hasSnackBar = false);
  }
}

/// View with borders only in corners.
class _ViewFinder extends StatelessWidget {
  const _ViewFinder();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return CustomPaint(
      foregroundPainter: _BorderPainter(color),
      child: const SizedBox.square(dimension: 200),
    );
  }
}

/// Custom painter for [_ViewFinder].
class _BorderPainter extends CustomPainter {
  final Paint _paint;

  _BorderPainter(Color color)
      : _paint = Paint()
          ..color = color
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final cornerSide = height * 0.08;
    final offsetLine = height * 0.08;

    final path = Path()
      // top left:
      ..moveTo(cornerSide + offsetLine, 0)
      ..lineTo(cornerSide, 0)
      ..moveTo(cornerSide, 0)
      ..quadraticBezierTo(0, 0, 0, cornerSide)
      ..lineTo(0, cornerSide + offsetLine)

      // bottom left:
      ..moveTo(0, height - cornerSide - offsetLine)
      ..lineTo(0, height - cornerSide)
      ..quadraticBezierTo(0, height, cornerSide, height)
      ..lineTo(cornerSide + offsetLine, height)

      // bottom right
      ..moveTo(width - cornerSide - offsetLine, height)
      ..lineTo(width - cornerSide, height)
      ..quadraticBezierTo(width, height, width, height - cornerSide)
      ..lineTo(width, height - cornerSide - offsetLine)

      // top right
      ..moveTo(width, cornerSide + offsetLine)
      ..lineTo(width, cornerSide)
      ..quadraticBezierTo(width, 0, width - cornerSide, 0)
      ..lineTo(width - cornerSide - offsetLine, 0);

    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(_BorderPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(_BorderPainter oldDelegate) => false;
}

/// Info panel with "i" icon and text.
class _InfoPanel extends StatelessWidget {
  const _InfoPanel();

  @override
  Widget build(BuildContext context) {
    const double iconSize = 80;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: iconSize / 2),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            width: double.infinity,
            padding:
                const EdgeInsets.all(16).add(const EdgeInsets.only(top: 16)),
            child: Text(
              context.strings.qrCodeScannerInfoBody,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SvgPicture.asset(
          "assets/images/info.svg",
          width: iconSize,
          height: iconSize,
        ),
      ],
    );
  }
}

@widgetbook.UseCase(
  path: '[Core]',
  name: '',
  type: _ViewFinder,
)
Widget previewViewFinder(BuildContext context) {
  return const Center(
    child: _ViewFinder(),
  );
}

@widgetbook.UseCase(
  path: '[Screens]',
  name: '',
  type: QRCodeScannerScreen,
)
Widget previewQRCodeScannerScreen(BuildContext context) {
  return const QRCodeScannerScreen();
}
