namespace central.Models.ArticleEditing
{
    public class ArticleEditingResult
    {
        public bool IsOk { get; set; }
        public Guid? Id { get; set; }
        public string? ErrorReason { get; set; }

        public static ArticleEditingResult Ok(Guid id)
        {
            return new() { Id = id, IsOk = true };
        }

        public static ArticleEditingResult Error(string error)
        {
            return new() { ErrorReason = error, IsOk = false };
        }
    }
}
