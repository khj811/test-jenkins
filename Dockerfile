# 베이스 이미지를 설정합니다. 여기서는 Python 3.9을 사용합니다.
FROM python:3.9

# 작업 디렉토리를 설정합니다.
WORKDIR /app

# 현재 디렉토리의 모든 파일을 작업 디렉토리로 복사합니다.
COPY . .

# 필요한 패키지를 설치합니다. 예를 들어 requirements.txt 파일을 사용할 수 있습니다.
RUN pip install --no-cache-dir -r requirements.txt

# 컨테이너가 실행될 명령을 설정합니다. 예를 들어 서버를 실행하는 경우:
CMD ["python", "app.py"]
