import 'package:mess_prototype/api/api_service.dart';
import 'package:mess_prototype/models/device_info.dart';
import 'package:mess_prototype/models/device_session.dart';

class DeviceRepository {
  final ApiService apiService;

  DeviceRepository({
    required this.apiService,
  });

  Future<DeviceSession> registerCurrentDevice({
    required String token,
    required DeviceInfo deviceInfo,
  }) {
    return apiService.registerDevice(
      token: token,
      deviceId: deviceInfo.deviceId,
      deviceName: deviceInfo.deviceName,
      platform: deviceInfo.platform,
    );
  }

  Future<List<DeviceSession>> getDevices({
    required String token,
  }) {
    return apiService.getMyDevices(
      token: token,
    );
  }

  Future<void> deleteDevice({
    required String token,
    required String sessionId,
  }) {
    return apiService.deleteDevice(
      token: token,
      sessionId: sessionId,
    );
  }
}