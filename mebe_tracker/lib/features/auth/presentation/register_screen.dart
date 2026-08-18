import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/providers/auth_provider.dart';

/// Bump when Terms/Privacy content changes materially — existing users whose
/// stored consent version lags this are prompted to re-consent (see app.dart).
const String kCurrentTermsVersion = '1.0';
const String kCurrentPrivacyVersion = '1.0';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  bool _consentTerms = false;
  bool _consentPrivacy = false;
  bool _consentDisclaimer = false;
  bool _consentAge = false;

  bool get _canRegister => _consentTerms && _consentPrivacy && _consentDisclaimer && _consentAge;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  String _deviceInfo() {
    if (Platform.isIOS) return 'iOS ${Platform.operatingSystemVersion}';
    if (Platform.isAndroid) return 'Android ${Platform.operatingSystemVersion}';
    return Platform.operatingSystem;
  }

  Future<void> _saveConsentRecord(String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('consents')
        .doc('registration')
        .set({
      'consentTerms': _consentTerms,
      'consentPrivacy': _consentPrivacy,
      'consentDisclaimer': _consentDisclaimer,
      'consentAge': _consentAge,
      'termsVersion': kCurrentTermsVersion,
      'privacyVersion': kCurrentPrivacyVersion,
      'consentedAt': FieldValue.serverTimestamp(),
      'deviceInfo': _deviceInfo(),
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_canRegister) return;
    setState(() => _loading = true);
    try {
      final credential = await ref.read(authRepositoryProvider).signUpWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
            displayName: _nameController.text.trim(),
          );
      final uid = credential.user?.uid;
      if (uid != null) {
        await _saveConsentRecord(uid);
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Tạo tài khoản thất bại.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            0,
            AppSpacing.xxl,
            AppSpacing.xxl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Tạo tài khoản', style: AppTextStyles.displaySm),
                const SizedBox(height: AppSpacing.xxl),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Tên của bạn',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Vui lòng nhập tên' : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập email';
                    if (!value.contains('@')) return 'Email không hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      tooltip: _obscurePassword ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    hintText: 'Xác nhận mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      tooltip: _obscureConfirm ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) return 'Mật khẩu không khớp';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Column(
                    children: [
                      _ConsentTile(
                        value: _consentTerms,
                        onChanged: (v) => setState(() => _consentTerms = v),
                        label: 'Tôi đồng ý với ',
                        linkText: 'Điều khoản sử dụng',
                        onLinkTap: () => context.push('/legal/terms'),
                      ),
                      _ConsentTile(
                        value: _consentPrivacy,
                        onChanged: (v) => setState(() => _consentPrivacy = v),
                        label: 'Tôi đã đọc và đồng ý với ',
                        linkText: 'Chính sách bảo mật',
                        onLinkTap: () => context.push('/legal/privacy'),
                      ),
                      _ConsentTile(
                        value: _consentDisclaimer,
                        onChanged: (v) => setState(() => _consentDisclaimer = v),
                        label: 'Tôi hiểu MeBé Tracker không thay thế tư vấn y tế chuyên nghiệp — ',
                        linkText: 'Miễn trừ trách nhiệm y tế',
                        onLinkTap: () => context.push('/legal/disclaimer'),
                      ),
                      _ConsentTile(
                        value: _consentAge,
                        onChanged: (v) => setState(() => _consentAge = v),
                        label: 'Tôi xác nhận mình từ 18 tuổi trở lên',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (_loading || !_canRegister) ? null : _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.blossom),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                          )
                        : const Text('Tạo tài khoản'),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Đã có tài khoản? ',
                        style: TextStyle(color: AppColors.body),
                        children: [
                          TextSpan(
                            text: 'Đăng nhập',
                            style: TextStyle(color: AppColors.blossom, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One checkbox row in the registration consent section — an optional
/// trailing [linkText] segment opens the relevant legal screen on tap.
class _ConsentTile extends StatelessWidget {
  const _ConsentTile({
    required this.value,
    required this.onChanged,
    required this.label,
    this.linkText,
    this.onLinkTap,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final String? linkText;
  final VoidCallback? onLinkTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: AppColors.blossom,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.ink),
                    children: [
                      TextSpan(text: label),
                      if (linkText != null)
                        TextSpan(
                          text: linkText,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.blossom,
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = onLinkTap,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
