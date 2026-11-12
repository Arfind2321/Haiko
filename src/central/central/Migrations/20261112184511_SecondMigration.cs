using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace central.Migrations
{
    /// <inheritdoc />
    public partial class SecondMigration : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "LastEditTime",
                table: "Articles",
                type: "TEXT",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<long>(
                name: "DownVotes",
                table: "ArticleParts",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.AddColumn<long>(
                name: "UpVotes",
                table: "ArticleParts",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.CreateTable(
                name: "UserComments",
                columns: table => new
                {
                    Id = table.Column<long>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    UserId = table.Column<Guid>(type: "TEXT", nullable: false),
                    Content = table.Column<string>(type: "TEXT", nullable: false),
                    DateTime = table.Column<DateTime>(type: "TEXT", nullable: false),
                    Likes = table.Column<long>(type: "INTEGER", nullable: false),
                    Dislikes = table.Column<long>(type: "INTEGER", nullable: false),
                    ArticlePartModelId = table.Column<Guid>(type: "TEXT", nullable: true),
                    UserCommentId = table.Column<long>(type: "INTEGER", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserComments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserComments_ArticleParts_ArticlePartModelId",
                        column: x => x.ArticlePartModelId,
                        principalTable: "ArticleParts",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_UserComments_UserComments_UserCommentId",
                        column: x => x.UserCommentId,
                        principalTable: "UserComments",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_UserComments_ArticlePartModelId",
                table: "UserComments",
                column: "ArticlePartModelId");

            migrationBuilder.CreateIndex(
                name: "IX_UserComments_UserCommentId",
                table: "UserComments",
                column: "UserCommentId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "UserComments");

            migrationBuilder.DropColumn(
                name: "LastEditTime",
                table: "Articles");

            migrationBuilder.DropColumn(
                name: "DownVotes",
                table: "ArticleParts");

            migrationBuilder.DropColumn(
                name: "UpVotes",
                table: "ArticleParts");
        }
    }
}
