@echo off
chcp 65001 >nul
setlocal

rem ---------- 導入するものを選ぶ ----------
rem   1 = Cowork と Code の両方 / 2 = Cowork だけ / 3 = Code だけ
rem   （管理者として再実行したときは、選んだ番号が引数で渡ってくる）
set "MODE=%~1"
if "%MODE%"=="1" goto MODE_OK
if "%MODE%"=="2" goto MODE_OK
if "%MODE%"=="3" goto MODE_OK
echo.
echo ============================================
echo   Claude アプリ準備（Windows）
echo ============================================
echo.
echo   どれを使えるように準備しますか？
echo.
echo     1. Cowork と Code の両方
echo     2. Cowork だけ（仮想マシン プラットフォーム）
echo     3. Code だけ（Git）
echo.
choice /c 123 /n /m "  番号を押してください [1/2/3]: "
set "MODE=%errorlevel%"
:MODE_OK

if "%MODE%"=="1" set "DO_COWORK=1" & set "DO_CODE=1" & set "MODE_NAME=Cowork と Code の両方"
if "%MODE%"=="2" set "DO_COWORK=1" & set "DO_CODE=0" & set "MODE_NAME=Cowork だけ"
if "%MODE%"=="3" set "DO_COWORK=0" & set "DO_CODE=1" & set "MODE_NAME=Code だけ"

rem ---------- Cowork の準備には管理者が必要 ----------
if "%DO_COWORK%"=="0" goto ADMIN_OK
net session >nul 2>&1
if %errorlevel%==0 goto ADMIN_OK
echo.
echo 管理者として実行し直します。許可を求める画面で「はい」を選んでください。
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -ArgumentList '%MODE%' -Verb RunAs"
exit /b
:ADMIN_OK

title Claude アプリ準備（%MODE_NAME%）
echo.
echo ============================================
echo   Claude アプリ準備：%MODE_NAME%
echo ============================================
echo.

rem ---------- Windows 情報 ----------
echo [Windows の情報（参考）]
powershell -NoProfile -Command "Write-Host ('  ' + (Get-CimInstance Win32_OperatingSystem).Caption)"
echo.

rem ---------- 仮想マシン プラットフォーム（Cowork 用） ----------
set "NEED_REBOOT=0"
if "%DO_COWORK%"=="0" goto VMP_DONE
echo [Cowork] 仮想マシン プラットフォームを確認しています...
powershell -NoProfile -Command "if ((Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).State -eq 'Enabled') { exit 0 } else { exit 1 }"
if %errorlevel%==0 goto VMP_OK
echo   無効なので有効にします...
powershell -NoProfile -Command "Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart | Out-Null"
set "NEED_REBOOT=1"
echo   有効にしました（再起動後に反映されます）。
goto VMP_END
:VMP_OK
echo   OK（有効になっています）
:VMP_END
echo.
:VMP_DONE

rem ---------- Git（Code タブ用） ----------
if "%DO_CODE%"=="0" goto GIT_DONE
echo [Code] Git を確認しています...
where git >nul 2>&1
if %errorlevel%==0 goto GIT_OK
if exist "%ProgramFiles%\Git\cmd\git.exe" goto GIT_OK
echo   Git が見つからないのでインストールします。
winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements
goto GIT_END
:GIT_OK
echo   OK（Git はインストール済みです）
:GIT_END
echo.
:GIT_DONE

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
