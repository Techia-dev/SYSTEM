import 'package:flutter/material.dart' hide DateUtils;
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/application_model.dart';
import '../../../providers/applications_provider.dart';
import '../../widgets/common/common_widgets.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationsProvider>().loadApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Consumer<ApplicationsProvider>(
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

  Widget _buildHeader(ApplicationsProvider provider) {
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
          child: const Text('APPLICATIONS TRACKING', style: AppTextStyles.labelMedium),
        ),
        const SizedBox(height: 12),
        Text('Applications', style: AppTextStyles.displayLarge),
        const SizedBox(height: 6),
        Text(
          'Track candidate applications and manage their pipeline status.',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildContent(ApplicationsProvider provider) {
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

    if (provider.applications.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: Text('No applications found', style: AppTextStyles.bodyMedium),
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
          ...provider.applications.map((app) => _ApplicationRow(application: app)),
        ],
      ),
    );
  }

  Widget _buildListHeader(ApplicationsProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const SectionChip(label: 'All Applications'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              '${provider.applications.length} app${provider.applications.length == 1 ? '' : 's'}',
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeaderRow() {
    const headers = ['CANDIDATE', 'OFFER', 'STATUS', 'SOURCE', 'CREATED'];
    const flexes = [3, 3, 1, 2, 2];

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

class _ApplicationRow extends StatelessWidget {
  final Application application;
  const _ApplicationRow({required this.application});

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
                Text(
                  application.candidateName.isEmpty
                      ? application.candidateId
                      : application.candidateName,
                  style: AppTextStyles.titleSmall,
                ),
                Text(application.id, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              application.offerTitle.isEmpty
                  ? application.offerId
                  : application.offerTitle,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Expanded(
            flex: 1,
            child: StatusBadge(label: application.status),
          ),
          Expanded(
            flex: 2,
            child: Text(
              application.source ?? 'N/A',
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              DateUtils.formatDate(application.createdAt),
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
