import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  final AuthService auth;
  final String schoolName;
  final ValueChanged<Session> onSignedIn;

  const LoginPage({
    super.key,
    required this.auth,
    required this.schoolName,
    required this.onSignedIn,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final _passFocus = FocusNode();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    final result = await widget.auth.signIn(_user.text, _pass.text);
    if (!mounted) return;

    final s = S.of(context);
    switch (result) {
      case SignInOk(:final session):
        widget.onSignedIn(session);
      case SignInWrong():
        setState(() {
          _busy = false;
          _error = s.wrongCredentials;
          _pass.clear();
        });
        _passFocus.requestFocus();
      case SignInLocked():
        setState(() {
          _busy = false;
          _error = s.accountLocked;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.ground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: FadeSlideIn(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.gradIndigo,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(19),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    widget.schoolName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: p.ink,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    s.appName,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: p.muted),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _user,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _passFocus.requestFocus(),
                    decoration: InputDecoration(
                      labelText: s.username,
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
                        size: 19,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _pass,
                    focusNode: _passFocus,
                    obscureText: true,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: s.password,
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        size: 19,
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: AppMotion.fast,
                    curve: AppMotion.standard,
                    child: _error == null
                        ? const SizedBox(width: double.infinity)
                        : Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  size: 16,
                                  color: AppColors.danger,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.danger,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(s.signIn),
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
