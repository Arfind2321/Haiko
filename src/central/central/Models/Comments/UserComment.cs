namespace central.Models.Comments
{
    public class UserComment
    {
        public long Id { get; set; }
        public Guid UserId { get; set; }
        public string Content { get; set; } = string.Empty;
        public DateTime DateTime { get; set; }
        public long Likes { get; set; }
        public long Dislikes { get; set; }
        public List<UserComment> Answers { get; set; } = [];
    }
}
