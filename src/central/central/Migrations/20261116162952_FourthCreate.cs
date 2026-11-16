using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace central.Migrations
{
    /// <inheritdoc />
    public partial class FourthCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ArticlePartCompletionStatus_AspNetUsers_UserModelId",
                table: "ArticlePartCompletionStatus");

            migrationBuilder.DropForeignKey(
                name: "FK_UserCommentVoteInfo_AspNetUsers_UserModelId",
                table: "UserCommentVoteInfo");

            migrationBuilder.DropForeignKey(
                name: "FK_UserVoteInfo_AspNetUsers_UserModelId",
                table: "UserVoteInfo");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UserVoteInfo",
                table: "UserVoteInfo");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UserCommentVoteInfo",
                table: "UserCommentVoteInfo");

            migrationBuilder.DropPrimaryKey(
                name: "PK_ArticlePartCompletionStatus",
                table: "ArticlePartCompletionStatus");

            migrationBuilder.RenameTable(
                name: "UserVoteInfo",
                newName: "UserVotes");

            migrationBuilder.RenameTable(
                name: "UserCommentVoteInfo",
                newName: "UserCommentVotes");

            migrationBuilder.RenameTable(
                name: "ArticlePartCompletionStatus",
                newName: "ArticlePartCompletionStatuses");

            migrationBuilder.RenameIndex(
                name: "IX_UserVoteInfo_UserModelId",
                table: "UserVotes",
                newName: "IX_UserVotes_UserModelId");

            migrationBuilder.RenameIndex(
                name: "IX_UserCommentVoteInfo_UserModelId",
                table: "UserCommentVotes",
                newName: "IX_UserCommentVotes_UserModelId");

            migrationBuilder.RenameIndex(
                name: "IX_ArticlePartCompletionStatus_UserModelId",
                table: "ArticlePartCompletionStatuses",
                newName: "IX_ArticlePartCompletionStatuses_UserModelId");

            migrationBuilder.AddColumn<string>(
                name: "Title",
                table: "ArticleParts",
                type: "TEXT",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddPrimaryKey(
                name: "PK_UserVotes",
                table: "UserVotes",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_UserCommentVotes",
                table: "UserCommentVotes",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_ArticlePartCompletionStatuses",
                table: "ArticlePartCompletionStatuses",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_ArticlePartCompletionStatuses_AspNetUsers_UserModelId",
                table: "ArticlePartCompletionStatuses",
                column: "UserModelId",
                principalTable: "AspNetUsers",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_UserCommentVotes_AspNetUsers_UserModelId",
                table: "UserCommentVotes",
                column: "UserModelId",
                principalTable: "AspNetUsers",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_UserVotes_AspNetUsers_UserModelId",
                table: "UserVotes",
                column: "UserModelId",
                principalTable: "AspNetUsers",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ArticlePartCompletionStatuses_AspNetUsers_UserModelId",
                table: "ArticlePartCompletionStatuses");

            migrationBuilder.DropForeignKey(
                name: "FK_UserCommentVotes_AspNetUsers_UserModelId",
                table: "UserCommentVotes");

            migrationBuilder.DropForeignKey(
                name: "FK_UserVotes_AspNetUsers_UserModelId",
                table: "UserVotes");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UserVotes",
                table: "UserVotes");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UserCommentVotes",
                table: "UserCommentVotes");

            migrationBuilder.DropPrimaryKey(
                name: "PK_ArticlePartCompletionStatuses",
                table: "ArticlePartCompletionStatuses");

            migrationBuilder.DropColumn(
                name: "Title",
                table: "ArticleParts");

            migrationBuilder.RenameTable(
                name: "UserVotes",
                newName: "UserVoteInfo");

            migrationBuilder.RenameTable(
                name: "UserCommentVotes",
                newName: "UserCommentVoteInfo");

            migrationBuilder.RenameTable(
                name: "ArticlePartCompletionStatuses",
                newName: "ArticlePartCompletionStatus");

            migrationBuilder.RenameIndex(
                name: "IX_UserVotes_UserModelId",
                table: "UserVoteInfo",
                newName: "IX_UserVoteInfo_UserModelId");

            migrationBuilder.RenameIndex(
                name: "IX_UserCommentVotes_UserModelId",
                table: "UserCommentVoteInfo",
                newName: "IX_UserCommentVoteInfo_UserModelId");

            migrationBuilder.RenameIndex(
                name: "IX_ArticlePartCompletionStatuses_UserModelId",
                table: "ArticlePartCompletionStatus",
                newName: "IX_ArticlePartCompletionStatus_UserModelId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_UserVoteInfo",
                table: "UserVoteInfo",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_UserCommentVoteInfo",
                table: "UserCommentVoteInfo",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_ArticlePartCompletionStatus",
                table: "ArticlePartCompletionStatus",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_ArticlePartCompletionStatus_AspNetUsers_UserModelId",
                table: "ArticlePartCompletionStatus",
                column: "UserModelId",
                principalTable: "AspNetUsers",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_UserCommentVoteInfo_AspNetUsers_UserModelId",
                table: "UserCommentVoteInfo",
                column: "UserModelId",
                principalTable: "AspNetUsers",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_UserVoteInfo_AspNetUsers_UserModelId",
                table: "UserVoteInfo",
                column: "UserModelId",
                principalTable: "AspNetUsers",
                principalColumn: "Id");
        }
    }
}
