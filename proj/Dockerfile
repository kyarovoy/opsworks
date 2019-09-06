FROM python:3.6-alpine
ENV MANAGER_IP $MANAGER_IP
COPY . /project
WORKDIR /project
RUN pip install -r requirements.txt
CMD ["python", "app/app.py"]
