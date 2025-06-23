@echo off
setlocal enabledelayedexpansion
chcp 65001
 
REM Устанавливаем путь к файлу для сохранения последнего значения
set "folderFile=folder-path.txt"

REM Проверяем, существует ли файл с сохранённым значением
if exist "%folderFile%" (
    REM Читаем последнее значение из файла
    set /p lastFolder= < %folderFile%
    echo Последняя папка: !lastFolder!
	REM Спрашиваем, использовать ли сохранённый путь
    set /p answer="Хотите использовать этот путь? (y/n): "
    if /i "!answer!"=="y" (
		set folder=!lastFolder!
        echo Используем путь: !folder!
    ) else (
        REM Запрос нового пути
        set /p folder="Введите новый путь к папке (например, D:/directory/путь с пробелами и кириллицей): "
        REM Сохраняем новый путь в файл
        echo !folder! > folder-path.txt
        echo Новый путь сохранён: !folder!
    )
) else (
	REM Запросить у пользователя путь к папке
	set /p folder="Введите путь к папке (например, D:/directory/путь с пробелами и кириллицей): "
    echo !folder! > folder-path.txt
    echo Путь сохранён: !folder!
)


REM Проверка, установлен ли Python
python --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Python не найден! Устанавливаем Python...
    REM Загружаем и устанавливаем Python
    curl -o python-installer.exe https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe
    start /wait python-installer.exe /quiet InstallAllUsers=1 PrependPath=1
    echo Python установлен!
) ELSE (
    echo Python уже установлен!
)

REM Проверить, что переход в директорию успешен
IF NOT EXIST "!folder!" (
    echo Указанный путь не валидный.
    exit /b
)


REM Переход в указанную пользователем директорию
cd /d %folder%
REM Запуск сервера
echo Запуск локального веб-сервера по адресу...

python -m http.server 80

pause