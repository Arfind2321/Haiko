class UserVoteModel 
{
    int id;
    String articlePartId;
    UserVoteType type;

    UserVoteModel(this.id, this.articlePartId, this.type);

    factory UserVoteModel.fromJson(Map<String, Object?> json) {
      return UserVoteModel(
        json['id'] as int,
        json['articlePartId'] as String,
        json['type'] == 0 ? UserVoteType.up : UserVoteType.down,
      );
    }
}

enum UserVoteType
{
    up,
    down
}