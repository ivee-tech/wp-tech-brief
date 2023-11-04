#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
# Install Curl
RUN apt-get update && apt-get install -y curl

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["./Gateway/MT3Gateway-Step2/MT3Gateway-Step2.csproj", "./Gateway/MT3Gateway-Step2/"]
COPY ["./MathTrickCore/MathTrickCore.csproj", "./MathTrickCore/"]
RUN dotnet restore "./Gateway/MT3Gateway-Step2/MT3Gateway-Step2.csproj"
COPY . .

FROM build AS publish
WORKDIR "/src/."
RUN dotnet publish "./Gateway/MT3Gateway-Step2/MT3Gateway-Step2.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "MT3Gateway-Step2.dll"]