import 'package:flutter/material.dart' hide DateUtils;
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/offer_model.dart';
import '../../../providers/offers_provider.dart';
import '../../widgets/common/common_widgets.dart';

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
      context.read<OffersProvider>().loadOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Consumer<OffersProvider>(
            builder: (context, provider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(provider),
                  const SizedBox(height: 32),
                  _buildContent(provider),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(OffersProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: const Text('OFFERS MANAGEMENT', style: AppTextStyles.labelMedium),
        ),
        const SizedBox(height: 12),
        Text('Offers', style: AppTextStyles.displayLarge),
        const SizedBox(height: 6),
        Text(
          'Manage job offers, commissions, and availability.',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildContent(OffersProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: CircularProgressIndicator(color: AppColors.accentCyan),
        ),
      );
    }

    if (provider.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(60),
          child: Text(
            provider.errorMessage ?? 'An error occurred',
            style: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFFEF4444)),
          ),
        ),
      );
    }

    if (provider.offers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: Text('No offers found', style: AppTextStyles.bodyMedium),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildListHeader(provider),
          const Divider(height: 1),
          _buildListHeaderRow(),
          const Divider(height: 1),
          ...provider.offers.map((offer) => _OfferRow(offer: offer)),
        ],
      ),
    );
  }

  Widget _buildListHeader(OffersProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const SectionChip(label: 'All Offers'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              '${provider.offers.length} offer${provider.offers.length == 1 ? '' : 's'}',
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeaderRow() {
    const headers = ['TITLE', 'COMPANY', 'COMMISSION', 'DELAY', 'STATUS', 'CREATED'];
    const flexes = [3, 2, 2, 1, 1, 2];

    return Container(
      color: AppColors.bgSurface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: headers.asMap().entries.map((entry) {
          return Expanded(
            flex: flexes[entry.key],
            child: Text(
              entry.value,
              style: AppTextStyles.labelLarge.copyWith(fontSize: 11),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _OfferRow extends StatelessWidget {
  final Offer offer;
  const _OfferRow({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(offer.title, style: AppTextStyles.titleSmall),
                Text(offer.id, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              offer.company ?? 'N/A',
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '\$${offer.commission.toStringAsFixed(2)}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.accentCyan,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${offer.commissionDelay}d',
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: offer.isActive
                    ? const Color(0xFF064E3B)
                    : const Color(0xFF3B0A0A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                offer.isActive ? 'Active' : 'Inactive',
                style: AppTextStyles.bodySmall.copyWith(
                  color: offer.isActive
                      ? const Color(0xFF34D399)
                      : const Color(0xFFEF4444),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              DateUtils.formatDate(offer.createdAt),
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
