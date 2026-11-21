using AspNet.Security.OAuth.Yandex;
using central.Models;
using central.Models.Auth;
using central.Models.Auth;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace central.Controllers
{
    [Route("auth")]
    [ApiController]
    public class AccountController : ControllerBase
    {
        private readonly ApplicationDbContext _applicationDbContext;
        private readonly UserManager<UserModel> _userManager;
        private readonly SignInManager<UserModel> _signInManager;
        private readonly IConfiguration _configuration;

        public AccountController(UserManager<UserModel> userManager, SignInManager<UserModel> signInManager, IConfiguration configuration, ApplicationDbContext applicationDbContext)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _configuration = configuration;
            _applicationDbContext = applicationDbContext;
        }

        private async Task<string> GenerateJwtToken(UserModel user)
        {
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Name, user.UserName)
            };

            var roles = await _userManager.GetRolesAsync(user);
            foreach (var role in roles)
            {
                claims.Add(new Claim(ClaimTypes.Role, role));
            }

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256Signature);

            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"],
                audience: _configuration["Jwt:Audience"],
                claims: claims,
                expires: DateTime.UtcNow.AddDays(1),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }


        [HttpPost("register")]
        public async Task<IActionResult> RegisterView([FromBody] RegisterViewModel model)
        {
            if (ModelState.IsValid)
            {
                var result = await Register(model.Username, model.Password);

                if (result.Item1.Succeeded)
                {
                    if (result.Item2 == null) return BadRequest("Неправильный логин или пароль");

                    //await _signInManager.SignInAsync(result.Item2, true);

                    return Ok(await GenerateJwtToken(result.Item2));
                }
            }

            return BadRequest(ModelState);
        }

        public async Task<(IdentityResult, UserModel)> Register(string username, string? password = null)
        {
            var user = new UserModel { UserName = username };
            if (string.IsNullOrEmpty(password))
            {
                return (await _userManager.CreateAsync(user), user);
            }
            else
            {
                return (await _userManager.CreateAsync(user, password), user);
            }
        }

        // Да, тут есть авторизация через Яндекс, но она почему то она полностью не работает и мне лень с этим возиться в связи "ограниченного бюджета" и наличием более важных вещей, которым нужно уделить время. Если вы видите это строчку, то я так и не поймал мотивацию чинить это и делать поддержку на стороне клиента.
        [HttpGet("auth-yandex")]
        [Authorize(AuthenticationSchemes = YandexAuthenticationDefaults.AuthenticationScheme)]
        public async Task<IActionResult> AuthYandex()
        {
            if (!User.Identity.IsAuthenticated)
            {
                return Unauthorized();
            }

            var userId = User.FindFirst(ClaimTypes.Name)?.Value;
            if (string.IsNullOrEmpty(userId))
            {
                return BadRequest();
            }

            var user = await _userManager.FindByNameAsync(userId);

            if (user == null)
            {
                var result = await Register(userId);
                return Ok(await GenerateJwtToken(result.Item2));
            }
            else
            {
                return Ok(await GenerateJwtToken(user));
            }

        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginViewModel model)
        {
            if (ModelState.IsValid)
            {
                var user = await _userManager.FindByNameAsync(model.Username);

                if (user == null) return BadRequest("Неправильный логин или пароль");

                var result = await _userManager.CheckPasswordAsync(user, model.Password);

                if (result)
                {
                    return Ok(await GenerateJwtToken(user));
                }

                return BadRequest("Неправильный логин или пароль");
            }

            return BadRequest("Некорректный запрос");
        }

        [HttpGet("logout")]
        [Authorize]
        public async Task<IActionResult> Logout()
        {
            await _signInManager.SignOutAsync();
            return Redirect("/");
        }

        [HttpPost("uploadAvatar")]
        [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
        public async Task<IActionResult> UploadAvatar(IFormFile uploadedFile)
        {
            if (uploadedFile != null)
            {
                if (User.Identity == null) return Unauthorized();
                if (string.IsNullOrEmpty(User.Identity.Name)) return Unauthorized();

                var user = await _userManager.FindByNameAsync(User.Identity.Name);

                if (user == null)
                {
                    return Unauthorized();
                }

                if (uploadedFile.Length > 10485760)
                {
                    return BadRequest("Файл весит больше 10МБ");
                }

                using (var fileStream = new FileStream($"/static/static/{user.Id}.png", FileMode.Create))
                {
                    await uploadedFile.CopyToAsync(fileStream);
                }

                return Ok();
            }

            return RedirectToAction("Index");
        }

        [HttpGet("me")]
        [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
        public async Task<IActionResult> UserInfo()
        {
            if (User.Identity == null) return Unauthorized();
            if (string.IsNullOrEmpty(User.Identity.Name)) return Unauthorized();

            var user = await _userManager.FindByNameAsync(User.Identity.Name);

            if (user == null)
            {
                return Unauthorized();
            }

            return Ok(new
            {
                Id = user.Id,
                UserName = user.UserName
            });
        }

        [HttpGet("getArticles")]
        [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
        public async Task<IActionResult> GetArticles()
        {
            if (User.Identity == null) return Unauthorized();
            if (string.IsNullOrEmpty(User.Identity.Name)) return Unauthorized();

            var user = await _userManager.FindByNameAsync(User.Identity.Name);

            if (user == null)
            {
                return Unauthorized();
            }

            _applicationDbContext.Articles.Load();

            List<MinimalArticleModel> minimalArticleModels = [];

            foreach (var item in user.Articles)
            {
                minimalArticleModels.Add(new() { id = item.Id, Title = item.Title, WriterId = item.WriterID });
            }

            return Ok(new
            {
                Articles = minimalArticleModels
            });
        }
    }
}
