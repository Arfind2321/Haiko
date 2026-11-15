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
    public class CommentController : ControllerBase
    {
        private readonly ArticleService _articleService;
        private readonly UserManager<UserModel> _userManager;
        private readonly CommentService _commentService;

        public CommentController(ArticleService articleService, UserManager<UserModel> userManager, CommentService commentService)
        {
            _articleService = articleService;
            _userManager = userManager;
            _commentService = commentService;
        }

        [HttpGet("create")]
        [Authorize]
        public async Task<IActionResult> Create([FromQuery] Guid pid, [FromQuery] string content, [FromQuery] long? cid = null)
        {
            if (User.Identity == null) return Unauthorized();
            if (!User.Identity.IsAuthenticated) return Unauthorized();
            if (string.IsNullOrEmpty(User.Identity.Name)) return Unauthorized();

            UserModel? userModel = await _userManager.FindByNameAsync(User.Identity.Name);

            if (userModel == null) return Unauthorized();

            bool result = await _commentService.PublishComment(userModel, pid, content, cid);

            return Ok(result);
        }

        [HttpGet("remove")]
        [Authorize]
        public async Task<IActionResult> Remove([FromQuery] long cid)
        {
            if (User.Identity == null) return Unauthorized();
            if (!User.Identity.IsAuthenticated) return Unauthorized();
            if (string.IsNullOrEmpty(User.Identity.Name)) return Unauthorized();

            UserModel? userModel = await _userManager.FindByNameAsync(User.Identity.Name);

            if (userModel == null) return Unauthorized();

            bool result = await _commentService.RemoveComment(userModel, cid);

            return Ok(result);
        }

        [HttpGet("voteUnvote")]
        [Authorize]
        public async Task<IActionResult> VoteUnvote([FromQuery]long id, [FromQuery]UserComentVoteType type)
        {
            if (User.Identity == null) return Unauthorized();
            if (!User.Identity.IsAuthenticated) return Unauthorized();
            if (string.IsNullOrEmpty(User.Identity.Name)) return Unauthorized();

            UserModel? userModel = await _userManager.FindByNameAsync(User.Identity.Name);

            if (userModel == null) return Unauthorized();

            VoteResult result = await _commentService.VoteUnvote(userModel, id, type);

            return Ok(result);
        }
    }
}
