import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/enums/training_term_status.dart';
import '../models/responses/training_response.dart';
import '../models/responses/training_term_response.dart';
import '../models/search_objects/training_term_search_object.dart';
import '../providers/training_term_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../widgets/term_card.dart';
import 'term_details_screen.dart';

class TrainingTermsScreen extends StatefulWidget {
  const TrainingTermsScreen({super.key, required this.training});

  final TrainingResponse training;

  @override
  State<TrainingTermsScreen> createState() => _TrainingTermsScreenState();
}

class _TrainingTermsScreenState extends State<TrainingTermsScreen> {
  List<TrainingTermResponse> _terms = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await context.read<TrainingTermProvider>().get(
        filter: TrainingTermSearchObject(
          trainingId: widget.training.id,
          startFromUtc: DateTime.now().toUtc(),
          status: TrainingTermStatus.scheduled,
          isActive: true,
          pageSize: 50,
          includeTotalCount: true,
        ),
      );
      if (!mounted) return;
      final terms = [...result.items]
        ..sort((a, b) => a.startTimeUtc.compareTo(b.startTimeUtc));
      setState(() {
        _terms = terms;
        _loading = false;
      });
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _openTerm(TrainingTermResponse term) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TermDetailsScreen(term: term)),
    );
    if (!mounted) return;
    _loadTerms();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Dostupni termini',
      subtitle: widget.training.name,
      showBackButton: true,
      child: RefreshIndicator(
        onRefresh: _loadTerms,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: _buildBody(),
        ),
      ),
    );
  }

  List<Widget> _buildBody() {
    if (_loading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (_error != null) {
      return [
        MessageBox(
          icon: Icons.cloud_off_outlined,
          message: _error!,
          action: OutlinedButton.icon(
            onPressed: _loadTerms,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Pokušaj ponovo'),
          ),
        ),
      ];
    }

    if (_terms.isEmpty) {
      return const [
        MessageBox(
          icon: Icons.event_busy_outlined,
          message: 'Trenutno nema zakazanih termina za ovaj trening.',
        ),
      ];
    }

    return [
      for (final term in _terms) ...[
        TermCard(term: term, onTap: () => _openTerm(term)),
        const SizedBox(height: 10),
      ],
    ];
  }
}
