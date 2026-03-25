const String baseIp = '192.168.174.180';
const String apiPort = '8000';

String get baseUrl =>
    apiPort.isEmpty ? 'https://$baseIp' : 'http://$baseIp:$apiPort';
