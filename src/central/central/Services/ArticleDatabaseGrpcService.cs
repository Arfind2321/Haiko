using central.Models;
using Grpc.Core;
using Haiko.Protobuf;

namespace central.Services
{
    public class ArticleDatabaseGrpcService : ArticleDatabase.ArticleDatabaseBase
    {
        private readonly ArticleService _articleService;
        public ArticleDatabaseGrpcService(ArticleService articleService)
        {
            _articleService = articleService;
        }

        public override async Task<MinimalArticle> GetMinimalArticle(ArticleRequest request, ServerCallContext context)
        {
            ArticleModel? articleModel = _articleService.GetById(Guid.Parse(request.ArticleId));

            if (articleModel == null) return new() { Ok = false };

            MinimalArticle minimalArticle = new()
            {
                Ok = true,
                Title = articleModel.Title,
                WriterId = articleModel.WriterID.ToString()
            };

            minimalArticle.Tags.Add(articleModel.Tags);

            return minimalArticle;
        }
    }
}
