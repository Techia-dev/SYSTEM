import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techia_sdk/techia_sdk.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../bloc/offers_bloc.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OffersBloc>().add(OffersLoad());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OffersBloc, OffersState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!), backgroundColor: Colors.red));
          context.read<OffersBloc>().add(OffersClearError());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: screenPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Offers', style: AppTextStyles.displayMedium),
                            const SizedBox(height: 6),
                            const SectionChip(label: 'Recruitment'),
                            const SizedBox(height: 4),
                            Text(state.matchingText, style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      AppPrimaryButton(
                        label: 'Add Offer',
                        icon: Icons.add,
                        onPressed: () => _showOfferDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search offers...',
                            prefixIcon: Icon(Icons.search, size: 20),
                          ),
                          onChanged: (v) => context.read<OffersBloc>().add(OffersUpdateFilter(searchQuery: v)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilterChip(
                        label: const Text('Show inactive'),
                        selected: state.showInactive,
                        onSelected: (v) => context.read<OffersBloc>().add(OffersUpdateFilter(showInactive: v)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state.isLoading)
                    const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                  else if (state.filteredItems.isEmpty)
                    Center(child: Padding(padding: const EdgeInsets.all(32), child: buildEmpty(context, 'No offers found')))
                  else
                    ...state.filteredItems.map((offer) => _buildOfferCard(context, offer)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOfferCard(BuildContext context, Offer offer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(offer.title, style: AppTextStyles.titleSmall),
                    const SizedBox(width: 8),
                    if (!offer.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                        child: const Text('Inactive', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(offer.company ?? '—', style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                Text('${offer.commission.toStringAsFixed(0)} EGP — due ${offer.commissionDelay}d', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          if (offer.isActive)
            TextButton.icon(
              onPressed: () => _confirmDeactivate(context, offer.id),
              icon: const Icon(Icons.block, size: 16, color: AppColors.error),
              label: const Text('Deactivate', style: TextStyle(color: AppColors.error, fontSize: 13)),
            ),
        ],
      ),
    );
  }

  void _confirmDeactivate(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate Offer'),
        content: const Text('Are you sure? This will hide the offer from active listings.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<OffersBloc>().add(OffersDeactivate(id));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _showOfferDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final commissionCtrl = TextEditingController(text: '0');
    final delayCtrl = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Offer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title *')),
              const SizedBox(height: 12),
              TextField(controller: companyCtrl, decoration: const InputDecoration(labelText: 'Company')),
              const SizedBox(height: 12),
              TextField(controller: commissionCtrl, decoration: const InputDecoration(labelText: 'Commission'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(controller: delayCtrl, decoration: const InputDecoration(labelText: 'Commission delay (days)'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                context.read<OffersBloc>().add(OffersCreate({
                  'title': titleCtrl.text,
                  if (companyCtrl.text.isNotEmpty) 'company': companyCtrl.text,
                  'commission': double.tryParse(commissionCtrl.text) ?? 0,
                  'commissionDelay': int.tryParse(delayCtrl.text) ?? 0,
                }));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
