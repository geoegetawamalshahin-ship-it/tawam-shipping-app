class AuthResult<T> {
  const AuthResult.success(this.data) : errorCode = null;

  const AuthResult.failure(this.errorCode) : data = null;

  final T? data;
  final String? errorCode;

  bool get isSuccess => errorCode == null;
}
