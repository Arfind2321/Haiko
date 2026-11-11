using Microsoft.EntityFrameworkCore;

namespace central.Models
{
    public class ApplicationDbContext : DbContext
    {
        public DbSet<ArticleModel> Articles { get; set; }
        public DbSet<ArticlePartModel> ArticleParts { get; set; }

        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
             : base(options)
        {

        }
    }
}
