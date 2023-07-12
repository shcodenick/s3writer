import boto3
import os
import random
import requests
import string
from urllib import parse

from flask import Flask, request
from flask import render_template


app = Flask(__name__)


def get_presigned_url(file_name):
    s3_client = boto3.client(
        "s3",
        aws_access_key_id=os.environ.get("AWS_ACCESS_KEY_ID"),
        aws_secret_access_key=os.environ.get("AWS_SECRET_ACCESS_KEY"),
        region_name=os.environ.get("AWS_REGION_NAME"),
        config=boto3.session.Config(signature_version='s3v4')
    )
    response = s3_client.generate_presigned_url('put_object', Params={
        "Bucket": os.environ.get("AWS_BUCKET_NAME"),
        'Key': file_name,
        'ContentType': 'application/x-www-form-urlencoded; charset=UTF-8'
    }, ExpiresIn=3600)
    print(response)
    return response


def count_records():
    """Fetches records count from CRUD app"""
    response = requests.get(os.environ.get("COUNT_ENDPOINT"))
    if response.status_code == 200:
        return response.text
    else:
        return -1


@app.route("/")
def yo():
    return render_template('app.html')


@app.route("/s3")
def main():
    return render_template('app.html')



@app.route("/s3/get-count")
def get_count():
    return {"count": count_records()}


@app.route("/s3/build-form-action-url", methods=['POST'])
def build_form_action_url():
    data = request.get_json()
    filename = data.get("name")
    random_ = ''.join(random.choices(string.ascii_uppercase + string.digits, k=5))
    parts = filename.split('.')
    file_name = f"{parts[0]}_{random_}.{parts[1]}"
    url = get_presigned_url(file_name)
    data = dict(parse.parse_qsl(parse.urlsplit(url).query))
    data["key"] = file_name
    return {'url': url, 'data': data}
