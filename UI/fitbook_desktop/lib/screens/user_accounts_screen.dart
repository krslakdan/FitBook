import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/common/page_result.dart';
import '../models/responses/user_account_response.dart';
import '../models/search_objects/user_search_object.dart';
import '../providers/auth_provider.dart';
import '../providers/user_account_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/app_config.dart';
import '../utils/app_roles.dart';
import '../utils/formatters.dart';
import '../widgets/crud/confirm_dialog.dart';
import '../widgets/crud/data_table_card.dart';
import '../widgets/crud/filter_bar.dart';
import '../widgets/crud/form_dialog.dart';
import '../widgets/crud/table_action_buttons.dart';
import '../widgets/status_chip.dart';
import 'user_accounts_details_screen.dart';

class UserAccountsScreen extends StatefulWidget {
  const UserAccountsScreen({super.key});

  @override
  State<UserAccountsScreen> createState() => _UserAccountsScreenState();
}

class _UserAccountsScreenState extends State<UserAccountsScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  String? _role;
  bool? _isActive;

  int _page = 1;
  int _pageSize = 10;

  PageResult<UserAccountResponse>? _data;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await context.read<UserAccountProvider>().get(
        filter: UserSearchObject(
          page: _page,
          pageSize: _pageSize,
          search: _searchController.text.trim(),
          role: _role,
          isActive: _isActive,
          includeTotalCount: true,
        ),
      );
      if (!mounted) return;
      setState(() => _data = result);
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      _page = 1;
      _load();
    });
  }

  void _applyFilterChange(VoidCallback change) {
    setState(() {
      change();
      _page = 1;
    });
    _load();
  }

  void _clearFilters() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _applyFilterChange(() {
      _role = null;
      _isActive = null;
    });
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: AppColors.primaryDark, content: Text(message)),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: AppColors.danger, content: Text(message)),
    );
  }

  Future<void> _openForm({UserAccountResponse? user}) async {
    final message = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => UserAccountsDetailsScreen(user: user),
    );
    if (message == null || !mounted) return;
    _showSuccess(message);
    if (user == null) {
      setState(() => _page = 1);
    }
    await _load();
  }

  Future<void> _openDetails(UserAccountResponse user) {
    return showDialog<void>(
      context: context,
      builder: (_) => _UserDetailsDialog(user: user),
    );
  }

  Future<void> _delete(UserAccountResponse user) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Brisanje korisnika',
      message:
          'Da li ste sigurni da želite obrisati korisnika "${user.firstName} ${user.lastName}"? '
          'Nalog će biti deaktiviran i uklonjen sa liste.',
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<UserAccountProvider>().remove(user.id);
      if (!mounted) return;
      _showSuccess(
        'Korisnik "${user.firstName} ${user.lastName}" je uspješno obrisan.',
      );
      if (_data != null && _data!.items.length == 1 && _page > 1) _page -= 1;
      await _load();
    } on ApiClientException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().currentUserId;

    return MasterScreen(
      title: 'Korisnici',
      subtitle: 'Pregled, pretraga i upravljanje korisnicima',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilterBar(
              fields: [
                FilterField(
                  label: 'Pretraga',
                  width: 260,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Ime, prezime, email, korisničko ime...',
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                  ),
                ),
                FilterField(
                  label: 'Uloga',
                  width: 170,
                  child: _dropdown<String?>(
                    value: _role,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Sve uloge'),
                      ),
                      for (final role in AppRoles.all)
                        DropdownMenuItem(
                          value: role,
                          child: Text(AppRoles.displayName(role)),
                        ),
                    ],
                    onChanged: (value) =>
                        _applyFilterChange(() => _role = value),
                  ),
                ),
                FilterField(
                  label: 'Status',
                  width: 150,
                  child: _dropdown<bool?>(
                    value: _isActive,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Svi statusi')),
                      DropdownMenuItem(value: true, child: Text('Aktivan')),
                      DropdownMenuItem(value: false, child: Text('Neaktivan')),
                    ],
                    onChanged: (value) =>
                        _applyFilterChange(() => _isActive = value),
                  ),
                ),
              ],
              actions: [
                FilledButton.icon(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Dodaj korisnika'),
                ),
                OutlinedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                  label: const Text('Očisti filtere'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: DataTableCard<UserAccountResponse>(
                title: 'Lista korisnika',
                loading: _loading,
                error: _error,
                items: _data?.items ?? const [],
                page: _page,
                pageSize: _pageSize,
                totalCount: _data?.totalCount,
                totalPages: _data?.totalPages,
                itemsLabel: 'korisnika',
                emptyMessage: 'Nema korisnika za zadate filtere.',
                onRefresh: _load,
                onPageChanged: (page) {
                  setState(() => _page = page);
                  _load();
                },
                onPageSizeChanged: (size) {
                  setState(() {
                    _pageSize = size;
                    _page = 1;
                  });
                  _load();
                },
                columns: const [
                  ColumnSpec('Korisnik', flex: 3),
                  ColumnSpec('Kontakt', flex: 2),
                  ColumnSpec('Korisničko ime', flex: 2),
                  ColumnSpec('Uloga', width: 120),
                  ColumnSpec('Status', width: 100),
                  ColumnSpec('Kreirano', width: 130),
                  ColumnSpec('Ažurirano', width: 130),
                  ColumnSpec('Akcije', width: 116),
                ],
                cellsBuilder: (context, user) => [
                  _userCell(user),
                  Text(user.phoneNumber, style: const TextStyle(fontSize: 13)),
                  Text(user.username, style: const TextStyle(fontSize: 13)),
                  StatusChip(
                    label: AppRoles.displayName(user.role),
                    tone: switch (user.role) {
                      AppRoles.admin => ChipTone.purple,
                      AppRoles.trainer => ChipTone.info,
                      _ => ChipTone.success,
                    },
                  ),
                  StatusChip(
                    label: user.isActive ? 'Aktivan' : 'Neaktivan',
                    tone: user.isActive ? ChipTone.success : ChipTone.warning,
                  ),
                  Text(
                    formatDateTime(user.createdAtUtc),
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  Text(
                    formatDateTime(user.updatedAtUtc),
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  TableActionButtons(
                    onView: () => _openDetails(user),
                    onEdit: () => _openForm(user: user),
                    onDelete: user.id == currentUserId
                        ? null
                        : () => _delete(user),
                    deleteDisabledReason: 'Ne možete obrisati vlastiti nalog.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      isExpanded: true,
      style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
      borderRadius: BorderRadius.circular(10),
      onChanged: (v) => onChanged(v as T),
    );
  }

  Widget _userCell(UserAccountResponse user) {
    final imageUrl = AppConfig.absoluteFileUrl(user.profileImageUrl);
    final initials =
        '${user.firstName.isEmpty ? '' : user.firstName[0]}${user.lastName.isEmpty ? '' : user.lastName[0]}';

    return Row(
      children: [
        CircleAvatar(
          radius: 19,
          backgroundColor: AppColors.primarySoft,
          foregroundImage: imageUrl == null ? null : NetworkImage(imageUrl),
          child: Text(
            initials.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onPrimarySoft,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${user.firstName} ${user.lastName}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                user.email,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserDetailsDialog extends StatelessWidget {
  const _UserDetailsDialog({required this.user});

  final UserAccountResponse user;

  @override
  Widget build(BuildContext context) {
    final imageUrl = AppConfig.absoluteFileUrl(user.profileImageUrl);
    final initials =
        '${user.firstName.isEmpty ? '' : user.firstName[0]}${user.lastName.isEmpty ? '' : user.lastName[0]}';

    return FormDialogShell(
      title: 'Detalji korisnika',
      maxWidth: 560,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.primarySoft,
                foregroundImage: imageUrl == null
                    ? null
                    : NetworkImage(imageUrl),
                child: Text(
                  initials.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimarySoft,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        StatusChip(
                          label: AppRoles.displayName(user.role),
                          tone: switch (user.role) {
                            AppRoles.admin => ChipTone.purple,
                            AppRoles.trainer => ChipTone.info,
                            _ => ChipTone.success,
                          },
                        ),
                        const SizedBox(width: 8),
                        StatusChip(
                          label: user.isActive ? 'Aktivan' : 'Neaktivan',
                          tone: user.isActive
                              ? ChipTone.success
                              : ChipTone.warning,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _detailRow(Icons.email_outlined, 'Email', user.email),
          _detailRow(Icons.phone_outlined, 'Telefon', user.phoneNumber),
          _detailRow(Icons.person_outline, 'Korisničko ime', user.username),
          _detailRow(
            Icons.event_outlined,
            'Kreirano',
            formatDateTime(user.createdAtUtc),
          ),
          _detailRow(
            Icons.update_outlined,
            'Ažurirano',
            formatDateTime(user.updatedAtUtc),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
