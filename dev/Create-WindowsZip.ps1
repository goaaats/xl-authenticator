try {
    Push-Location
    Set-Location $PSScriptRoot\..
    flutter build windows --release

    Set-Location build\windows\runner\Release
    # source: https://docs.flutter.dev/desktop#building-your-own-zip-file-for-windows
    Copy-Item -Destination .\ -Path "C:\Windows\System32\msvcp140.dll", "C:\Windows\System32\vcruntime140.dll", "C:\Windows\System32\vcruntime140_1.dll"

    Compress-Archive -DestinationPath ..\..\..\windows.zip -Path "*.exe", "*.dll", "data"
}
finally {
    Pop-Location
}
