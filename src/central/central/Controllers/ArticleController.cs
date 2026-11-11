using central.Models;
using central.Models.ArticleEditing;
using central.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using TANO.Models;

namespace central.Controllers
{
    [Route("articles")]
    [ApiController]
    public class ArticleController : ControllerBase
    {
        private readonly ArticleService _articleService;
        private readonly UserManager<UserModel> _userManager;
        private readonly SignInManager<UserModel> _signInManager;
        private readonly IConfiguration _configuration;
        private readonly ArticleCompletionService _articleCompletionService;

        public ArticleController(ArticleService articleService, UserManager<UserModel> userManager, SignInManager<UserModel> signInManager, IConfiguration configuration, ArticleCompletionService articleCompletionService)
        {
            _articleService = articleService;
            _userManager = userManager;
            _signInManager = signInManager;
            _configuration = configuration;
            _articleCompletionService = articleCompletionService;
        }

        [HttpPost("createOrEdit")]
        [Authorize]
        public async Task<IActionResult> CreateOrEditArticle([FromBody] ArticleEditingRequest req)
        {
            if (User.Identity == null) return Unauthorized();
            if (!User.Identity.IsAuthenticated) return Unauthorized();
            if (string.IsNullOrEmpty(User.Identity.Name)) return Unauthorized();

            UserModel? userModel = await _userManager.FindByIdAsync(User.Identity.Name);

            if (userModel == null) return Unauthorized();

            ArticleEditingResult result = await _articleService.CreateOrEditArticle(userModel, req);

            return Ok(result);
        }

        [HttpDelete("remove")]
        [Authorize]
        public async Task<IActionResult> RemoveArticle([FromQuery] Guid id)
        {
            if (User.Identity == null) return Unauthorized();
            if (!User.Identity.IsAuthenticated) return Unauthorized();
            if (string.IsNullOrEmpty(User.Identity.Name)) return Unauthorized();

            UserModel? userModel = await _userManager.FindByIdAsync(User.Identity.Name);

            if (userModel == null) return Unauthorized();

            ArticleEditingResult result = await _articleService.RemoveById(userModel, id);

            return Ok(result);
        }

        [HttpGet("get")]
        public IActionResult GetArticle([FromQuery]Guid id)
        {
            ArticleModel? articleModel = _articleService.GetById(id);

            if (articleModel == null)
            {
                return NotFound();
            }

            return Ok(articleModel);
        }
    }
}
