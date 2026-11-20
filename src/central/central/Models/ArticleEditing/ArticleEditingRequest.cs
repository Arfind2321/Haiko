namespace central.Models.ArticleEditing
{
    public class ArticleEditingRequest
    {
        public string ArticleId { get; set; } = "";
        public bool IsNew => string.IsNullOrEmpty(ArticleId) || ArticleId == "0";
        public string Title { get; set; } = string.Empty;
        public List<string> Tags { get; set; } = [];
        public List<ArticlePartEditingModel> Parts { get; set; } = [];
    }
}
