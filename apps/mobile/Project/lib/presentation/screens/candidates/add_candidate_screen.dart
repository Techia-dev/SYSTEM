import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techia_ats/core/theme/app_colors.dart';
import 'package:techia_ats/core/theme/app_text_styles.dart';
import 'package:techia_ats/core/responsive/responsive.dart';
import 'package:techia_ats/blocs/candidates/candidates_bloc.dart';

class AddCandidateScreen extends StatefulWidget {
  const AddCandidateScreen({super.key});

  @override
  State<AddCandidateScreen> createState() => _AddCandidateScreenState();
}

class _AddCandidateScreenState extends State<AddCandidateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _selectedCode = '+20';
  String _selectedLevel = 'Junior';
  bool _isSubmitting = false;
  bool _didSubmit = false;

  static const _countryCodes = [
    ('+20', '\u{1F1F9}\u{1F1EC} Egypt'),
    ('+1', '\u{1F1FA}\u{1F1F8} USA'),
    ('+44', '\u{1F1EC}\u{1F1E7} UK'),
    ('+971', '\u{1F1E6}\u{1F1EA} UAE'),
    ('+966', '\u{1F1F8}\u{1F1E6} Saudi Arabia'),
    ('+962', '\u{1F1F2}\u{1F1F4} Jordan'),
    ('+961', '\u{1F1F1}\u{1F1E7} Lebanon'),
    ('+965', '\u{1F1F0}\u{1F1FC} Kuwait'),
    ('+974', '\u{1F1F6}\u{1F1E6} Qatar'),
    ('+973', '\u{1F1E7}\u{1F1ED} Bahrain'),
    ('+968', '\u{1F1F9}\u{1F1F2} Oman'),
    ('+213', '\u{1F1E9}\u{1F1FF} Algeria'),
    ('+212', '\u{1F1F2}\u{1F1E6} Morocco'),
    ('+216', '\u{1F1F9}\u{1F1F3} Tunisia'),
    ('+49', '\u{1F1E9}\u{1F1EA} Germany'),
    ('+33', '\u{1F1EB}\u{1F1F7} France'),
    ('+91', '\u{1F1EE}\u{1F1F3} India'),
    ('+86', '\u{1F1E8}\u{1F1F3} China'),
  ];

  static final _countryMenuItems = _countryCodes.map((c) =>
    DropdownMenuItem(value: c.$1, child: Text('${c.$2}', style: AppTextStyles.bodySmall))
  ).toList(growable: false);

  static const _levelItems = ['Junior', 'Mid', 'Senior'];
  static final _levelMenuItems = _levelItems.map((s) =>
    DropdownMenuItem(value: s, child: Text(s, style: AppTextStyles.bodyMedium))
  ).toList(growable: false);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = getScreenSize(context);

    return BlocConsumer<CandidatesBloc, CandidatesState>(
      listenWhen: (prev, curr) =>
          _didSubmit &&
          !curr.isLoading &&
          (curr.error != null || prev.lastSynced != curr.lastSynced),
      listener: (context, state) {
        if (!mounted) return;
        _didSubmit = false;
        setState(() => _isSubmitting = false);
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.error!),
            backgroundColor: Colors.red,
          ));
        } else {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('New candidate'),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(screen == ScreenSize.mobile ? 16 : 32),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (screen != ScreenSize.mobile) ...[
                        Text('New candidate', style: AppTextStyles.headlineLarge),
                        const SizedBox(height: 4),
                        Text('Fill in the candidate details', style: AppTextStyles.bodySmall),
                        const SizedBox(height: 24),
                      ],
                      // Name
                      _FieldLabel('Name *'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameCtrl,
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                        decoration: const InputDecoration(hintText: 'Full name'),
                      ),
                      const SizedBox(height: 16),
                      // Phone with country code
                      _FieldLabel('Phone *'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 140,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCode,
                                isExpanded: true,
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                                items: _countryMenuItems,
                                onChanged: (v) => setState(() => _selectedCode = v!),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                              decoration: const InputDecoration(hintText: '123 456 789'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Email
                      _FieldLabel('Email'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                        decoration: const InputDecoration(hintText: 'email@example.com'),
                      ),
                      const SizedBox(height: 16),
                      // Level
                      _FieldLabel('Level'),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedLevel,
                            isExpanded: true,
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                            items: _levelMenuItems,
                            onChanged: (v) => setState(() => _selectedLevel = v!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Submit
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          child: _isSubmitting
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Add candidate'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    _didSubmit = true;

    final fullPhone = '$_selectedCode ${_phoneCtrl.text}';

    context.read<CandidatesBloc>().add(CandidatesCreate({
      'name': _nameCtrl.text,
      'phone': fullPhone,
      'email': _emailCtrl.text,
      'level': _selectedLevel.toLowerCase(),
    }));
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.bodySmall.copyWith(
      color: AppColors.textLabel,
      fontWeight: FontWeight.w500,
      fontSize: 12,
    ));
  }
}
