using central.Models;
using central.Models.ArticleEditing;
using central.Models.Comments;
using central.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace central.Controllers
{
    [Route("voting")]
    [ApiController]
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
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
        public async Task<IActionResult> VoteUnvote([FromQuery]Guid id, [FromQuery]UserVoteType type)
        {
            if (User.Identity == null) return Unauthorized();
            if (string.IsNullOrEmpty(User.Identity.Name)) return Unauthorized();

            UserModel? userModel = await _userManager.FindByNameAsync(User.Identity.Name);

            if (userModel == null) return Unauthorized();

            VoteResult result = await _voteService.VoteUnvote(userModel, id, type);

            return Ok(result);
        }

        [HttpGet("get")]
        public async Task<IActionResult> VoteUnvote([FromQuery] Guid id)
        {
            UserModel? userModel = await _userManager.FindByNameAsync(User.Identity!.Name!);

            if (userModel == null) return Unauthorized();

            UserVoteInfo? result = _voteService.GetUserVote(userModel, id);

            if (result == null) return Ok("non");

            return Ok(result);
        }
    }
}
