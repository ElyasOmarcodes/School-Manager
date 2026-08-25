import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../data/db/database.dart';
import '../../data/repositories/user_repository.dart';
import '../../widgets/data_table_view.dart';
import '../auth/auth_service.dart';

/// د کاروونکو پاڼه — حسابونه، رولونه او اجازې.
class UsersPage extends StatefulWidget {
  final UserRepository users;
  final Session session;

  const UsersPage({super.key, required this.users, required this.session});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  int _tab = 0;

  /// **مدیر هر څه کولی شي؛ نور یوازې خپل ځان.**
  ///
  /// دا یوه کرښه د ټولې پاڼې قاعده ده. که هره تڼۍ يې پخپله
  /// پرېکړه کوله، یوه به تل هېره شوې وه — او هغه یوه به هغه وه
  /// چې د یوه محاسب ته يې د مدیر پاسورډ بدلولو اجازه ورکوله.
  bool get _isAdmin => widget.session.role == 'admin';

  bool _isSelf(UserRow r) => r.user.id == widget.session.userId;
  bool _loading = true;
  List<UserRow> _users = const [];
  List<AuditLog> _activity = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final users = await widget.users.list();
    final activity = await widget.users.recentActivity();
    if (!mounted) return;
    setState(() {
      _users = users;
      _activity = activity;
      _loading = false;
    });
  }

  void _toast(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 500,
        backgroundColor: color,
        content: Text(text),
      ),
    );
  }

  Future<void> _create() async {
    final draft = await showDialog<_UserDraft>(
      context: context,
      builder: (_) => const _UserDialog(),
    );
    if (draft == null || !mounted) return;

    if (await widget.users.usernameTaken(draft.username)) {
      if (mounted) _toast('دا کارن نوم مخکې نیول شوی.', AppColors.danger);
      return;
    }

    await widget.users.create(
      username: draft.username,
      fullName: draft.fullName,
      password: draft.password,
      role: draft.role,
      byUserId: widget.session.userId,
      byUserName: widget.session.username,
    );
    if (!mounted) return;
    await _load();
    if (!mounted) return;
    _toast('کاروونکی جوړ شو.', AppColors.success);
  }

  Future<void> _editPermissions(UserRow row) async {
    if (row.user.role == 'admin') {
      _toast(
        'د مدیر اجازې نه سمېږي — مدیر تل هرڅه کولی شي.',
        AppColors.warning,
      );
      return;
    }

    final result = await showDialog<Map<String, Set<String>>>(
      context: context,
      builder: (_) => _PermissionDialog(row: row),
    );
    if (result == null || !mounted) return;

    await widget.users.updatePermissions(
      userId: row.user.id,
      permissions: result,
      byUserId: widget.session.userId,
      byUserName: widget.session.username,
    );
    await _load();
  }

  Future<void> _toggleActive(UserRow row) async {
    if (row.user.isActive && await widget.users.isLastActiveAdmin(row.user.id)) {
      if (mounted) {
        _toast(
          'دا وروستی فعال مدیر دی — که بند شي، هېڅوک به سیسټم ته '
          'لاره ونه لري. لومړی بل مدیر جوړ کړئ.',
          AppColors.danger,
        );
      }
      return;
    }

    await widget.users.setActive(
      userId: row.user.id,
      active: !row.user.isActive,
      byUserId: widget.session.userId,
      byUserName: widget.session.username,
    );
    await _load();
  }

  /// د نوم او کارن‌نوم سمون — یوازې مدیر.
  Future<void> _editProfile(UserRow row) async {
    final draft = await showDialog<({String fullName, String username})>(
      context: context,
      builder: (_) => _ProfileDialog(user: row.user),
    );
    if (draft == null || !mounted) return;

    final result = await widget.users.updateProfile(
      userId: row.user.id,
      fullName: draft.fullName,
      username: draft.username,
      byUserId: widget.session.userId,
      byUserName: widget.session.username,
    );
    if (!mounted) return;
    await _load();
    if (!mounted) return;
    _toast(
      result.message,
      result == UpdateProfileResult.ok
          ? AppColors.success
          : AppColors.danger,
    );
  }

  /// **خپل پاسورډ بدلول — زوړ پاسورډ پکار دی.**
  ///
  /// مدیر د بل چا پاسورډ پرته له زوړه بدلولی شي (ځکه چې هغه يې
  /// نه پېژني)، خو خپل نه — که يې پرده خلاصه پرېښوده او څوک
  /// ورته کېناست، د حساب خاوند به يې بدل کړ.
  Future<void> _changeOwnPassword() async {
    final draft = await showDialog<({String oldPass, String newPass})>(
      context: context,
      builder: (_) => const _OwnPasswordDialog(),
    );
    if (draft == null || !mounted) return;

    final ok = await widget.users.changeOwnPassword(
      userId: widget.session.userId,
      oldPassword: draft.oldPass,
      newPassword: draft.newPass,
    );
    if (!mounted) return;
    await _load();
    if (!mounted) return;
    _toast(
      ok ? 'پاسورډ بدل شو.' : 'زوړ پاسورډ سم نه دی.',
      ok ? AppColors.success : AppColors.danger,
    );
  }

  Future<void> _resetPassword(UserRow row) async {
    final pass = await showDialog<String>(
      context: context,
      builder: (_) => _PasswordDialog(name: row.user.fullName),
    );
    if (pass == null || !mounted) return;

    await widget.users.resetPassword(
      userId: row.user.id,
      newPassword: pass,
      byUserId: widget.session.userId,
      byUserName: widget.session.username,
    );
    if (!mounted) return;
    await _load();
    if (!mounted) return;
    _toast('پاسورډ بدل شو.', AppColors.success);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                for (final t in const [
                  (0, 'کاروونکي'),
                  (1, 'د تفتیش تاریخچه'),
                ]) ...[
                  _Tab(
                    label: t.$2,
                    selected: _tab == t.$1,
                    onTap: () => setState(() => _tab = t.$1),
                  ),
                  const SizedBox(width: 8),
                ],
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _changeOwnPassword,
                  icon: const Icon(Icons.key_rounded, size: 17),
                  label: const Text('خپل پاسورډ'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const SizedBox(width: 10),
                if (_isAdmin)
                  FilledButton.icon(
                    onPressed: _create,
                    icon: const Icon(Icons.person_add_rounded, size: 18),
                    label: const Text('نوی کاروونکی'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.modUsers,
                      minimumSize: const Size(0, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      textStyle: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: AnimatedSwitcher(
              duration: AppMotion.fast,
              switchInCurve: AppMotion.standard,
              layoutBuilder: (current, previous) => Stack(
                fit: StackFit.expand,
                children: [...previous, if (current != null) current],
              ),
              child: KeyedSubtree(
                key: ValueKey(_tab),
                child: _tab == 0 ? _buildUsers(p) : _buildActivity(p),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsers(AppPalette p) {
    final locale = S.of(context).locale;

    return DataTableView<UserRow>(
      loading: _loading,
      rows: _users,
      emptyIcon: Icons.manage_accounts_rounded,
      emptyTitle: 'هېڅ کاروونکی نشته',
      columns: [
        TableColumn(
          title: 'کاروونکی',
          flex: 3,
          cell: (context, r) => Row(
            children: [
              AvatarCell(
                name: r.user.fullName,
                color: r.user.isActive ? AppColors.modUsers : p.faint,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      r.user.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: r.user.isActive ? p.ink : p.faint,
                      ),
                    ),
                    Text(
                      r.user.username,
                      style: AppTheme.tabular(
                        TextStyle(fontSize: 11.5, color: p.muted),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        TableColumn(
          title: 'رول',
          width: 116,
          cell: (context, r) => StatusChip(
            label: roleLabel(r.user.role),
            color: r.user.role == 'admin'
                ? AppColors.primary
                : AppColors.modUsers,
          ),
        ),
        TableColumn(
          title: 'اجازې',
          width: 130,
          cell: (context, r) => Text(
            r.user.role == 'admin'
                ? 'ټولې'
                : '${locale.num(r.permissions.visibleModules.length)} ماډلونه'
                      '${r.user.permissionsJson == null ? '' : ' *'}',
            style: TextStyle(fontSize: 12, color: p.inkSoft),
          ),
        ),
        TableColumn(
          title: 'وروستی ننوتل',
          width: 140,
          cell: (context, r) => Text(
            r.user.lastLoginAt == null
                ? 'هېڅکله'
                : locale.num(_stamp(r.user.lastLoginAt!)),
            style: AppTheme.tabular(
              TextStyle(fontSize: 11.5, color: p.muted),
            ),
          ),
        ),
        TableColumn(
          title: 'حالت',
          width: 108,
          cell: (context, r) => StatusChip(
            label: r.isLocked
                ? 'بند شوی'
                : (r.user.isActive ? 'فعال' : 'غیرفعال'),
            color: r.isLocked
                ? AppColors.danger
                : (r.user.isActive ? AppColors.success : AppColors.modUsers),
          ),
        ),
        TableColumn(
          title: '',
          width: 200,
          cell: (context, r) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isAdmin && !_isSelf(r))
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: Tooltip(
                    message: 'یوازې مدیر د نورو حسابونه سمولی شي',
                    child: Icon(Icons.lock_rounded, size: 15, color: p.faint),
                  ),
                ),
              IconButton(
                tooltip: 'نوم او کارن‌نوم',
                onPressed: _isAdmin ? () => _editProfile(r) : null,
                icon: Icon(
                  Icons.badge_rounded,
                  size: 17,
                  color: _isAdmin ? p.muted : p.faint,
                ),
              ),
              IconButton(
                tooltip: 'اجازې',
                onPressed: _isAdmin ? () => _editPermissions(r) : null,
                icon: Icon(
                  Icons.tune_rounded,
                  size: 17,
                  color: _isAdmin ? p.muted : p.faint,
                ),
              ),
              IconButton(
                tooltip: _isSelf(r) ? 'خپل پاسورډ بدل کړه' : 'پاسورډ بدل کړه',
                onPressed: _isSelf(r)
                    ? _changeOwnPassword
                    : (_isAdmin ? () => _resetPassword(r) : null),
                icon: Icon(
                  Icons.key_rounded,
                  size: 17,
                  color: _isSelf(r) || _isAdmin ? p.muted : p.faint,
                ),
              ),
              if (r.isLocked)
                IconButton(
                  tooltip: 'خلاص کړه',
                  onPressed: _isAdmin
                      ? () async {
                          await widget.users.unlock(r.user.id);
                          await _load();
                        }
                      : null,
                  icon: Icon(
                    Icons.lock_open_rounded,
                    size: 17,
                    color: _isAdmin ? AppColors.danger : p.faint,
                  ),
                ),
              IconButton(
                tooltip: r.user.isActive ? 'غیرفعال کړه' : 'فعال کړه',
                onPressed: _isAdmin ? () => _toggleActive(r) : null,
                icon: Icon(
                  r.user.isActive
                      ? Icons.toggle_on_rounded
                      : Icons.toggle_off_rounded,
                  size: 21,
                  color: !_isAdmin
                      ? p.faint
                      : (r.user.isActive ? AppColors.success : p.faint),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivity(AppPalette p) {
    final locale = S.of(context).locale;

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: p.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        itemCount: _activity.length,
        separatorBuilder: (_, _) => Divider(color: p.line, height: 1),
        itemBuilder: (context, i) {
          final a = _activity[i];
          final color = switch (a.action) {
            'create' => AppColors.success,
            'delete' => AppColors.danger,
            'login' => AppColors.modAttendance,
            _ => AppColors.modUsers,
          };

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    switch (a.action) {
                      'create' => Icons.add_rounded,
                      'delete' => Icons.delete_outline_rounded,
                      'login' => Icons.login_rounded,
                      'logout' => Icons.logout_rounded,
                      _ => Icons.edit_rounded,
                    },
                    size: 15,
                    color: color,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${a.userName ?? 'سیسټم'} — '
                        '${_actionLabel(a.action)} '
                        '«${_entityLabel(a.entity)}»',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: p.ink,
                        ),
                      ),
                      if (a.changesJson != null)
                        Text(
                          a.changesJson!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: p.faint,
                            fontFamily: 'monospace',
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  locale.num(_stamp(a.at)),
                  style: AppTheme.tabular(
                    TextStyle(fontSize: 11.5, color: p.muted),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _actionLabel(String a) => switch (a) {
    'create' => 'جوړ کړ',
    'update' => 'بدل کړ',
    'delete' => 'ړنګ کړ',
    'login' => 'ننوت',
    'logout' => 'ووت',
    _ => a,
  };

  static String _entityLabel(String e) => switch (e) {
    'students' => 'شاګردان',
    'app_users' => 'کاروونکي',
    'teachers' => 'استادان',
    'staff_members' => 'کارمندان',
    'attendance_lock' => 'د ورځې تړل',
    'leave_requests' => 'اجازت‌نامې',
    'messages' => 'پیغامونه',
    'marks' => 'نمرې',
    'devices' => 'وسایل',
    'fee_invoices' => 'د فیس بلونه',
    'payroll_runs' => 'معاشونه',
    _ => e,
  };

  static String _stamp(DateTime t) =>
      '${t.month.toString().padLeft(2, '0')}/${t.day.toString().padLeft(2, '0')}'
      ' ${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';
}

// ═══════════════════════════════════════════════════════════

class _UserDraft {
  final String username;
  final String fullName;
  final String password;
  final String role;

  const _UserDraft({
    required this.username,
    required this.fullName,
    required this.password,
    required this.role,
  });
}

class _UserDialog extends StatefulWidget {
  const _UserDialog();

  @override
  State<_UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends State<_UserDialog> {
  final _username = TextEditingController();
  final _fullName = TextEditingController();
  final _password = TextEditingController();
  String _role = 'reception';
  bool _show = false;

  @override
  void dispose() {
    _username.dispose();
    _fullName.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final ready =
        _username.text.trim().length >= 3 &&
        _fullName.text.trim().isNotEmpty &&
        _password.text.length >= 8;

    return AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      title: const Text(
        'نوی کاروونکی',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _fullName,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'بشپړ نوم *'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _username,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'کارن نوم *',
                hintText: 'لږ تر لږه درې توري',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _password,
              obscureText: !_show,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'پاسورډ *',
                hintText: 'لږ تر لږه اته توري',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _show = !_show),
                  icon: Icon(
                    _show
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'رول'),
              items: [
                for (final r in appRoles)
                  DropdownMenuItem(
                    value: r.key,
                    child: Text(
                      r.label,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _role = v ?? 'reception'),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Text(
                _roleDescription(_role),
                style: TextStyle(fontSize: 11.5, height: 1.75, color: p.muted),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('بندول'),
        ),
        FilledButton(
          onPressed: !ready
              ? null
              : () => Navigator.pop(
                  context,
                  _UserDraft(
                    username: _username.text.trim(),
                    fullName: _fullName.text.trim(),
                    password: _password.text,
                    role: _role,
                  ),
                ),
          child: const Text('جوړ کړه'),
        ),
      ],
    );
  }

  static String _roleDescription(String role) => switch (role) {
    'admin' => 'مدیر: هر ماډل، هره کړنه. د مدیر اجازې نه محدودېږي.',
    'deputy' =>
      'مرستیال: شاګردان، حاضري، اجازې، مهالویش او ازموینې سموي؛ '
          'پیسې او تنظیمات نه ویني.',
    'teacher' =>
      'استاد: حاضري نیسي، نمرې لیکي، مهالویش ویني. شاګرد نه شي '
          'ړنګولی.',
    'accountant' => 'محاسب: فیس او معاشونه سموي، رپوټونه ویني.',
    _ =>
      'ریسیپشن: شاګرد ثبتوي، حاضري نیسي، اجازه ثبتوي، فیس اخلي. '
          'هېڅ شی نه ړنګوي.',
  };
}

/// د نوم او کارن‌نوم سمون.
class _ProfileDialog extends StatefulWidget {
  final AppUser user;
  const _ProfileDialog({required this.user});

  @override
  State<_ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<_ProfileDialog> {
  late final _name = TextEditingController(text: widget.user.fullName);
  late final _username = TextEditingController(text: widget.user.username);

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final valid =
        _name.text.trim().isNotEmpty && _username.text.trim().length >= 3;

    return AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      title: const Text(
        'د کاروونکي پېژندنه',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'بشپړ نوم'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _username,
              textDirection: TextDirection.ltr,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'کارن‌نوم',
                hintText: 'لږ تر لږه درې توري',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'د کارن‌نوم بدلول د حساب تاریخچه نه ورکوي — هماغه حساب '
              'دی، یوازې نوې پېژندنه لري. راتلونکی ځل به په نوي '
              'کارن‌نوم ننوځي.',
              style: TextStyle(fontSize: 11.5, height: 1.7, color: p.muted),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).cancel),
        ),
        FilledButton(
          onPressed: !valid
              ? null
              : () => Navigator.pop(context, (
                  fullName: _name.text.trim(),
                  username: _username.text.trim(),
                )),
          child: Text(S.of(context).save),
        ),
      ],
    );
  }
}

/// خپل پاسورډ — زوړ او نوی دواړه پکار دي.
class _OwnPasswordDialog extends StatefulWidget {
  const _OwnPasswordDialog();

  @override
  State<_OwnPasswordDialog> createState() => _OwnPasswordDialogState();
}

class _OwnPasswordDialogState extends State<_OwnPasswordDialog> {
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _repeat = TextEditingController();
  bool _show = false;

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _repeat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final match = _new.text == _repeat.text;
    final valid = _old.text.isNotEmpty && _new.text.length >= 8 && match;

    return AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      title: const Text(
        'خپل پاسورډ بدل کړئ',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _old,
              autofocus: true,
              obscureText: !_show,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'اوسنی پاسورډ',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _show = !_show),
                  icon: Icon(
                    _show
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _new,
              obscureText: !_show,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'نوی پاسورډ',
                hintText: 'لږ تر لږه اته توري',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _repeat,
              obscureText: !_show,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'بیا يې ولیکئ',
                errorText: _repeat.text.isEmpty || match
                    ? null
                    : 'دواړه یو شان نه دي',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).cancel),
        ),
        FilledButton(
          onPressed: !valid
              ? null
              : () => Navigator.pop(context, (
                  oldPass: _old.text,
                  newPass: _new.text,
                )),
          child: const Text('بدل کړه'),
        ),
      ],
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  final String name;
  const _PasswordDialog({required this.name});

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _c = TextEditingController();
  bool _show = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      title: Text(
        'د ${widget.name} پاسورډ',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _c,
              autofocus: true,
              obscureText: !_show,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'نوی پاسورډ',
                hintText: 'لږ تر لږه اته توري',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _show = !_show),
                  icon: Icon(
                    _show
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'زوړ پاسورډ نه لوستل کېږي — یوازې نوی ځای پرې نیسي. '
              'د ناکامو هڅو شمېر هم پاکېږي.',
              style: TextStyle(fontSize: 11.5, height: 1.7, color: p.muted),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('بندول'),
        ),
        FilledButton(
          onPressed: _c.text.length < 8
              ? null
              : () => Navigator.pop(context, _c.text),
          child: const Text('بدل کړه'),
        ),
      ],
    );
  }
}

/// د اجازو جدول — ماډل × کړنه.
class _PermissionDialog extends StatefulWidget {
  final UserRow row;
  const _PermissionDialog({required this.row});

  @override
  State<_PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<_PermissionDialog> {
  late Map<String, Set<String>> _perms;

  @override
  void initState() {
    super.initState();
    // له اوسنیو مؤثرو اجازو څخه پیل کوو — نه له تشې. که تش وای،
    // مدیر به يې فکر کاوه چې کارن هېڅ نه شي کولی.
    _perms = {
      for (final m in permModules)
        m.key: {
          for (final perm in Perm.values)
            if (widget.row.permissions.can(m.key, perm)) perm.key,
        },
    }..removeWhere((_, v) => v.isEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              'د ${widget.row.user.fullName} اجازې',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () => setState(() {
              // بېرته د رول تلوالو ته.
              _perms = {
                for (final m in permModules)
                  m.key: {
                    ...?roleDefaults[widget.row.user.role]?[m.key],
                  },
              }..removeWhere((_, v) => v.isEmpty);
            }),
            child: const Text(
              'د رول تلوالې',
              style: TextStyle(fontSize: 12.5),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 620,
        height: 460,
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 150),
                for (final perm in Perm.values)
                  SizedBox(
                    width: 92,
                    child: Text(
                      perm.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: p.muted,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: permModules.length,
                separatorBuilder: (_, _) => Divider(color: p.line, height: 1),
                itemBuilder: (context, i) {
                  final m = permModules[i];
                  final set = _perms[m.key] ?? {};

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            m.label,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: set.isEmpty ? p.faint : p.ink,
                            ),
                          ),
                        ),
                        for (final perm in Perm.values)
                          SizedBox(
                            width: 92,
                            child: Center(
                              child: Checkbox(
                                value: set.contains(perm.key),
                                onChanged: (v) => setState(() {
                                  final s = _perms.putIfAbsent(
                                    m.key,
                                    () => {},
                                  );
                                  if (v == true) {
                                    s.add(perm.key);
                                    // **زیاتول پرته له کتلو بې‌معنا ده.**
                                    if (perm != Perm.view) {
                                      s.add(Perm.view.key);
                                    }
                                  } else {
                                    s.remove(perm.key);
                                    // که کتل ولاړ شي، پاتې هم ځي.
                                    if (perm == Perm.view) s.clear();
                                  }
                                  if (s.isEmpty) _perms.remove(m.key);
                                }),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('بندول'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _perms),
          style: FilledButton.styleFrom(backgroundColor: AppColors.modUsers),
          child: const Text('وساتـه'),
        ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.modUsers.withValues(alpha: 0.11)
              : p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: selected ? AppColors.modUsers : p.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.modUsers : p.inkSoft,
          ),
        ),
      ),
    );
  }
}
