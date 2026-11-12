namespace central.Models.Comments
{
    public class UserCommentVoteInfo
    {
        public long Id { get; set; }
        public long CommentId { get; set; }
        public UserComentVoteType Type { get; set; }
    }

    public enum UserComentVoteType
    {
        Like,
        Dislike
    }
}
