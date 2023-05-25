## s3writer


Yet another s3 bucket filling app.

## Run it

    python3 -m venv venv
    . venv/bin/activate
    pip install -r requirements.txt
    export AWS_ACCESS_KEY_ID=...
    export AWS_SECRET_ACCESS_KEY=...
    export AWS_REGION_NAME=...
    export AWS_BUCKET_NAME=...
    export COUNT_ENDPOINT=...
    flask run --host=0.0.0.0 --port=5000


## Run it with docker

Create env.list file with vars mentioned above. This one COUNT_ENDPOINT should be http://host.docker.internal:8000/crud/count/ 

Run the crud app too!

    docker build -t s3writer .
    docker run --env-file=env.list --add-host=host.docker.internal:host-gateway -p 5000:5000 s3writer .

    docker tag s3writer:latest public.ecr.aws/[registry]/s3writer:latest
    docker push public.ecr.aws/[registry]/s3writer:latest

