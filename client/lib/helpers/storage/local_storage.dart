import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:binary_success/helpers/localizations/language.dart';
import 'package:binary_success/helpers/services/auth_services.dart';
import 'package:binary_success/helpers/theme/theme_customizer.dart';

class LocalStorage {
  static const String _loggedInUserKey = "user";
  static const String _themeCustomizerKey = "theme_customizer";
  static const String _languageKey = "lang_code";
  static const String _userRole = "user_role";
  static const String _authToken = "auth_token";
  static const String _refreshToken = "refresh_token";
  static const String _userName = "user_name";
  static const String _userID = "user_id";
  static const String _userEmail = "user_email";
  static const String _userIdDB = "user_id_db";
  static const String _entityIdDB = "role_entity_id_db";
  static const String _instituteIdDB = "institute_id_db";
  static const String _alfrescoSiteIdDB = "alfresco_site_id_db";
  static const String _bulkUploadId = "bulk_upload_id";
  static const String _csv_bulk_upload_ids = "csv_bulk_upload_ids";
  static const String _displayRoleNameDB = "display_role_name_db";
  static const String _tempUserDetailsKey = "temp_user_details"; // Add this key
  static const String _platformKey = "platform_key";
  static const String _isDemoSchool = "is_demo_school";
// Keys for LMS integration persistence
  static const String _integrationDataKey = "integration_data_key";
  static const String _integrationConnectedKey = "integration_connected_key";
  static SharedPreferences? _preferencesInstance;
  static const String _crmContactId = "crm_contact_id";
  static const String _crmAccountId = "crm_account_id";

  static SharedPreferences get preferences {
    if (_preferencesInstance == null) {
      throw ("Call LocalStorage.init() to initialize local storage");
    }
    return _preferencesInstance!;
  }

  static Future<void> init() async {
    _preferencesInstance = await SharedPreferences.getInstance();
    await initData();
  }

  static Future<void> initData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    AuthService.isLoggedIn = preferences.getBool(_loggedInUserKey) ?? false;
    ThemeCustomizer.fromJSON(preferences.getString(_themeCustomizerKey));
  }

  static Future<void> setTemporaryUserDetails(
      Map<String, String> details) async {
    await preferences.setString(_tempUserDetailsKey, jsonEncode(details));
  }

  static Map<String, String>? getTemporaryUserDetails() {
    final detailsString = preferences.getString(_tempUserDetailsKey);
    if (detailsString != null) {
      try {
        return Map<String, String>.from(jsonDecode(detailsString));
      } catch (e) {
        print('Error parsing temporary user details: $e');
        return null;
      }
    }
    return null;
  }

// Save platform value persistently
  static Future<bool> setPlatform(String platform) async {
    return preferences.setString(_platformKey, platform);
  }

// Retrieve platform value (returns null if not set)
  static String? getPlatform() {
    return preferences.getString(_platformKey);
  }

  static String? get(String key) {
    return preferences.getString(key);
  }

// Save integration data as JSON string
  static Future<bool> setIntegrationData(String jsonData) async {
    return preferences.setString(_integrationDataKey, jsonData);
  }

// Retrieve integration data JSON string
  static String? getIntegrationData() {
    return preferences.getString(_integrationDataKey);
  }

// Save connection status boolean
  static Future<bool> setIntegrationConnected(bool connected) async {
    return preferences.setBool(_integrationConnectedKey, connected);
  }

// Retrieve connection status, default false if not set
  static bool getIntegrationConnected() {
    return preferences.getBool(_integrationConnectedKey) ?? false;
  }

// Clear integration related data and flags
  static Future<void> clearIntegration() async {
    await preferences.remove(_integrationDataKey);
    await preferences.remove(_integrationConnectedKey);
  }

  static Future<void> clearTemporaryUserDetails() async {
    await preferences.remove(_tempUserDetailsKey);
  }

  static Future<bool> setAuthToken(String token) {
    return preferences.setString(_authToken, token);
  }

  static String? getAuthToken() {
    return preferences.getString(_authToken);
  }

  static Future<bool> setUserID(String token) {
    return preferences.setString(_userID, token);
  }

  static String? getUserID() {
    return preferences.getString(_userID);
  }

  static Future<bool> setDBUserID(String token) {
    return preferences.setString(_userIdDB, token);
  }

  static String? getDBUserID() {
    return preferences.getString(_userIdDB);
  }

  static Future<bool> setDBEntityID(String token) {
    return preferences.setString(_entityIdDB, token);
  }

  static String? getDBEntityID() {
    return preferences.getString(_entityIdDB);
  }

  static String? getIsDemoSchool() {
    return preferences.getString(_isDemoSchool);
  }

  static Future<bool> setIsDemoSchool(String value) {
    return preferences.setString(_isDemoSchool, value);
  }

  static Future<bool> setDBInstituteID(String token) {
    return preferences.setString(_instituteIdDB, token);
  }

  static String? getDBInstituteID() {
    return preferences.getString(_instituteIdDB);
  }

  static Future<bool> setAlfrescoSiteID(String siteId) {
    return preferences.setString(_alfrescoSiteIdDB, siteId);
  }

  static String? getAlfrescoSiteID() {
    return preferences.getString(_alfrescoSiteIdDB);
  }

  static Future<bool> setBulkUploadID(String bulkUploadId) {
    return preferences.setString(_bulkUploadId, bulkUploadId);
  }

  static String? getBulkUploadID() {
    return preferences.getString(_bulkUploadId);
  }

  static Future<bool> removeBulkUploadID() {
    return preferences.remove(_bulkUploadId);
  }

  static Future<bool> setCsvBulkUploadIds(List<String> bulkUploadIds) {
    final String bulkUploadIdsString = jsonEncode(bulkUploadIds);
    return preferences.setString(_csv_bulk_upload_ids, bulkUploadIdsString);
  }

  static List<String>? getCsvBulkUploadIds() {
    final bulkUploadIds = preferences.getString(_csv_bulk_upload_ids);
    return bulkUploadIds != null
        ? List<String>.from(jsonDecode(bulkUploadIds))
        : null;
  }

  static Future<bool> removeCsvBulkUploadIds() {
    return preferences.remove(_csv_bulk_upload_ids);
  }

  static Future<bool> setDBDisplayRoleName(String token) {
    return preferences.setString(_displayRoleNameDB, token);
  }

  static String? getDBDisplayRoleName() {
    return preferences.getString(_displayRoleNameDB);
  }

  static Future<bool> setRefreshToken(String token) {
    return preferences.setString(_refreshToken, token);
  }

  static String? getRefreshTokenn() {
    return preferences.getString(_refreshToken);
  }

  static Future<bool> setUserName(String token) {
    return preferences.setString(_userName, token);
  }

  static String? getUserName() {
    return preferences.getString(_userName);
  }

  static Future<bool> setLoggedInUser(bool loggedIn) async {
    return preferences.setBool(_loggedInUserKey, loggedIn);
  }

  static Future<bool> setCustomizer(ThemeCustomizer themeCustomizer) {
    return preferences.setString(_themeCustomizerKey, themeCustomizer.toJSON());
  }

  static Future<bool> setLanguage(Language language) {
    return preferences.setString(_languageKey, language.locale.languageCode);
  }

  static String? getLanguage() {
    return preferences.getString(_languageKey);
  }

  static Future<bool> setUserRole(String role) {
    return preferences.setString(_userRole, role);
  }

  static String? getUserRole() {
    return preferences.getString(_userRole);
  }

  static Future<bool> setUserEmail(String email) {
    return preferences.setString(_userEmail, email);
  }

  static String? getUserEmail() {
    return preferences.getString(_userEmail);
  }

  static Future<bool> removeLoggedInUser() async {
    return preferences.remove(_loggedInUserKey);
  }

  static Future<bool> erase() async {
    return preferences.clear();
  }

  static Future<bool> setCRMContactId(String id) async {
    return preferences.setString(_crmContactId, id); // ✅ keep as String
  }

  static String? getCRMContactId() {
    return preferences.getString(_crmContactId); // ✅ fetch as String
  }

  static Future<bool> setCRMAccountId(String id) async {
    return preferences.setString(_crmAccountId, id);
  }

  static String? getCRMAccountId() {
    return preferences.getString(_crmAccountId);
  }
}
