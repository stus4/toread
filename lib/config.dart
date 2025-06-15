const String baseIp = '192.168.1.5'; // змінюється тут
const String apiPort = '8000'; // якщо треба

String get baseUrl => 'http://$baseIp:$apiPort';
