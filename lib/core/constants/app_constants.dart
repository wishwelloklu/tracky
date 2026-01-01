class AppConstants {
  static const String appName = 'Traky';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userRoleKey = 'user_role';
  static const String userDataKey = 'user_data';
  static const String packagesKey = 'packages';
  static const String reportsKey = 'reports';
  
  // API Endpoints (Mock)
  static const String baseUrl = 'https://api.traky.com/v1';
  static const String loginEndpoint = '/auth/login';
  static const String packagesEndpoint = '/packages';
  static const String reportsEndpoint = '/reports';
  
  // Mineral Types
  static const List<String> mineralTypes = [
    'Gold Dust',
    'Gold Nuggets', 
    'Raw Gold',
    'Processed Gold',
    'Alluvial Gold',
  ];
  
  // Grade Options
  static const List<String> gradeOptions = [
    '18K',
    '20K', 
    '22K',
    '24K',
    'Mixed Grade',
  ];
  
  // Package Status
  static const String statusPending = 'pending';
  static const String statusVerified = 'verified';
  static const String statusRejected = 'rejected';
  
  // User Roles
  static const String roleMiner = 'miner';
  static const String roleOfficial = 'official';
}