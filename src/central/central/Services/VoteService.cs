using central.Models;
using central.Models.ArticleEditing;
using central.Models.Comments;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace central.Services
{
    public class VoteService
    {
        private readonly ApplicationDbContext _applicationDbContext;
        private readonly ArticleService _articleService;
        private readonly UserManager<UserModel> _userManager;
        public VoteService(ApplicationDbContext applicationDbContext, ArticleService articleService, UserManager<UserModel> userManager) 
        {
            _applicationDbContext = applicationDbContext;
            _articleService = articleService;
            _userManager = userManager;
        }

        public async Task<VoteResult> VoteUnvote(UserModel user, Guid pid, UserVoteType vote)
        {
            ArticlePartModel? articlePartModel = _articleService.GetPartById(pid);

            if (articlePartModel == null) return VoteResult.Error("Нет шага статьи");

            if (!Voted(user, pid))
            {
                UserVoteInfo uvi = new()
                {
                    ArticlePartId = pid,
                    Type = vote
                };

                user.UserVotes.Add(uvi);

                UpdateArticlePartVote(articlePartModel, vote, true);

                await _userManager.UpdateAsync(user);

                return VoteResult.Ok(true);
            }

            UserVoteInfo userVote = GetUserVote(user, pid)!;

            if (userVote.Type == vote)
            {
                user.UserVotes.Remove(userVote);

                UpdateArticlePartVote(articlePartModel, vote, false);

                await _userManager.UpdateAsync(user);

                return VoteResult.Ok(false);
            }
            else
            {
                UpdateArticlePartVote(articlePartModel, userVote.Type, false);

                userVote.Type = vote;

                UpdateArticlePartVote(articlePartModel, vote, true);

                await _userManager.UpdateAsync(user);

                return VoteResult.Ok(true);
            }
        }

        public void UpdateArticlePartVote(ArticlePartModel articlePartModel, UserVoteType vote, bool isChecked)
        {
            if (vote == UserVoteType.Up)
            {
                if (isChecked)
                {
                    articlePartModel.UpVotes++;
                }
                else
                {
                    articlePartModel.UpVotes--;
                }
            }
            else
            {
                if (isChecked)
                {
                    articlePartModel.DownVotes++;
                }
                else
                {
                    articlePartModel.DownVotes--;
                }
            }
        }

        public bool Voted(UserModel user, Guid pid)
        {
            return GetUserVote(user, pid) != null;
        }

        public bool VotedTo(UserModel user, Guid pid, UserVoteType vote)
        {
            return GetUserVote(user, pid)?.Type == vote;
        }

        public UserVoteInfo? GetUserVote(UserModel user, Guid pid)
        {
            _applicationDbContext.UserVotes.Load();
            return user.UserVotes.FirstOrDefault(x => x.ArticlePartId == pid);
        }
    }
}
