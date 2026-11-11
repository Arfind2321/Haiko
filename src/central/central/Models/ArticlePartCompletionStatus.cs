namespace central.Models
{
    public class ArticlePartCompletionStatus
    {
        public Guid Id { get; set; }
        public Guid ArticleId { get; set; }
        public List<Guid> CompletedPartIDs { get; set; } = [];
    }
}
