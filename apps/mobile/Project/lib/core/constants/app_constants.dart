class AppConstants {
  // API
  static const String baseUrl = 'apps/api — localhost:4000';
  static const String apiCandidates = '/api/candidates';
  static const String apiLogin = '/api/auth/login';
  static const String apiLogout = '/api/auth/logout';
  static const String apiAdvanceStage = '/api/candidates/{id}/advance';

  // Pipeline Stages
  static const String stageApplied = 'applied';
  static const String stageInterview = 'interview';
  static const String stageHired = 'hired';

  static const List<String> pipelineStages = [
    stageApplied,
    stageInterview,
    stageHired,
  ];

  // Candidate Levels
  static const List<String> candidateLevels = [
    'All levels',
    'B1',
    'B2',
    'C1',
    'C2',
    'Junior',
    'Mid',
    'Senior',
  ];

  // Status filters
  static const List<String> statusFilters = [
    'All statuses',
    'applied',
    'interview',
    'hired',
  ];

  // Pagination
  static const int pageSize = 10;

  // Local storage keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserEmail = 'user_email';
  static const String keySessionData = 'session_data';

  // App info
  static const String appName = 'Techia ATS';
  static const String appTagline = 'SHIP Small Things Every Single Day 🚀';
  static const String appVersion = '1.0.0';
  static const String appBuild = 'BUILD DEVELOP RUN';
  static const String appOrg = 'TECHIA';
}
