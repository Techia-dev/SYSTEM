import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techia_sdk/techia_sdk.dart';
import 'package:techia_ats/core/theme/app_colors.dart';
import 'package:techia_ats/core/theme/app_text_styles.dart';
import 'package:techia_ats/core/responsive/responsive.dart';
import 'package:techia_ats/blocs/offers/offers_bloc.dart';
import 'package:techia_ats/presentation/widgets/common/common_widgets.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OffersBloc>().add(OffersLoad());
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<OffersBloc>().add(OffersUpdateFilter(
      searchQuery: _searchController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OffersBloc, OffersState>(
      builder: (context, state) {
        final items = state.filteredItems;

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
                            value: state.showInactive,
                            onChanged: (v) => context.read<OffersBloc>().add(OffersUpdateFilter(showInactive: v ?? false)),
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
                    buildError(context, state.error!, () =>
                        context.read<OffersBloc>().add(OffersLoad()))
                  else if (items.isEmpty)
                    buildEmpty('No offers found')
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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final o = items[i];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accentEmerald.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                o.title.isNotEmpty ? o.title[0].toUpperCase() : '?',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.accentEmerald,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            title: Text(o.title, style: AppTextStyles.titleSmall),
            subtitle: Row(
              children: [
                Text('${o.commission.toStringAsFixed(0)} EGP', style: AppTextStyles.bodySmall),
                const SizedBox(width: 8),
                StatusBadge(label: o.isActive ? 'Active' : 'Inactive'),
              ],
            ),
            children: [
              _detailRow(Icons.business, 'Company', o.company ?? '—'),
              _detailRow(Icons.description_outlined, 'Description',
                  o.description?.isNotEmpty == true ? o.description! : '—'),
              _detailRow(Icons.attach_money, 'Commission', '${o.commission.toStringAsFixed(0)} EGP'),
              _detailRow(Icons.schedule, 'Delay', '${o.commissionDelay} days'),
              _detailRow(Icons.calendar_today, 'Created', formatDate(o.createdAt)),
              const SizedBox(height: 12),
              if (o.isActive)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.read<OffersBloc>().add(OffersDeactivate(o.id)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.statusRejected,
                      side: BorderSide(color: AppColors.statusRejected.withValues(alpha: 0.3)),
                    ),
                    child: const Text('Deactivate'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }

  void _showNewOfferDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final commissionCtrl = TextEditingController(text: '0');
    final delayCtrl = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => _OfferDialog(
        formKey: formKey,
        titleCtrl: titleCtrl,
        companyCtrl: companyCtrl,
        descCtrl: descCtrl,
        commissionCtrl: commissionCtrl,
        delayCtrl: delayCtrl,
      ),
    );
  }
}

class _OfferDialog extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleCtrl;
  final TextEditingController companyCtrl;
  final TextEditingController descCtrl;
  final TextEditingController commissionCtrl;
  final TextEditingController delayCtrl;

  const _OfferDialog({
    required this.formKey,
    required this.titleCtrl,
    required this.companyCtrl,
    required this.descCtrl,
    required this.commissionCtrl,
    required this.delayCtrl,
  });

  @override
  State<_OfferDialog> createState() => _OfferDialogState();
}

class _OfferDialogState extends State<_OfferDialog> {
  bool _isSubmitting = false;
  bool _didSubmit = false;

  @override
  void dispose() {
    widget.titleCtrl.dispose();
    widget.companyCtrl.dispose();
    widget.descCtrl.dispose();
    widget.commissionCtrl.dispose();
    widget.delayCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OffersBloc, OffersState>(
      listenWhen: (prev, curr) =>
          _didSubmit &&
          !curr.isLoading &&
          (curr.error != null || prev.items != curr.items),
      listener: (context, state) {
        _didSubmit = false;
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.error!),
            backgroundColor: Colors.red,
          ));
          setState(() { _isSubmitting = false; });
        } else {
          Navigator.pop(context);
        }
      },
      child: AlertDialog(
        title: const Text('New offer'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Form(
              key: widget.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fill in the offer details.', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 16),
                  Text('Title *', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: widget.titleCtrl,
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  Text('Company', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 4),
                  TextFormField(controller: widget.companyCtrl),
                  const SizedBox(height: 12),
                  Text('Description', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 4),
                  TextFormField(controller: widget.descCtrl, maxLines: 3),
                  const SizedBox(height: 12),
                  Text('Commission (EGP)', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 4),
                  TextFormField(controller: widget.commissionCtrl, keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  Text('Commission delay (days)', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 4),
                  TextFormField(controller: widget.delayCtrl, keyboardType: TextInputType.number),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting
                ? null
                : () {
                    _didSubmit = true;
                    Navigator.pop(context);
                  },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () {
                    if (!widget.formKey.currentState!.validate()) return;
                    setState(() { _isSubmitting = true; _didSubmit = true; });
                    final bloc = context.read<OffersBloc>();
                    bloc.add(OffersCreate({
                      'title': widget.titleCtrl.text,
                      'company': widget.companyCtrl.text,
                      'description': widget.descCtrl.text,
                      'commission': double.tryParse(widget.commissionCtrl.text) ?? 0,
                      'commission_delay': int.tryParse(widget.delayCtrl.text) ?? 0,
                    }));
                  },
            child: _isSubmitting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Add offer'),
          ),
        ],
      ),
    );
  }

}
