abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Đã có lỗi xảy ra từ máy chủ']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Kết nối mạng không ổn định']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Xác thực không thành công']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Lỗi truy xuất bộ nhớ tạm']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
