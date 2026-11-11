using central.Models;
using central.Models.ArticleEditing;
using Haiko.Protobuf;
using TANO.Models;

namespace central.Services
{
    public class ArticleService
    {
        private readonly ApplicationDbContext _applicationDbContext;
        private readonly SearcherDatabase.SearcherDatabaseClient _searcherDatabaseClient;
        public ArticleService(ApplicationDbContext applicationDbContext, SearcherDatabase.SearcherDatabaseClient searcherDatabaseClient)
        {
            _applicationDbContext = applicationDbContext;
            _searcherDatabaseClient = searcherDatabaseClient;
        }

        public async Task<ArticleEditingResult> CreateOrEditArticle(UserModel user, ArticleEditingRequest request)
        {
            ArticleModel articleModel = new();
            if (!request.IsNew)
            {
                ArticleModel? am = GetById(request.ArticleId.Value, user);

                if (am == null)
                {
                    return ArticleEditingResult.Error("Нет доступа");
                }

                articleModel = am;
            }

            articleModel.Title = request.Title;
            articleModel.Tags = request.Tags;
            articleModel.WriterID = user.Id;

            List<ArticlePartModel> newArticlePartList = [];

            foreach (ArticlePartEditingModel articlePartEditingModel in request.Parts)
            {
                if (articlePartEditingModel.Id == null)
                {
                    newArticlePartList.Add(CreatePart(articlePartEditingModel.Content));
                }
                else
                {
                    ArticlePartModel? articlePartModel = GetPartById(articlePartEditingModel.Id.Value);

                    if (articlePartModel != null)
                    {
                        articlePartModel.Content = articlePartEditingModel.Content;
                        newArticlePartList.Add(articlePartModel);
                    }
                }
            }

            articleModel.Contents = newArticlePartList;

            articleModel.LastEditTime = DateTime.Now;

            if (request.IsNew)
            {
                _applicationDbContext.Articles.Add(articleModel);
                user.Articles.Add(articleModel);
            }

            _applicationDbContext.SaveChanges();

            PushArticleChangesRequest pushArticleChangesRequest = new PushArticleChangesRequest()
            {
                ArticleId = articleModel.Id.ToString(),
                Title = articleModel.Title
            };

            pushArticleChangesRequest.Tags.AddRange(articleModel.Tags);

            foreach (var part in articleModel.Contents)
            {
                pushArticleChangesRequest.Parts.Add(new ArticlePartChanges()
                {
                    Id = part.Id.ToString(),
                    Content = part.Content
                });
            }

            StatusResponse resp = await _searcherDatabaseClient.PushArticleChangesAsync(pushArticleChangesRequest);

            if (resp.IsOK)
            {
                return ArticleEditingResult.Ok(articleModel.Id);
            }
            else
            {
                return ArticleEditingResult.Error("Внутренняя ошибка");
            }
        }

        public ArticleModel? GetById(Guid id)
        {
            return _applicationDbContext.Articles.Where(x => x.Id == id).FirstOrDefault();
        }

        public ArticleModel? GetById(Guid id, UserModel user)
        {
            return user.Articles.FirstOrDefault(x => x.Id == id);
        }

        public async Task<ArticleEditingResult> RemoveById(UserModel user, Guid id)
        {
            ArticleModel? article = GetById(id, user);

            if (article == null) return ArticleEditingResult.Error("Нет доступа");

            user.Articles.Remove(article);
            _applicationDbContext.Articles.Remove(article);

            _applicationDbContext.SaveChanges();

            return ArticleEditingResult.Ok(id);
        }

        public ArticlePartModel CreatePart(string content, bool autosave = true)
        {
            ArticlePartModel articlePartModel = new()
            {
                Content = content
            };

            _applicationDbContext.ArticleParts.Add(articlePartModel);

            if (autosave)
            {
                _applicationDbContext.SaveChanges();
            }
            
            return articlePartModel;
        }

        public ArticlePartModel? GetPartById(Guid id)
        {
            return _applicationDbContext.ArticleParts.Where(x => x.Id == id).FirstOrDefault();
        }
    }
}
