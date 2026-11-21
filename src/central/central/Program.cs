using central.Models;
using central.Services;
using Haiko.Protobuf;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using System.Text;

namespace central;

public static class Program
{
    public static void Main(string[] args)
    {

        var builder = WebApplication.CreateBuilder(args);

        // Add services to the container.

        builder.Services.AddControllers();
        // Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
        builder.Services.AddOpenApi();

        builder.Services.AddDbContext<ApplicationDbContext>(o =>
        {
            o.UseSqlite("Data Source=/db/app.db");
        });

        builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
                       .AddJwtBearer(options =>
                           {
                               options.TokenValidationParameters = new TokenValidationParameters()
                               {
                                   ValidateIssuer = true,
                                   ValidateAudience = true,
                                   ValidateLifetime = true,
                                   ValidateIssuerSigningKey = true,
                                   ValidIssuer = builder.Configuration["Jwt:Issuer"],
                                   ValidAudience = builder.Configuration["Jwt:Audience"],
                                   IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]))
                               };
                           }
                       );
                       /*
                       .AddYandex(options =>
                       {
                           options.ClientId = "a735a49422424ff0801141d9c1e9305c";
                           options.ClientSecret = "1e48946439c34fa0ad15e3a653130bef";
                       })*/


        builder.Services.AddIdentity<UserModel, IdentityRole<Guid>>()
            .AddEntityFrameworkStores<ApplicationDbContext>()
            .AddUserManager<UserManager<UserModel>>()
            .AddRoleManager<RoleManager<IdentityRole<Guid>>>();

        builder.Services.AddGrpc();

        builder.Services.AddGrpcClient<SearcherDatabase.SearcherDatabaseClient>(o =>
        {
            o.Address = new("https://searcher:8080");
        });


        builder.Services.AddScoped<ArticleCompletionService>();
        builder.Services.AddScoped<ArticleService>();
        builder.Services.AddScoped<CommentService>();
        builder.Services.AddScoped<VoteService>();

        var app = builder.Build();

        // Configure the HTTP request pipeline.
        if (app.Environment.IsDevelopment())
        {
            app.MapOpenApi();
        }

        app.UseHttpsRedirection();

        app.UseAuthentication();
        app.UseAuthorization();

        app.MapGrpcService<ArticleDatabaseGrpcService>();

        app.MapControllers();

        app.Run();

    }
}