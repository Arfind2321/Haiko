using central.Models;
using central.Services;
using Haiko.Protobuf;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using TANO.Models;

namespace central;

public static class Program
{
    public static TokenValidationParameters tvp;

    public static void Main(string[] args)
    {

        var builder = WebApplication.CreateBuilder(args);

        // Add services to the container.

        builder.Services.AddControllers();
        // Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
        builder.Services.AddOpenApi();

        builder.Services.AddDbContext<ApplicationDbContext>(o =>
        {
            o.UseSqlite("Data Source=app.db");
        });

        tvp = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]))
        };


        builder.Services.AddAuthentication(config =>
        {
            config.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
            //config.DefaultChallengeScheme = OpenIdConnectDefaults.AuthenticationScheme;
        })
                       .AddJwtBearer(JwtBearerDefaults.AuthenticationScheme,
                           options =>
                           {
                               options.TokenValidationParameters = tvp;
                           }
                       );


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

        var app = builder.Build();

        // Configure the HTTP request pipeline.
        if (app.Environment.IsDevelopment())
        {
            app.MapOpenApi();
        }

        app.UseHttpsRedirection();

        app.UseAuthorization();

        app.MapControllers();

        app.Run();

    }
}