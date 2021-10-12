## s3writer


Yet another s3 bucket filling app. (ups006)

## Run it

    python3 -m venv venv
    . venv/bin/activate
    pip install -r requirements.txt
    export AWS_ACCESS_KEY_ID=...
    export AWS_SECRET_ACCESS_KEY=...
    export AWS_REGION_NAME=...
    export AWS_BUCKET_NAME=...
    flask run --host=0.0.0.0 --port=8080