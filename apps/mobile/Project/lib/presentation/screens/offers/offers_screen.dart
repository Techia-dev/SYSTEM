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
    return LayoutBuilder(
      builder: (ctx, constraints) {
        const double minWidth = 700;
        final bool needsScroll = constraints.maxWidth < minWidth;
        final Widget table = Container(
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
                        Expanded(child: StatusBadge(label: o.isActive ? 'Active' : 'Inactive')),
                        Expanded(child: Text(formatDate(o.createdAt), style: AppTextStyles.bodySmall)),
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
        if (needsScroll) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: minWidth,
              child: table,
            ),
          );
        }
        return table;
      },
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
    if (!_didSubmit) {
      widget.titleCtrl.dispose();
      widget.companyCtrl.dispose();
      widget.descCtrl.dispose();
      widget.commissionCtrl.dispose();
      widget.delayCtrl.dispose();
    }
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
        _disposeAll();
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.error!),
            backgroundColor: Colors.red,
          ));
          setState(() { _isSubmitting = false; _didSubmit = false; });
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
                    _disposeAll();
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

  void _disposeAll() {
    widget.titleCtrl.dispose();
    widget.companyCtrl.dispose();
    widget.descCtrl.dispose();
    widget.commissionCtrl.dispose();
    widget.delayCtrl.dispose();
  }
}
