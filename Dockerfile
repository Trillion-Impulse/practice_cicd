# 1. 사용할 Python 버전 설정 (도커 이미지)
FROM python:3.10-slim

# 2. 앱 폴더 생성
WORKDIR /app

# 3. 현재 폴더의 파일들을 컨테이너 내부 /app 에 복사
COPY . /app

# 4. 필요한 패키지 설치
RUN pip install --no-cache-dir -r requirements.txt

# 5. 컨테이너 실행 시 이 명령 실행
CMD ["python", "docker-test.py"]