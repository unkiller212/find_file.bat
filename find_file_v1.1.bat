@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title 文件查找工具 - by Zz

rem 日志文件路径：BAT 所在目录下的 查找记录.txt
set "LOG_FILE=%~dp0查找记录.txt"

:main_loop
cls
echo ============================================
echo   文件查找工具（支持文件名 / 后缀） author ：Zz
echo ============================================
echo.
echo 用法说明：
echo   1) 输入完整文件名： touch.c  lcd.c  main.c
echo   2) 输入后缀：       .c  .h  .txt
echo   3) 混合输入：       touch.c  .h  .txt
echo   4) 支持通配符：     touch*  *.c
echo   多个用 空格 / 逗号 / 分号 隔开
echo.
echo   输入 q 或 Q 退出程序
echo   查找结果将追加到：%LOG_FILE%
echo.
set /p "input=请输入要查找的内容： "

if /i "%input%"=="q" goto :eof
if "%input%"=="" (
    echo 未输入任何内容，请重新输入...
    timeout /t 1 >nul
    goto main_loop
)

rem 统一分隔符：逗号、分号 -> 空格
set "input=%input:,= %"
set "input=%input:;= %"

echo.
echo 当前目录：%cd%
echo ============================================

rem 写入日志头部，方便区分每次查找
>>"%LOG_FILE%" echo ============================================
>>"%LOG_FILE%" echo 查找时间：%date% %time%
>>"%LOG_FILE%" echo 当前目录：%cd%
>>"%LOG_FILE%" echo 查找内容：%input%
>>"%LOG_FILE%" echo ============================================

for %%f in (%input%) do (
    call :search "%%f"
)

echo.
echo ============================================
echo 查找完成。结果已保存到：%LOG_FILE%
echo.
echo 按任意键继续查找，或输入 q 退出...
pause >nul
goto main_loop

:search
set "pattern=%~1"
set "found=0"

rem 判断是不是“纯后缀”，例如 .c / .h
set "firstChar=%pattern:~0,1%"
if "%firstChar%"=="." (
    set "pattern=*%pattern%"
)

echo.
echo ---------- 查找：%~1  （匹配：!pattern!） ----------
>>"%LOG_FILE%" echo.
>>"%LOG_FILE%" echo ---------- 查找：%~1  （匹配：!pattern!） ----------

for /f "delims=" %%p in ('dir /s /b "!pattern!" 2^>nul') do (
    echo [找到] %%p
    >>"%LOG_FILE%" echo [找到] %%p
    set "found=1"
)

if "!found!"=="0" (
    echo [未找到] %~1
    >>"%LOG_FILE%" echo [未找到] %~1
)
exit /b