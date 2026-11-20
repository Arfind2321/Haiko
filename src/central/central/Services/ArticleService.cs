using central.Models;
using central.Models.ArticleEditing;
using Haiko.Protobuf;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;

namespace central.Services
{
    public class ArticleService
    {
        private readonly ApplicationDbContext _applicationDbContext;
        private readonly SearcherDatabase.SearcherDatabaseClient _searcherDatabaseClient;
        private readonly UserManager<UserModel> _userManager;
        private readonly ILogger<ArticleService> _logger;
        public ArticleService(ApplicationDbContext applicationDbContext, SearcherDatabase.SearcherDatabaseClient searcherDatabaseClient, UserManager<UserModel> userManager, ILogger<ArticleService> logger)
        {
            _applicationDbContext = applicationDbContext;
            _searcherDatabaseClient = searcherDatabaseClient;
            _userManager = userManager;
            _logger = logger;
        }

        public async Task<ArticleEditingResult> CreateOrEditArticle(UserModel user, ArticleEditingRequest request)
        {
            ArticleModel articleModel = new();
            if (!request.IsNew)
            {
                ArticleModel? am = GetById(Guid.Parse(request.ArticleId), user);

                if (am == null)
                {
                    return ArticleEditingResult.Error("Нет доступа");
                }

                articleModel = am;
            }

            articleModel.Title = request.Title;
            articleModel.Tags = request.Tags;
            articleModel.WriterID = user.Id;

            articleModel.Contents.Clear();

            foreach (ArticlePartEditingModel articlePartEditingModel in request.Parts)
            {
                if (string.IsNullOrEmpty(articlePartEditingModel.Id) || articlePartEditingModel.Id == "0")
                {
                    articleModel.Contents.Add(CreatePart(articlePartEditingModel.Title, articlePartEditingModel.Content));
                }
                else
                {
                    ArticlePartModel? articlePartModel = GetPartById(Guid.Parse(articlePartEditingModel.Id));

                    if (articlePartModel != null)
                    {
                        articlePartModel.Content = articlePartEditingModel.Content;
                        articlePartModel.Title = articlePartEditingModel.Title;
                        articleModel.Contents.Add(articlePartModel);
                    }
                }
            }

            articleModel.LastEditTime = DateTime.Now;

            if (request.IsNew)
            {
                _applicationDbContext.Articles.Add(articleModel);
                user.Articles.Add(articleModel);
            }
            
            await _applicationDbContext.SaveChangesAsync();
            await _userManager.UpdateAsync(user);
            
            //StatusResponse status = await UpdateArticle(articleModel);

            if (true)//status.IsOK)
            {
                return ArticleEditingResult.Ok(articleModel.Id);
            }
            else
            {
                return ArticleEditingResult.Error("Внутренняя ошибка");
            }
        }

        public async Task<StatusResponse> UpdateArticle(ArticleModel articleModel)
        {
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
                    Title = part.Title,
                    Content = part.Content
                });
            }

            StatusResponse resp = await _searcherDatabaseClient.PushArticleChangesAsync(pushArticleChangesRequest);

            return resp;
        }

        public async Task<ArticleEditingResult> ForkArticle(UserModel user, Guid id)
        {
            ArticleModel? articleModel = GetById(id);
            if (articleModel == null)
            {
                return ArticleEditingResult.Error("Не найдено");
            }

            DateTime now = DateTime.Now;

            ArticleModel newModel = new()
            {
                IsForked = true,
                ForkedFrom = articleModel,
                Title = articleModel.Title,
                CreationTime = now,
                LastEditTime = now,
                WriterID = user.Id
            };

            foreach (var content in articleModel.Contents)
            {
                newModel.Contents.Add(CreatePart(content.Title, content.Content, false));   
            }

            newModel.Tags.AddRange(articleModel.Tags);

            _applicationDbContext.Articles.Add(newModel);
            user.Articles.Add(newModel);

            await _applicationDbContext.SaveChangesAsync();

            return ArticleEditingResult.Ok(newModel.Id);
        }

        public ArticleModel? GetById(Guid id)
        {
            _applicationDbContext.UserComments.Load();
            _applicationDbContext.ArticleParts.Load();
            _applicationDbContext.Articles.Load();

            ArticleModel? model = _applicationDbContext.Articles.Where(x => x.Id == id).FirstOrDefault();
            if (model == null) return null;

            return model;
        }

        public ArticleModel? GetById(Guid id, UserModel user)
        {
            _applicationDbContext.UserComments.Load();
            _applicationDbContext.ArticleParts.Load();
            _applicationDbContext.Articles.Load();

            ArticleModel? model = user.Articles.FirstOrDefault(x => x.Id == id);
            if (model == null) return null;

            return model;
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

        public ArticlePartModel CreatePart(string title, string content, bool autosave = true)
        {
            ArticlePartModel articlePartModel = new()
            {
                Title = title,
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
            //_applicationDbContext.UserComments.Load();

            ArticlePartModel? model = _applicationDbContext.ArticleParts.Include(x => x.Comments).Where(x => x.Id == id).FirstOrDefault();

            if (model == null) return null;

            return model;
        }
    }
}
