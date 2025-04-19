# K8s Setup Template



## Getting started

You can (privately) fork this repo to get started. Afterwards, follow these steps:

1. Add your desired python version and dependencies to `pyproject.toml`.
2. Replace
    - `viyer9` in `example_job.yml` with your own NetID
    - `varuniyer` with your gitlab username when referring to the [image](https://gitlab.nrp-nautilus.io/varuniyer/k8s-setup-template/-/blob/main/example_job.yml?ref_type=heads#L14) or the [repo](https://gitlab.nrp-nautilus.io/varuniyer/k8s-setup-template/-/blob/main/example_job.yml?ref_type=heads#L51)
    - `k8s-setup-template` with the name of your fork
3. Create the GitLab authentication secrets with the command: `kubectl create secret generic NetID-gitlab --from-literal=user=USERNAME --from-literal=password=TOKEN`
    - `NetID` is your NetID
    - `USERNAME` is your gitlab username
    - `TOKEN` is a [Personal Access Token](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html) with the `read_repository` scope.
4. Follow [these instructions](https://nrp.ai/documentation/userdocs/development/private-repos/) to create a deploy token with the `read_registry` scope and use it in [`example_job.yml`](https://gitlab.nrp-nautilus.io/varuniyer/k8s-setup-template/-/blob/main/example_job.yml?ref_type=heads#L61)
    - Its name should be `NetID-REPONAME-regcred` where `NetID` is your NetID and `REPONAME` is the name of your fork
5. Adjust `test_script.py` to suit your needs. If you want to pass in arguments, do so in [`example_job.yml`](https://gitlab.nrp-nautilus.io/varuniyer/k8s-setup-template/-/blob/main/example_job.yml?ref_type=heads#L31).
6. If you would like to develop and test code locally, install and use [`uv`](https://docs.astral.sh/uv/getting-started/installation/). Open your terminal, `cd` into this project\'s directory, and run `uv sync`. This will create a virtualenv in `.venv` containing all project dependencies.
    - You may update dependencies later on using the same command. After updating dependencies, commit and push the changes to `pyproject.toml` to build a new image. You can track the new build\'s progress in the sidebar \"Build\" -> \"Jobs\".
7. Once your changes are complete, push them to the branch specified in [`example_job.yml`](https://gitlab.nrp-nautilus.io/varuniyer/k8s-setup-template/-/blob/main/example_job.yml?ref_type=heads#L49).
8. Finally, run the job with the following command: `kubectl create -f example_job.yml`
