namespace central.Models.Comments
{
    public class UserVoteInfo
    {
        public long Id { get; set; }
        public Guid ArticlePartId { get; set; }
        public UserVoteType Type { get; set; }
    }

    public enum UserVoteType
    {
        Up,
        Down
    }
}
