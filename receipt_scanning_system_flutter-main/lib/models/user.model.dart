class UserModel {
  String? userId;
  String? userUsername;
  String? userPassword;
  String? userDisplayName;
  String? userAvatar;

  UserModel({
    this.userId,
    this.userUsername,
    this.userPassword,
    this.userDisplayName,
    this.userAvatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> parsedJson) {
    try {
      return UserModel(
        userId: parsedJson['_id'],
        userUsername: parsedJson['user_username'],
        userPassword: parsedJson['user_password'],
        userDisplayName: parsedJson['user_display_name'],
        userAvatar: parsedJson['user_avatar'],
      );
    } catch (ex) {
      print('UserModel ====> $ex');
      throw ('factory UserModel.fromJson ====> $ex');
    }
  }

  Map<String, dynamic> toJson() => {
        'user_username': userUsername,
        'user_password': userPassword,
        'user_display_name': userDisplayName,
        'user_avatar': userAvatar,
      };
}
