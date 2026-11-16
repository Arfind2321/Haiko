using central.Models;
using central.Models.Comments;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace central.Services
{
    public class CommentService
    {
        private readonly ApplicationDbContext _applicationDbContext;
        private readonly ArticleService _articleService;
        private readonly UserManager<UserModel> _userManager;
        public CommentService(ApplicationDbContext applicationDbContext, ArticleService articleService, UserManager<UserModel> userManager)
        {
            _applicationDbContext = applicationDbContext;
            _articleService = articleService;
            _userManager = userManager;
        }

        public async Task<bool> PublishComment(UserModel user, Guid pid, string content, long? commentID = null)
        {
            UserComment userComment = new()
            {
                Content = content,
                DateTime = DateTime.Now,
                UserId = user.Id
            };

            ArticlePartModel? articlePartModel = _articleService.GetPartById(pid);

            if (articlePartModel == null)
            {
                return false;
            }

            _applicationDbContext.UserComments.Add(userComment);

            if (commentID == null)
            {
                articlePartModel.Comments.Add(userComment);
            }
            else
            {
                UserComment? answeringTo = GetComment(commentID.Value);

                if (answeringTo == null)
                {
                    return false;
                }

                answeringTo.Answers.Add(userComment);
            }

            await _applicationDbContext.SaveChangesAsync();

            return true;
        }

        public async Task<bool> RemoveComment(UserModel user, long id)
        {
            UserComment? userComment = GetComment(id);

            if (userComment == null) return false;

            if (userComment.UserId != user.Id)
            {
                return false;
            }

            _applicationDbContext.UserComments.Remove(userComment);
            await _applicationDbContext.SaveChangesAsync();

            return true;
        }

        public async Task<VoteResult> VoteUnvote(UserModel user, long id, UserComentVoteType vote)
        {
            UserComment? comment = GetComment(id);

            if (comment == null) return VoteResult.Error("Нет коментария");

            if (!Voted(user, id))
            {
                UserCommentVoteInfo uvi = new()
                {
                    CommentId = id,
                    Type = vote
                };

                user.UserCommentVotes.Add(uvi);

                UpdateCommentVote(comment, vote, true);

                await _userManager.UpdateAsync(user);

                return VoteResult.Ok(true);
            }

            UserCommentVoteInfo userVote = GetUserVote(user, id)!;

            if (userVote.Type == vote)
            {
                user.UserCommentVotes.Remove(userVote);

                UpdateCommentVote(comment, vote, false);

                await _userManager.UpdateAsync(user);

                return VoteResult.Ok(false);
            }
            else
            {
                UpdateCommentVote(comment, userVote.Type, false);

                userVote.Type = vote;

                UpdateCommentVote(comment, vote, true);

                await _userManager.UpdateAsync(user);

                return VoteResult.Ok(true);
            }
        }

        public void UpdateCommentVote(UserComment articlePartModel, UserComentVoteType vote, bool isChecked)
        {
            if (vote == UserComentVoteType.Like)
            {
                if (isChecked)
                {
                    articlePartModel.Likes++;
                }
                else
                {
                    articlePartModel.Likes--;
                }
            }
            else
            {
                if (isChecked)
                {
                    articlePartModel.Dislikes++;
                }
                else
                {
                    articlePartModel.Dislikes--;
                }
            }
        }

        public bool Voted(UserModel user, long id)
        {
            return GetUserVote(user, id) != null;
        }

        public bool VotedTo(UserModel user, long id, UserComentVoteType vote)
        {
            return GetUserVote(user, id)?.Type == vote;
        }

        public UserCommentVoteInfo? GetUserVote(UserModel user, long id)
        {
            _applicationDbContext.UserCommentVotes.Load();
            return user.UserCommentVotes.FirstOrDefault(x => x.CommentId == id);
        }

        public UserComment? GetComment(long id)
        {
            _applicationDbContext.UserComments.Load();
            return _applicationDbContext.UserComments.FirstOrDefault(x => x.Id == id);
        }
    }
}
