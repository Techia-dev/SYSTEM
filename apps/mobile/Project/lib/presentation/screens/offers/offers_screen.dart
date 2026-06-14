import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techia_sdk/techia_sdk.dart';
import 'package:techia_ats/core/theme/app_colors.dart';
import 'package:techia_ats/core/theme/app_text_styles.dart';
import 'package:techia_ats/core/responsive/responsive.dart';
import 'package:techia_ats/blocs/offers/offers_bloc.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final _searchController = TextEditingController();
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OffersBloc>().add(OffersLoad());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OffersBloc, OffersState>(
      builder: (context, state) {
        var items = state.items;
        if (_searchController.text.isNotEmpty) {
          final q = _searchController.text.toLowerCase();
          items = items.where((o) =>
            o.title.toLowerCase().contains(q) ||
            (o.company?.toLowerCase().contains(q) ?? false)
          ).toList();
        }
        if (!_showInactive) {
          items = items.where((o) => o.isActive).toList();
        }

        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: screenPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Offers', style: AppTextStyles.headlineLarge),
                            const SizedBox(height: 4),
                            Text('${items.length} offer${items.length == 1 ? '' : 's'}', style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showNewOfferDialog(context),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('New offer'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Search & Show inactive
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            hintText: 'Search title, company\u2026',
                            prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _showInactive,
                            onChanged: (v) => setState(() => _showInactive = v ?? false),
                            activeColor: AppColors.accentEmerald,
                            visualDensity: VisualDensity.compact,
                          ),
                          Text('Show inactive', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (state.isLoading)
                    const Center(child: CircularProgressIndicator(color: AppColors.accentEmerald))
                  else if (state.error != null)
                    _buildError(state.error!)
                  else if (items.isEmpty)
                    _buildEmpty()
                  else
                    _buildTable(items),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTable(List<Offer> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(child: Text('Title', style: AppTextStyles.tableHeader)),
                Expanded(child: Text('Company', style: AppTextStyles.tableHeader)),
                Expanded(child: Text('Commission', style: AppTextStyles.tableHeader)),
                Expanded(child: Text('Status', style: AppTextStyles.tableHeader)),
                Expanded(child: Text('Created', style: AppTextStyles.tableHeader)),
                const SizedBox(width: 96),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
            itemBuilder: (_, i) {
              final o = items[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(child: Text(o.title, style: AppTextStyles.titleSmall)),
                    Expanded(child: Text(o.company ?? '—', style: AppTextStyles.bodyMedium)),
                    Expanded(child: Text('\EGP ${o.commission.toStringAsFixed(0)}', style: AppTextStyles.bodyMedium)),
                    Expanded(child: _StatusBadge(o.isActive)),
                    Expanded(child: Text(_formatDate(o.createdAt), style: AppTextStyles.bodySmall)),
                    SizedBox(
                      width: 96,
                      child: TextButton(
                        onPressed: o.isActive ? () => context.read<OffersBloc>().add(OffersDeactivate(o.id)) : null,
                        child: Text(o.isActive ? 'Deactivate' : '', style: AppTextStyles.bodySmall.copyWith(color: AppColors.statusRejected)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _StatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? AppColors.accentEmerald.withValues(alpha: 0.1) : AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: AppTextStyles.bodySmall.copyWith(
          color: isActive ? AppColors.accentEmerald : AppColors.textMuted,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }

  void _showNewOfferDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final commissionCtrl = TextEditingController(text: '0');
    final delayCtrl = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New offer'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fill in the offer details.', style: AppTextStyles.bodySmall),
                const SizedBox(height: 16),
                Text('Title *', style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                TextField(controller: titleCtrl),
                const SizedBox(height: 12),
                Text('Company', style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                TextField(controller: companyCtrl),
                const SizedBox(height: 12),
                Text('Description', style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                TextField(controller: descCtrl, maxLines: 3),
                const SizedBox(height: 12),
                Text('Commission (EGP)', style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                TextField(controller: commissionCtrl, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                Text('Commission delay (days)', style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                TextField(controller: delayCtrl, keyboardType: TextInputType.number),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<OffersBloc>().add(OffersCreate({
                'title': titleCtrl.text,
                'company': companyCtrl.text,
                'description': descCtrl.text,
                'commission': double.tryParse(commissionCtrl.text) ?? 0,
                'commission_delay': int.tryParse(delayCtrl.text) ?? 0,
              }));
              Navigator.pop(ctx);
            },
            child: const Text('Add offer'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    return '${_months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  Widget _buildError(String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.accentEmerald),
            onPressed: () => context.read<OffersBloc>().add(OffersLoad()),
          ),
          const SizedBox(height: 12),
          Text(error, style: AppTextStyles.bodySmall.copyWith(color: AppColors.statusRejected)),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(child: Text('No offers found', style: AppTextStyles.bodyMedium)),
    );
  }
}
