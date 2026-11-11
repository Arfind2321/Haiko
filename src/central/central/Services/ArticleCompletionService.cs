using central.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using System.Security.Cryptography;
using TANO.Models;

namespace central.Services
{
    public class ArticleCompletionService
    {
        private readonly UserManager<UserModel> _userManager;
        private readonly ILogger<ArticleCompletionService> _logger;

        public ArticleCompletionService( UserManager<UserModel> userManager, ILogger<ArticleCompletionService> logger)
        {
            _userManager = userManager;
            _logger = logger;
        }

        public async Task<bool> ChangeCompletionStatusArticlePart(UserModel user, Guid aid, Guid apid, bool IsCompleted)
        {
            try
            {
                ArticlePartCompletionStatus ArticlePartCompletionStatus = GetCompletionStatusByArticleId(user, aid);

                if (IsCompleted)
                {
                    if (!ArticlePartCompletionStatus.CompletedPartIDs.Contains(apid))
                        ArticlePartCompletionStatus.CompletedPartIDs.Add(apid);
                }
                else
                {
                    if (ArticlePartCompletionStatus.CompletedPartIDs.Contains(apid))
                    {
                        // careful shhhh
                        // Также удаляются все id добавленные после удаляемого ( если ты не справился с шагом, то и шаги после этого тоже удаляются )
                        // Сделан акцент на то, что id ( выполнение шагов ) добавляются в хронологическом порядке
                        int removalIndex = ArticlePartCompletionStatus.CompletedPartIDs.IndexOf(apid);
                        ArticlePartCompletionStatus.CompletedPartIDs.RemoveRange(removalIndex, ArticlePartCompletionStatus.CompletedPartIDs.Count - removalIndex);
                    }    
                }
                
                await _userManager.UpdateAsync(user);

                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.ToString());
                return false;
            }
        }

        public List<Guid> GetCompletionByArticleId(UserModel user, Guid aid)
        {
            ArticlePartCompletionStatus ArticlePartCompletionStatus = GetCompletionStatusByArticleId(user, aid);

            return ArticlePartCompletionStatus.CompletedPartIDs;
        }

        public ArticlePartCompletionStatus GetCompletionStatusByArticleId(UserModel user, Guid aid)
        {
            return user.ArticlePartCompletionStatuses.FirstOrDefault(x => x.ArticleId == aid, new());
        }
    }
}
