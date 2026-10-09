@echo off
setlocal enabledelayedexpansion
title 文件查找工具 - by Zz

rem ============================================================
rem 文件查找工具
rem 功能：支持按文件名 / 后缀查找，支持多个关键词，支持通配符
rem 作者：Zz
rem 说明：查找结果会自动保存到电脑上，路径为 BAT 文件所在目录下的
rem       “查找记录.txt”。每次查找的结果都会追加到该文件中。
rem       查找结束后，可输入编号跳转到对应文件所在文件夹。
rem ============================================================

rem 设置日志文件路径：%~dp0 表示 BAT 文件所在目录
set "LOG_FILE=%~dp0查找记录.txt"
rem 临时文件，存放本次找到的文件列表，用于跳转
set "FOUND_LIST=%TEMP%\find_tool_found.txt"

:main_loop
cls
echo ============================================
echo   文件查找工具（支持文件名 / 后缀） author ：Zz
echo ============================================
echo.
echo 用法说明：
echo   1. 输入完整文件名： touch.c  lcd.c  main.c
echo   2. 输入后缀：       .c  .h  .txt
echo   3. 混合输入：       touch.c  .h  .txt
echo   4. 支持通配符：     touch*  *.c
echo   多个用 空格 / 逗号 / 分号 隔开
echo.
echo   输入 q 或 Q 退出程序
echo   查找结果将追加保存到： "%LOG_FILE%"
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

rem 清空临时文件，准备存放本次找到的文件
if exist "%FOUND_LIST%" del "%FOUND_LIST%"

rem 将本次查找的信息（时间、目录、内容）写入日志文件
>>"%LOG_FILE%" echo ============================================
>>"%LOG_FILE%" echo 查找时间：%date% %time%
>>"%LOG_FILE%" echo 当前目录：%cd%
>>"%LOG_FILE%" echo 查找内容：%input%
>>"%LOG_FILE%" echo ============================================

for %%f in (%input%) do (
    call :search "%%f"
)

rem ============================================================
rem 查找结束后，显示带编号的文件列表，并允许输入编号跳转
rem ============================================================
if exist "%FOUND_LIST%" (
    set /a idx=0
    echo.
    echo ===== 找到的文件列表 =====
    for /f "usebackq delims=" %%p in ("%FOUND_LIST%") do (
        set /a idx+=1
        echo [!idx!] %%p
        set "file[!idx!]=%%p"
    )
    echo ==========================
    if !idx! GTR 0 (
        set /p "choice=请输入要跳转的文件编号（直接回车跳过）："
        if not "!choice!"=="" (
            set "selected="
            call set "selected=%%file[!choice!]%%"
            if defined selected (
                echo 正在打开：!selected!
                explorer /select,"!selected!"
            ) else (
                echo 无效的编号。
            )
        )
    )
)

echo.
echo ============================================
echo 查找完成。结果已保存到： "%LOG_FILE%"
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

rem 将找到的文件路径同时输出到屏幕、日志文件和临时列表
for /f "delims=" %%p in ('dir /s /b "!pattern!" 2^>nul') do (
    echo [找到] %%p
    >>"%LOG_FILE%" echo [找到] %%p
    >>"%FOUND_LIST%" echo %%p
    set "found=1"
)

rem 如果没找到，也在日志中记录
if "!found!"=="0" (
    echo [未找到] %~1
    >>"%LOG_FILE%" echo [未找到] %~1
)
exit /b