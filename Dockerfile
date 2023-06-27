FROM python:3.9-buster
COPY requirements.txt /
RUN pip3 install -r /requirements.txt

COPY . /app
RUN chown -R www-data:www-data /app
WORKDIR /app
RUN chmod +x gunicorn.sh
EXPOSE 5000
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0
ENTRYPOINT ["./gunicorn.sh"]
#CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]