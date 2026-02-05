const String baseIp = '127.0.0.1';
const String apiPort = '8000';

String get baseUrl =>
    apiPort.isEmpty ? 'https://$baseIp' : 'http://$baseIp:$apiPort';
