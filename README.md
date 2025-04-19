# K8s Setup Template



## Getting started

You can fork this repo to get started. Afterwards, follow these steps:

1. Add your desired python version and dependencies to `pyproject.toml`.
2. Replace
    - `viyer9` in `example_job.yml` with your own NetID and create the secrets as shown [here](https://kubernetes.io/docs/concepts/configuration/secret/#opaque-secrets). `GIT_PASSWORD` should be a [Personal Access Token](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html).
    - `varuniyer` with your gitlab username when referring to the image `gitlab-registry.nrp-nautilus.io/varuniyer/k8s-setup-template:latest` or `https://gitlab.nrp-nautilus.io/varuniyer/k8s-setup-template`
3. If this repo is private, follow [these instructions](https://nrp.ai/documentation/userdocs/development/private-repos/) to setup your GitLab container registry credentials and use them in `example_job.yml`
4. Adjust `test_script.py` to suit your needs. If you want to pass in arguments, do so in [`example_job.yml`](https://gitlab.nrp-nautilus.io/varuniyer/k8s-setup-template/-/blob/main/example_job.yml?ref_type=heads#L31).
5. If you would like to develop and test code locally, install and use [`uv`](https://docs.astral.sh/uv/getting-started/installation/). Open your terminal, `cd` into this project\'s directory, and run `uv sync`. This will create a virtualenv in `.venv` containing all project dependencies.
    - You may update dependencies later on using the same command. After updating dependencies, commit and push the changes to `pyproject.toml` to build a new image. You can track the new build\'s progress in the sidebar \"Build\" -> \"Jobs\".
6. Once your changes are complete, push them to the branch specified in [`example_job.yml`](https://gitlab.nrp-nautilus.io/varuniyer/k8s-setup-template/-/blob/main/example_job.yml?ref_type=heads#L49).
7. Finally, run the job with the following command: `kubectl create -f example_job.yml`
