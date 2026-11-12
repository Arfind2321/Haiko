using central.Models.Comments;

namespace central.Models
{
    public class ArticlePartModel
    {
        public Guid Id { get; set; }
        public string Content { get; set; } = "";
        public long UpVotes { get; set; }
        public long DownVotes { get; set; }
        public List<UserComment> Comments { get; set; } = [];
    }
}
