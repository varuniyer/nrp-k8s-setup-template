# K8s Setup Template



## Getting started

You can fork this repo to get started. Afterwards, follow these steps:

1. Add your desired python version and dependencies to `pyproject.toml`.
2. Replace `viyer9` in `example_job.yml` with your own NetID and create the secrets as shown [here](https://kubernetes.io/docs/concepts/configuration/secret/#opaque-secrets).
3. If using a private repo, follow [these instructions](https://nrp.ai/documentation/userdocs/development/private-repos/) to setup your GitLab container registry credentials and use them in `example_job.yml`
4. Adjust `test_script.py` to suit your needs. If you want to pass in arguments, do so in `example_job.yml` on line 47.
5. Once your changes are complete, install and use [`rclone`](https://rclone.org/downloads/) to copy the directory to your Ceph S3 bucket (ask the admins for credentials if you haven\'t already). Create a remote called `nautilus` to connect to your Ceph S3 bucket. Open your terminal, `cd` into this project\'s directory, and run the following: `rclone copy . nautilus://k8s-setup-template --exclude __pycache__ --exclude .venv`
6. Finally, run the job with the following command: `kubectl create -f example_job.yml`
