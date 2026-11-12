using central.Models;
using central.Models.ArticleEditing;
using central.Models.Comments;

namespace central.Services
{
    public class VoteService
    {
        private readonly ApplicationDbContext _applicationDbContext;
        private readonly ArticleService _articleService;
        public VoteService(ApplicationDbContext applicationDbContext, ArticleService articleService) 
        {
            _applicationDbContext = applicationDbContext;
            _articleService = articleService;
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

                UpdateArticlePartVote(articlePartModel, vote);

                await _applicationDbContext.SaveChangesAsync();

                return VoteResult.Ok(true);
            }

            UserVoteInfo userVote = GetUserVote(user, pid);

            if (userVote.Type == vote)
            {
                user.UserVotes.Remove(userVote);

                UpdateArticlePartVote(articlePartModel, vote);

                await _applicationDbContext.SaveChangesAsync();

                return VoteResult.Ok(false);
            }
            else
            {
                userVote.Type = vote;

                UpdateArticlePartVote(articlePartModel, vote);

                await _applicationDbContext.SaveChangesAsync();

                return VoteResult.Ok(true);
            }
        }

        public void UpdateArticlePartVote(ArticlePartModel articlePartModel, UserVoteType vote)
        {
            if (vote == UserVoteType.Up)
            {
                articlePartModel.UpVotes++;
                articlePartModel.DownVotes--;
            }
            else
            {
                articlePartModel.UpVotes--;
                articlePartModel.DownVotes++;
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
            return user.UserVotes.FirstOrDefault(x => x.ArticlePartId == pid);
        }
    }
}
