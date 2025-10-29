# build_all_simple.ps1

Write-Host "Starting Flavor Build Automation..." -ForegroundColor Green

# Переходим в корень проекта Flutter
Set-Location ..

# Получаем версию из pubspec.yaml
$pubspecContent = Get-Content -Path "pubspec.yaml" -Raw
$versionLine = ($pubspecContent -split "`n") | Where-Object { $_ -match "version:" }
$versionFull = $versionLine.Split(":")[1].Trim()
$versionParts = $versionFull -split "\+"
$version = $versionParts[0]
$buildNumber = $versionParts[1]

Write-Host "Version: $version (build: $buildNumber)" -ForegroundColor Yellow

# Создаем папку для релизов
$releasesDir = "build/releases"
if (Test-Path $releasesDir) {
    Remove-Item -Path $releasesDir -Recurse -Force
}
New-Item -ItemType Directory -Path $releasesDir -Force | Out-Null

# Массив с flavor'ами
$flavors = @("asiec", "altag")

foreach ($flavor in $flavors) {
    Write-Host "Building $flavor..." -ForegroundColor Magenta
    
    # Сборка APK
    flutter build apk --flavor $flavor --release -t "lib/main_$flavor.dart"
    
    if ($LASTEXITCODE -eq 0) {
        $sourceApk = "build/app/outputs/flutter-apk/app-$flavor-release.apk"
        $destApk = "build/releases/${flavor}_schedule_v${version}.apk"
        
        if (Test-Path $sourceApk) {
            Copy-Item -Path $sourceApk -Destination $destApk
            $fileSize = [math]::Round((Get-Item $destApk).Length / 1MB, 2)
            Write-Host "SUCCESS: ${flavor}_schedule_v${version}.apk ($fileSize MB)" -ForegroundColor Green
        } else {
            Write-Host "APK file not found: $sourceApk" -ForegroundColor Red
        }
    } else {
        Write-Host "BUILD FAILED for $flavor" -ForegroundColor Red
    }
}

Write-Host "Build completed! Files in build/releases/" -ForegroundColor Cyan