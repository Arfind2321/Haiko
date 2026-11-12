using central.Models;
using central.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using central.Models;

namespace central.Controllers
{
    [Route("completion")]
    [ApiController]
    public class ArticleCompletionController : ControllerBase
    {
        private readonly UserManager<UserModel> _userManager;
        private readonly SignInManager<UserModel> _signInManager;
        private readonly IConfiguration _configuration;
        private readonly ArticleCompletionService _articleCompletionService;

        public ArticleCompletionController(UserManager<UserModel> userManager, SignInManager<UserModel> signInManager, IConfiguration configuration, ArticleCompletionService articleCompletionService)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _configuration = configuration;
            _articleCompletionService = articleCompletionService;
        }

        [HttpGet("get")]
        [Authorize]
        public async Task<IActionResult> GetArticleComplectionStatus([FromQuery] Guid id)
        {
            if (User.Identity == null) return Unauthorized();
            if (!User.Identity.IsAuthenticated) return Unauthorized();
            if (string.IsNullOrEmpty(User.Identity.Name)) return Unauthorized();

            UserModel? userModel = await _userManager.FindByIdAsync(User.Identity.Name);

            if (userModel == null) return Unauthorized();

            List<Guid> ids = _articleCompletionService.GetCompletionByArticleId(userModel, id);

            return Ok(ids);
        }

        [HttpGet("set")]
        [Authorize]
        public async Task<IActionResult> SetArticleComplectionStatus([FromQuery] Guid id, [FromQuery] Guid pid, [FromQuery] bool ic)
        {
            if (User.Identity == null) return Unauthorized();
            if (!User.Identity.IsAuthenticated) return Unauthorized();
            if (string.IsNullOrEmpty(User.Identity.Name)) return Unauthorized();

            UserModel? userModel = await _userManager.FindByIdAsync(User.Identity.Name);

            if (userModel == null) return Unauthorized();

            bool ok = await _articleCompletionService.ChangeCompletionStatusArticlePart(userModel, id, pid, ic);

            return Ok(ok);
        }
    }
}
