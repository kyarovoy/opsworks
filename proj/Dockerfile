FROM python:3.4-alpine
COPY . /project
WORKDIR /project
RUN pip install -r requirements.txt
CMD ["python", "app/app.py"]
