namespace central.Models
{
    public class ArticlePartEditingModel
    {
        public Guid? Id { get; set; }
        public string Title { get; set; } = "";
        public string Content { get; set; } = "";
    }
}
