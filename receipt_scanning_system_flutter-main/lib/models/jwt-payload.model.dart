class JwtPayloadModel {
  String? userId;

  JwtPayloadModel({this.userId});

  factory JwtPayloadModel.fromJson(Map<String, dynamic> parsedJson) {
    try {
      return JwtPayloadModel(
        userId: parsedJson['user_id'],
      );
    } catch (ex) {
      print('JwtPayloadModel ====> $ex');
      throw ('factory JwtPayloadModel.fromJson ====> $ex');
    }
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
      };
}
