# K8s Setup Template



## Getting started

You can fork this repo to get started. Afterwards, follow these steps:

1. Add your desired python version and dependencies to `pyproject.toml`.
2. Replace `viyer9` in `example_job.yml` with your own NetID and create the secrets as shown [here](https://kubernetes.io/docs/concepts/configuration/secret/#opaque-secrets). Also, replace `varuniyer` with your gitlab username when referring to the image `gitlab-registry.nrp-nautilus.io/varuniyer/k8s-setup-template:latest`.
3. If using a private repo, follow [these instructions](https://nrp.ai/documentation/userdocs/development/private-repos/) to setup your GitLab container registry credentials and use them in `example_job.yml`
4. Adjust `test_script.py` to suit your needs. If you want to pass in arguments, do so in `example_job.yml` on line 47.
5. If you would like to develop and test code locally, install and use [`uv`](https://docs.astral.sh/uv/getting-started/installation/). Open your terminal, `cd` into this project\'s directory, and run `uv sync`. This will create a virtualenv in `.venv` containing all project dependencies.
    - You may update dependencies later on using the same command. After updating dependencies, commit and push the changes to `pyproject.toml` to build a new image. You can track the new build's progress in the sidebar "Build" -> "Jobs".
6. Once your changes are complete, install and use [`rclone`](https://rclone.org/downloads/) to copy the directory to your Ceph S3 bucket (ask the admins for credentials if you haven\'t already). Create a remote called `nautilus` to connect to your Ceph S3 bucket (named `bucket-name`) and run the following: `rclone copy . nautilus:bucket-name/k8s-setup-template --exclude __pycache__ --exclude .venv`
7. Finally, run the job with the following command: `kubectl create -f example_job.yml`