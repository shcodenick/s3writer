FROM python:3.9-buster
COPY requirements.txt /
RUN pip3 install -r /requirements.txt

COPY . /app
RUN chown -R www-data:www-data /app
WORKDIR /app
ENTRYPOINT ["./gunicorn.sh"]