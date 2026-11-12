using central.Models;
using central.Models.ArticleEditing;
using central.Models.Comments;
using central.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace central.Controllers
{
    [Route("voting")]
    [ApiController]
    public class VotingController : ControllerBase
    {
        private readonly ArticleService _articleService;
        private readonly UserManager<UserModel> _userManager;
        private readonly VoteService _voteService;

        public VotingController(ArticleService articleService, UserManager<UserModel> userManager, VoteService voteService)
        {
            _articleService = articleService;
            _userManager = userManager;
            _voteService = voteService;
        }

        [HttpGet("voteUnvote")]
        [Authorize]
        public async Task<IActionResult> VoteUnvote([FromQuery]Guid id, [FromQuery]UserVoteType type)
        {
            if (User.Identity == null) return Unauthorized();
            if (!User.Identity.IsAuthenticated) return Unauthorized();
            if (string.IsNullOrEmpty(User.Identity.Name)) return Unauthorized();

            UserModel? userModel = await _userManager.FindByIdAsync(User.Identity.Name);

            if (userModel == null) return Unauthorized();

            VoteResult result = await _voteService.VoteUnvote(userModel, id, type);

            return Ok(result);
        }
    }
}
