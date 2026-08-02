FROM mcr.microsoft.com/dotnet/runtime:9.0-bookworm-slim AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:9.0-bookworm-slim AS publish
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["FitBook.Worker/FitBook.Worker.csproj", "FitBook.Worker/"]
COPY ["FitBook.Services/FitBook.Services.csproj", "FitBook.Services/"]
COPY ["FitBook.Common.Services/FitBook.Common.Services.csproj", "FitBook.Common.Services/"]
COPY ["FitBook.Model/FitBook.Model.csproj", "FitBook.Model/"]
RUN dotnet restore "FitBook.Worker/FitBook.Worker.csproj" -r linux-x64
COPY . .
RUN dotnet publish "FitBook.Worker/FitBook.Worker.csproj" -c $BUILD_CONFIGURATION -r linux-x64 --self-contained false -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
USER app
ENTRYPOINT ["dotnet", "FitBook.Worker.dll"]
