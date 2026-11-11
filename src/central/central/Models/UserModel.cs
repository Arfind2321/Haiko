using central.Models;
using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;

namespace TANO.Models
{
    public class UserModel : IdentityUser<Guid>
    {
        [Required]
        [StringLength(50, MinimumLength = 3, ErrorMessage = "Username must be between 3 and 50 characters")]
        public override string UserName { get; set; }
        public string DisplayName { get; set; } = "Крутой пользователь";

        public RoleModel Role { get; set; } = RoleModel.Beginner;
        public List<ArticleModel> Articles { get; set; } = [];

        public List<ArticlePartCompletionStatus> ArticlePartCompletionStatuses { get; set; } = [];
    }
}
