# practice_cicd

# Docker
- 프로그램을 환경 문제 없이 어디서나 동일하게 실행할 수 있게 만들어주는 컨테이너 기술
- 개발자가 만든 프로그램을 박스(container)에 담아서 어디서 실행하든 환경 차이 없이 똑같이 돌아가게 함

## 왜 필요한가?
- 보통 발생하는 프로그램 실행 문제
    - Python 버전이 다름
    - 라이브러리 설치 안 돼있음
    - OS가 다름(Windows / Linux / macOS)
- 이런 문제를 해결하기 위해 Docker 같은 컨테이너 기술이 등장

## 컨테이너(container)란?
- 컨테이너는 프로그램 + 필요한 라이브러리 + 실행 환경을 하나로 묶어둔 독립된 작은 컴퓨터 환경
- 예
    - Python 버전 고정
    - 필요한 pip 패키지 포함
    - 특정 OS 환경 포함
- 그래서 어디에서 실행하든 결과가 같음

## 이미지(image)란?
- 이미지는 그 컨테이너의 설계도(템플릿)

## Dockerfile이란?
- 이미지를 어떻게 만들지 적어놓는 파일
- 예
    ```
    FROM python:3.10
    COPY . /app
    RUN pip install -r requirements.txt
    CMD ["python", "crawler.py"]
    ```

## Docker 흐름 요약
- Dockerfile 작성 → 패키징
- Image 빌드(build) → 이미지 생성
- Container 실행(run) → 실제 프로그램 실행
- Registry(GHCR, Docker Hub 등)에 push → 배포