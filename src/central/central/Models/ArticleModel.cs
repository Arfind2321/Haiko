namespace central.Models
{
    public class ArticleModel
    {
        public Guid Id { get; set; }
        public Guid WriterID { get; set; }
        public string Title { get; set; } = string.Empty;
        public List<string> Tags { get; set; } = [];
        public DateTime CreationTime { get; set; } = DateTime.Now;
        public DateTime LastEditTime { get; set; } = DateTime.Now;
        public List<ArticlePartModel> Contents { get; set; } = [];

        public bool IsForked { get; set; }
        public ArticleModel? ForkedFrom { get; set; }
    }
}
