const String baseIp = '192.168.170.157';
const String apiPort = '8000';

String get baseUrl =>
    apiPort.isEmpty ? 'https://$baseIp' : 'http://$baseIp:$apiPort';
