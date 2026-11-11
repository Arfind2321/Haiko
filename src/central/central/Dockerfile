FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG BUILD_CONFIGURATION=Release

# Project name
ARG PROJECT_NAME=central
#

# Copy all protos to container
WORKDIR /src
COPY ["/protos", "/protos"]
# 

COPY ["$PROJECT_NAME/$PROJECT_NAME/$PROJECT_NAME.csproj", "$PROJECT_NAME/$PROJECT_NAME/"]
RUN dotnet restore "./$PROJECT_NAME/$PROJECT_NAME/$PROJECT_NAME.csproj"
COPY ["$PROJECT_NAME/$PROJECT_NAME/", "$PROJECT_NAME/$PROJECT_NAME/"]
WORKDIR "/src/$PROJECT_NAME/$PROJECT_NAME"

RUN dotnet build "./$PROJECT_NAME.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish

# Project name
ARG PROJECT_NAME=central
#

ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./$PROJECT_NAME.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final

WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "central.dll"]