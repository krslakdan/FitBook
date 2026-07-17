import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/common/page_result.dart';
import '../models/responses/news_item_response.dart';
import '../models/search_objects/news_item_search_object.dart';
import '../providers/news_item_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/app_config.dart';
import '../utils/formatters.dart';
import '../widgets/crud/confirm_dialog.dart';
import '../widgets/crud/data_table_card.dart';
import '../widgets/crud/filter_bar.dart';
import '../widgets/crud/form_dialog.dart';
import '../widgets/crud/table_action_buttons.dart';
import '../widgets/status_chip.dart';
import 'news_items_details_screen.dart';

class NewsItemsScreen extends StatefulWidget {
  const NewsItemsScreen({super.key});

  @override
  State<NewsItemsScreen> createState() => _NewsItemsScreenState();
}

class _NewsItemsScreenState extends State<NewsItemsScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  bool? _isActive;

  int _page = 1;
  int _pageSize = 10;

  PageResult<NewsItemResponse>? _data;
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
      final result = await context.read<NewsItemProvider>().get(
        filter: NewsItemSearchObject(
          page: _page,
          pageSize: _pageSize,
          search: _searchController.text.trim(),
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

  Future<void> _openForm({NewsItemResponse? newsItem}) async {
    final message = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => NewsItemsDetailsScreen(newsItem: newsItem),
    );
    if (message == null || !mounted) return;
    _showSuccess(message);
    if (newsItem == null) {
      setState(() => _page = 1);
    }
    await _load();
  }

  Future<void> _openDetails(NewsItemResponse newsItem) {
    return showDialog<void>(
      context: context,
      builder: (_) => _NewsItemDetailsDialog(newsItem: newsItem),
    );
  }

  Future<void> _delete(NewsItemResponse newsItem) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Brisanje obavijesti',
      message:
          'Da li ste sigurni da želite obrisati obavijest "${newsItem.title}"?',
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<NewsItemProvider>().remove(newsItem.id);
      if (!mounted) return;
      _showSuccess('Obavijest "${newsItem.title}" je uspješno obrisana.');
      if (_data != null && _data!.items.length == 1 && _page > 1) _page -= 1;
      await _load();
    } on ApiClientException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    }
  }

  Widget _newsCell(NewsItemResponse newsItem) {
    final imageUrl = AppConfig.absoluteFileUrl(newsItem.imageUrl);

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageUrl == null
              ? Container(
                  width: 44,
                  height: 44,
                  color: AppColors.primarySoft,
                  child: const Icon(
                    Icons.campaign_outlined,
                    size: 22,
                    color: AppColors.onPrimarySoft,
                  ),
                )
              : Image.network(
                  imageUrl,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 44,
                    height: 44,
                    color: AppColors.primarySoft,
                    child: const Icon(
                      Icons.campaign_outlined,
                      size: 22,
                      color: AppColors.onPrimarySoft,
                    ),
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
                newsItem.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                newsItem.content,
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

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Obavijesti',
      subtitle: 'Upravljanje obavijestima',
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
                      hintText: 'Naslov ili sadržaj obavijesti...',
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                  ),
                ),
                FilterField(
                  label: 'Status',
                  width: 150,
                  child: DropdownButtonFormField<bool?>(
                    initialValue: _isActive,
                    isExpanded: true,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textPrimary,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Svi statusi')),
                      DropdownMenuItem(value: true, child: Text('Aktivna')),
                      DropdownMenuItem(value: false, child: Text('Neaktivna')),
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
                  label: const Text('Dodaj obavijest'),
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
              child: DataTableCard<NewsItemResponse>(
                title: 'Lista obavijesti',
                loading: _loading,
                error: _error,
                items: _data?.items ?? const [],
                page: _page,
                pageSize: _pageSize,
                totalCount: _data?.totalCount,
                totalPages: _data?.totalPages,
                itemsLabel: 'obavijesti',
                emptyMessage: 'Nema obavijesti za zadate filtere.',
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
                  ColumnSpec('Obavijest', flex: 4),
                  ColumnSpec('Objavljeno', width: 130),
                  ColumnSpec('Status', width: 110),
                  ColumnSpec('Kreirano', width: 130),
                  ColumnSpec('Akcije', width: 116),
                ],
                cellsBuilder: (context, newsItem) => [
                  _newsCell(newsItem),
                  Text(
                    formatDateTime(newsItem.publishedAtUtc),
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  StatusChip(
                    label: newsItem.isActive ? 'Aktivna' : 'Neaktivna',
                    tone: newsItem.isActive
                        ? ChipTone.success
                        : ChipTone.warning,
                  ),
                  Text(
                    formatDateTime(newsItem.createdAtUtc),
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  TableActionButtons(
                    onView: () => _openDetails(newsItem),
                    onEdit: () => _openForm(newsItem: newsItem),
                    onDelete: () => _delete(newsItem),
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

class _NewsItemDetailsDialog extends StatelessWidget {
  const _NewsItemDetailsDialog({required this.newsItem});

  final NewsItemResponse newsItem;

  @override
  Widget build(BuildContext context) {
    final imageUrl = AppConfig.absoluteFileUrl(newsItem.imageUrl);

    return FormDialogShell(
      title: 'Detalji obavijesti',
      maxWidth: 620,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  newsItem.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              StatusChip(
                label: newsItem.isActive ? 'Aktivna' : 'Neaktivna',
                tone: newsItem.isActive ? ChipTone.success : ChipTone.warning,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            newsItem.content,
            style: const TextStyle(fontSize: 13.5, height: 1.5),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          DetailRow(
            icon: Icons.campaign_outlined,
            label: 'Objavljeno',
            value: formatDateTime(newsItem.publishedAtUtc),
          ),
          DetailRow(
            icon: Icons.event_outlined,
            label: 'Kreirano',
            value: formatDateTime(newsItem.createdAtUtc),
          ),
          DetailRow(
            icon: Icons.update_outlined,
            label: 'Ažurirano',
            value: formatDateTime(newsItem.updatedAtUtc),
          ),
        ],
      ),
    );
  }
}
