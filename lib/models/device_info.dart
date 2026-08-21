class DeviceInfo {
  final String deviceId;
  final String deviceName;
  final String platform;

  const DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.platform
  });

  @override
  String toString() {
    return 'DeviceInfo('
      'deviceId: $deviceId, '
      'deviceName: $deviceName, '
      'platform: $platform'
      ')';
  }
}