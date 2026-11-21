namespace central.Models
{
    public class MinimalArticleModel
    {
        public Guid id { get; set; }
        public string Title { get; set; } = "";
        public Guid WriterId { get; set; }
    }
}
