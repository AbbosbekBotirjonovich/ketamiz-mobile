class HttpResult {
  final bool isSuccess;
  final int status;
  final dynamic result;

  HttpResult({
    required this.isSuccess,
    required this.result,
    required this.status,
  });
}
