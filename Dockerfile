FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /src
COPY ["personal_website.csproj", "./"]
RUN dotnet restore "./personal_website.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "personal_website.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "personal_website.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "personal_website.dll"]
