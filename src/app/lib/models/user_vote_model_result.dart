class UserVoteResultModel 
{
    bool isOk;
    bool isChecked;
    String? error;

    UserVoteResultModel(this.isOk, this.isChecked, this.error);

    factory UserVoteResultModel.fromJson(Map<String, Object?> json) {
      return UserVoteResultModel(
        json['isOk'] as bool,
        json['isChecked'] as bool,
        json['error'] as String?,
      );
    }
}