namespace central.Models.ArticleEditing
{
    public class ArticleEditingRequest
    {
        public Guid? ArticleId { get; set; }
        public bool IsNew => ArticleId == null;
        public string Title { get; set; } = string.Empty;
        public List<string> Tags { get; set; } = [];
        public List<ArticlePartEditingModel> Parts { get; set; } = [];
    }
}
