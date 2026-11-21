using central.Models;
using central.Models.ArticleEditing;
using central.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using central.Models;
using System.Text.Json;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;

namespace central.Controllers
{
    [Route("articles")]
    [ApiController]
    public class ArticleController : ControllerBase
    {
        private readonly ApplicationDbContext _applicationDbContext;
        private readonly ArticleService _articleService;
        private readonly UserManager<UserModel> _userManager;
        private readonly ILogger<ArticleController> _logger;
        private readonly SignInManager<UserModel> _signInManager;
        private readonly IConfiguration _configuration;
        private readonly ArticleCompletionService _articleCompletionService;

        public ArticleController(ArticleService articleService, UserManager<UserModel> userManager, SignInManager<UserModel> signInManager, IConfiguration configuration, ArticleCompletionService articleCompletionService, ILogger<ArticleController> logger, ApplicationDbContext applicationDbContext)
        {
            _articleService = articleService;
            _userManager = userManager;
            _signInManager = signInManager;
            _configuration = configuration;
            _articleCompletionService = articleCompletionService;
            _logger = logger;
            _applicationDbContext = applicationDbContext;
        }

        [HttpPost("createOrEdit")]
        [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
        public async Task<IActionResult> CreateOrEditArticle([FromBody] ArticleEditingRequest req)
        {
            if (User.Identity == null) return Unauthorized();
            if (string.IsNullOrEmpty(User.Identity.Name)) return Unauthorized();

            UserModel? userModel = await _userManager.FindByNameAsync(User.Identity.Name);

            if (userModel == null) return Unauthorized();

            ArticleEditingResult result = await _articleService.CreateOrEditArticle(userModel, req);

            return Ok(result);
        }

        [HttpDelete("remove")]
        [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
        public async Task<IActionResult> RemoveArticle([FromQuery] Guid id)
        {
            if (User.Identity == null) return Unauthorized();
            if (string.IsNullOrEmpty(User.Identity.Name)) return Unauthorized();

            UserModel? userModel = await _userManager.FindByNameAsync(User.Identity.Name);

            if (userModel == null) return Unauthorized();

            _applicationDbContext.Articles.Load();

            ArticleModel? articleModel = _articleService.GetById(id);

            if (articleModel == null)
            {
                return NotFound();
            }

            if (!userModel.Articles.Contains(articleModel))
            {
                return Forbid();
            }

            ArticleEditingResult result = await _articleService.RemoveById(userModel, id);

            return Ok(result);
        }

        [HttpPost("fork")]
        [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
        public async Task<IActionResult> ForkArticle([FromQuery] Guid id)
        {
            if (User.Identity == null) return Unauthorized();
            if (string.IsNullOrEmpty(User.Identity.Name)) return Unauthorized();

            UserModel? userModel = await _userManager.FindByNameAsync(User.Identity.Name);

            if (userModel == null) return Unauthorized();

            ArticleEditingResult result = await _articleService.ForkArticle(userModel, id);

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

        [HttpGet("getLatest")]
        public IActionResult GetLatest([FromQuery] int max = 10, [FromQuery] int page = 1)
        {
            List<object> result = [];

            _applicationDbContext.Articles.Load();

            List<ArticleModel> articles;

            if (_applicationDbContext.Articles.Count() < max)
            {
                articles = _applicationDbContext.Articles.ToList();
            }
            else
            {
                articles = _applicationDbContext.Articles.Skip((page - 1) * max).Take(max).ToList();
            }

            foreach (var item in articles)
            {
                result.Add(new
                {
                    item.Id,
                    item.Title,
                    writerId = item.WriterID
                });
            }

            return Ok(result);
        }

        [HttpGet("getMinimal")]
        public IActionResult GetMinimalArticle([FromQuery] Guid id)
        {
            ArticleModel? articleModel = _articleService.GetById(id);

            if (articleModel == null)
            {
                return NotFound();
            }

            return Ok(new
            {
                articleModel.Id,
                articleModel.Title,
                writerId = articleModel.WriterID
            });
        }
    }
}
