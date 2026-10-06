@echo off
chcp 65001 >nul
setlocal

rem ---------- 管理者として再実行 ----------
net session >nul 2>&1
if %errorlevel%==0 goto ADMIN_OK
echo 管理者として実行し直します。許可を求める画面で「はい」を選んでください。
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
exit /b
:ADMIN_OK

title Claude アプリ準備（Cowork / Code）
echo.
echo ============================================
echo   Claude アプリ準備（Windows）
echo ============================================
echo.

rem ---------- 1. Windows 情報 ----------
echo [1/3] Windows の情報（参考）
powershell -NoProfile -Command "Write-Host ('  ' + (Get-CimInstance Win32_OperatingSystem).Caption)"
echo.

rem ---------- 2. 仮想マシン プラットフォーム ----------
echo [2/3] 仮想マシン プラットフォームを確認しています（Cowork に必要）...
set "NEED_REBOOT=0"
powershell -NoProfile -Command "if ((Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).State -eq 'Enabled') { exit 0 } else { exit 1 }"
if %errorlevel%==0 goto VMP_OK
echo   無効なので有効にします...
powershell -NoProfile -Command "Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart | Out-Null"
set "NEED_REBOOT=1"
echo   有効にしました（再起動後に反映されます）。
goto VMP_DONE
:VMP_OK
echo   OK（有効になっています）
:VMP_DONE
echo.

rem ---------- 3. Git（Code タブ用） ----------
echo [3/3] Git を確認しています（Code タブに必要）...
where git >nul 2>&1
if %errorlevel%==0 goto GIT_OK
if exist "%ProgramFiles%\Git\cmd\git.exe" goto GIT_OK
echo   Git が見つからないのでインストールします。
winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements
goto GIT_DONE
:GIT_OK
echo   OK（Git はインストール済みです）
:GIT_DONE
echo.

echo ============================================
if "%NEED_REBOOT%"=="1" (
echo   完了しました。PC を再起動してから
echo   Claude アプリを開いてください。
) else (
echo   完了しました。Claude アプリを開いている場合は
echo   一度終了して開き直してください。
)
echo ============================================
echo.
pause
endlocal
