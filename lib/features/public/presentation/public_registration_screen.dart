import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/app_constants.dart';

class PublicRegistrationScreen extends StatefulWidget {
  const PublicRegistrationScreen({super.key});

  @override
  State<PublicRegistrationScreen> createState() =>
      _PublicRegistrationScreenState();
}

class _PublicRegistrationScreenState extends State<PublicRegistrationScreen> {
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _extraCtrl = TextEditingController();

  bool _isSeller = true;
  bool _isLoading = false;
  bool _isLockedRole = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _extraCtrl.dispose();
    super.dispose();
  }

  void _onCodeChanged(String value) {
    if (value.startsWith('carguito::seller::')) {
      setState(() {
        _isSeller = true;
        _isLockedRole = true;
      });
    } else if (value.startsWith('carguito::recipient::')) {
      setState(() {
        _isSeller = false;
        _isLockedRole = true;
      });
    } else {
      setState(() {
        _isLockedRole = false;
      });
    }
  }

  Future<void> _openQrScanner() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const _QrScannerPage(),
      ),
    );

    if (!mounted || result == null || result.trim().isEmpty) {
      return;
    }

    _codeCtrl.text = result.trim();
    _onCodeChanged(result.trim());
  }

  Future<void> _submit() async {
    if (_codeCtrl.text.isEmpty ||
        _nameCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor llena todos los campos, incluyendo la contraseña.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.baseUrl,
          connectTimeout: const Duration(seconds: 10),
        ),
      );

      String actualCompanyId = _codeCtrl.text.trim();
      if (actualCompanyId.contains('::')) {
        actualCompanyId = actualCompanyId.split('::').last;
      }

      if (_isSeller) {
        final payload = {
          'company_id': actualCompanyId,
          'business_name':
              _extraCtrl.text.isEmpty ? _nameCtrl.text : _extraCtrl.text,
          'contact_name': _nameCtrl.text,
          'phone': _phoneCtrl.text,
          'email': _emailCtrl.text,
          'password': _passCtrl.text,
        };
        await dio.post('/public/register-seller', data: payload);
      } else {
        final payload = {
          'company_id': actualCompanyId,
          'full_name': _nameCtrl.text,
          'phone': _phoneCtrl.text,
          'email': _emailCtrl.text,
          'password': _passCtrl.text,
          'address': _extraCtrl.text.isEmpty ? 'N/A' : _extraCtrl.text,
        };
        await dio.post('/public/register-recipient', data: payload);
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Registro exitoso! Ya puedes iniciar sesión.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } on DioException catch (de) {
      final errorMsg =
          de.response?.data?['error']?.toString() ?? 'Error de conexión';

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $errorMsg'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFFB0B7C3),
        size: 22,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE5E7EB),
          width: 1.2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE5E7EB),
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFF4B83A),
          width: 1.4,
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    final activeColor = const Color(0xFF3B82F6);
    final inactiveColor = const Color(0xFF374151);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _isLockedRole
                  ? null
                  : () {
                      setState(() {
                        _isSeller = true;
                      });
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isSeller
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: _isSeller ? activeColor : inactiveColor,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Soy Vendedor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _isSeller ? activeColor : inactiveColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 34,
            color: const Color(0xFFE5E7EB),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _isLockedRole
                  ? null
                  : () {
                      setState(() {
                        _isSeller = false;
                      });
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      !_isSeller
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: !_isSeller ? activeColor : inactiveColor,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Soy Cliente',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: !_isSeller ? activeColor : inactiveColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF6F6F7);
    const textDark = Color(0xFF1F2937);
    const textMuted = Color(0xFF4B5563);
    const primary = Color(0xFFF4B83A);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF111827),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Registro',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
          children: [
            const Text(
              'Únete a una Empresa',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ingresa el Código de la empresa proporcionado para unirte.',
              style: TextStyle(
                fontSize: 16,
                height: 1.45,
                color: textMuted,
              ),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _codeCtrl,
              onChanged: _onCodeChanged,
              decoration: _fieldDecoration(
                hint: 'Código QR / ID aquí',
                icon: Icons.mail_outline_rounded,
                suffixIcon: IconButton(
                  onPressed: _isLoading ? null : _openQrScanner,
                  icon: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _openQrScanner,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: Colors.white,
                ),
                icon: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Color(0xFF374151),
                ),
                label: const Text(
                  'Escanear QR con cámara',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ),
            if (_isLockedRole) ...[
              const SizedBox(height: 10),
              const Text(
                'Rol detectado automáticamente por el código.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 18),
            _buildRoleSelector(),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _nameCtrl,
                    decoration: _fieldDecoration(
                      hint: 'Nombre Completo',
                      icon: Icons.person_outline_rounded,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: _fieldDecoration(
                      hint: 'Teléfono',
                      icon: Icons.call_outlined,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _fieldDecoration(
                      hint: 'Email (Será tu usuario)',
                      icon: Icons.mail_outline_rounded,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscurePassword,
                    decoration: _fieldDecoration(
                      hint: 'Contraseña',
                      icon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFFB0B7C3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _extraCtrl,
                    decoration: _fieldDecoration(
                      hint: _isSeller
                          ? 'Nombre del Negocio (solo si vendedor)'
                          : 'Dirección de Entrega',
                      icon: _isSeller
                          ? Icons.storefront_outlined
                          : Icons.location_on_outlined,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFF2B63A),
                            Color(0xFFF5C34E),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.28),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Crear Cuenta',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrScannerPage extends StatefulWidget {
  const _QrScannerPage();

  @override
  State<_QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<_QrScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) {
      return;
    }

    final codes = capture.barcodes;
    for (final code in codes) {
      final value = code.rawValue;
      if (value != null && value.trim().isNotEmpty) {
        _handled = true;
        Navigator.of(context).pop(value.trim());
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Escanear QR'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFF4B83A),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Text(
              'Coloca el código QR dentro del recuadro',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}