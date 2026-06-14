class AppConstants {
  // API
  // استخدم --dart-define=API_URL=http://10.0.2.2:4000 للـ Android emulator
  // أو --dart-define=API_URL=http://192.168.1.x:4000 للـ device الحقيقي
  //http://techiaapi.railway.internal
  /////
  static const String baseUrl = String.fromEnvironment('API_URL',
      defaultValue: 'https://techiaapi-production.up.railway.app');
  static const String apiCandidates = '/api/candidates';
  static const String apiApplications = '/api/applications';
  static const String apiOffers = '/api/offers';
  static const String apiCommissions = '/api/commissions';
  static const String apiLogin = '/api/auth/login';
  static const String apiLogout = '/api/auth/logout';
  static const String apiMe = '/api/auth/me';
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
  static const String appTagline = 'Ship Small Things Every Single Day';
  static const String appVersion = '1.0.0';
  static const String appBuild = 'BUILD DEVELOP RUN';
  static const String appOrg = 'TECHIA';
}
