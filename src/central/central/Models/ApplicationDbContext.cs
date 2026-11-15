using central.Models.Comments;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace central.Models
{
    public class ApplicationDbContext : IdentityDbContext<UserModel, IdentityRole<Guid>, Guid>
    {
        public DbSet<ArticleModel> Articles { get; set; }
        public DbSet<ArticlePartModel> ArticleParts { get; set; }
        public DbSet<UserComment> UserComments { get; set; }

        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
             : base(options)
        {
            Database.EnsureCreated();
        }
    }
}
