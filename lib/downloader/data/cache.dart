import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedCahche extends GetxController {
  static const String _listOfUrlsKey = 'listOfUrls';
  static const String _isPauseKey = 'isPause';
  static const String _downloadPercentageKey = 'downloadPercentage';
  static const String _totalContentLengthKey = 'totalContentLength';
  static const String _statusKey = 'status';
  static const String _checkIfDownloadCompleteKey = 'checkIfDownloadComplete';
  static const String _contentLengthKey = 'contentLength';

  Future<SharedPreferences> _getSharedPreferencesInstance() async {
    return await SharedPreferences.getInstance();
  }

  Future<List<String>> getListOfUrls() async {
    final sharedPreferences = await _getSharedPreferencesInstance();
    final listOfUrls = sharedPreferences.getStringList(_listOfUrlsKey) ?? [];
    return listOfUrls;
  }

  Future<void> setListOfUrls(List<String> listOfUrls) async {
    final sharedPreferences = await _getSharedPreferencesInstance();
    await sharedPreferences.setStringList(_listOfUrlsKey, listOfUrls);
  }

  Future<bool> getIsPause() async {
    final sharedPreferences = await _getSharedPreferencesInstance();
    final isPause = sharedPreferences.getBool(_isPauseKey) ?? false;
    return isPause;
  }

  Future<void> setIsPause(bool isPause) async {
    final sharedPreferences = await _getSharedPreferencesInstance();
    await sharedPreferences.setBool(_isPauseKey, isPause);
  }

  Future<int> getDownloadPercentage() async {
    final sharedPreferences = await _getSharedPreferencesInstance();
    final downloadPercentage =
        sharedPreferences.getInt(_downloadPercentageKey) ?? 0;
    return downloadPercentage;
  }

  Future<void> setDownloadPercentage(int downloadPercentage) async {
    final sharedPreferences = await _getSharedPreferencesInstance();
    await sharedPreferences.setInt(_downloadPercentageKey, downloadPercentage);
  }

  Future<double> getTotalContentLength() async {
    final sharedPreferences = await _getSharedPreferencesInstance();
    final totalContentLength =
        sharedPreferences.getDouble(_totalContentLengthKey) ?? 0.0;
    return totalContentLength;
  }

  Future<void> setTotalContentLength(double totalContentLength) async {
    final sharedPreferences = await _getSharedPreferencesInstance();
    await sharedPreferences.setDouble(
        _totalContentLengthKey, totalContentLength);
  }

  Future<String> getStatus() async {
    final sharedPreferences = await _getSharedPreferencesInstance();
    final status =
        sharedPreferences.getString(_statusKey) ?? 'Start Download Now';
    return status;
  }

  Future<void> setStatus(String status) async {
    final sharedPreferences = await _getSharedPreferencesInstance();
    await sharedPreferences.setString(_statusKey, status);
  }

  Future<bool> getCheckIfDownloadComplete() async {
    final sharedPreferences = await _getSharedPreferencesInstance();
    final checkIfDownloadComplete =
        sharedPreferences.getBool(_checkIfDownloadCompleteKey) ?? false;
    return checkIfDownloadComplete;
  }

  Future<void> setCheckIfDownloadComplete(bool checkIfDownloadComplete) async {
    final sharedPreferences = await _getSharedPreferencesInstance();
    await sharedPreferences.setBool(
        _checkIfDownloadCompleteKey, checkIfDownloadComplete);
  }

  Future<double> getContentLength() async {
    final sharedPreferences = await _getSharedPreferencesInstance();
    final contentLength = sharedPreferences.getDouble(_contentLengthKey) ?? 0.0;
    return contentLength;
  }

  Future<void> setContentLength(double contentLength) async {
    final sharedPreferences = await _getSharedPreferencesInstance();
    await sharedPreferences.setDouble(_contentLengthKey, contentLength);
  }
//   List<String> listOfUrls = await MySharedPreferences.getListOfUrls();
// bool isPause = await MySharedPreferences.getIsPause();
// int downloadPercentage = await MySharedPreferences.getDownloadPercentage();
// double totalContentLength = await MySharedPreferences.getTotalContentLength();
// String status = await MySharedPreferences.getStatus();
// Future<bool>  checkIfDownloadComplete =   SharedCahche.getCheckIfDownloadComplete();
// double contentLength = await MySharedPreferences.getContentLength();
}
