using central.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using static central.Controllers.AccountController;

namespace central.Controllers
{
    [Route("users")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly UserManager<UserModel> _userManager;
        private readonly SignInManager<UserModel> _signInManager;
        private readonly IConfiguration _configuration;

        public UsersController(UserManager<UserModel> userManager, SignInManager<UserModel> signInManager, IConfiguration configuration)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _configuration = configuration;
        }

        [HttpGet("get")]
        public async Task<IActionResult> UserInfo([FromQuery]Guid id)
        {
            var user = await _userManager.FindByIdAsync(id.ToString());

            if (user == null)
            {
                return NotFound();
            }

            return Ok(new MeResponse
            {
                Id = user.Id,
                UserName = user.UserName
            });
        }
    }
}
