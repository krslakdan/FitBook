FROM mcr.microsoft.com/dotnet/aspnet:9.0-bookworm-slim AS base
WORKDIR /app
EXPOSE 5121

FROM mcr.microsoft.com/dotnet/sdk:9.0-bookworm-slim AS publish
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["FitBook.WebAPI/FitBook.WebAPI.csproj", "FitBook.WebAPI/"]
COPY ["FitBook.Services/FitBook.Services.csproj", "FitBook.Services/"]
COPY ["FitBook.Common.Services/FitBook.Common.Services.csproj", "FitBook.Common.Services/"]
COPY ["FitBook.Model/FitBook.Model.csproj", "FitBook.Model/"]
RUN dotnet restore "FitBook.WebAPI/FitBook.WebAPI.csproj" -r linux-x64
COPY . .
RUN dotnet publish "FitBook.WebAPI/FitBook.WebAPI.csproj" -c $BUILD_CONFIGURATION -r linux-x64 --self-contained false -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
RUN mkdir -p /app/wwwroot/uploads && chown -R app:app /app/wwwroot
USER app
ENTRYPOINT ["dotnet", "FitBook.WebAPI.dll"]
