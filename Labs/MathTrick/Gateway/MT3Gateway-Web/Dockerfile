#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
# Install Curl
RUN apt-get update && apt-get install -y curl

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["MT3Gateway-Web.csproj", "."]
RUN dotnet restore "./MT3Gateway-Web.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "MT3Gateway-Web.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "MT3Gateway-Web.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "MT3Gateway-Web.dll"]