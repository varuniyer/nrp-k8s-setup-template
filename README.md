# K8s Setup Template



## Getting started

You can (privately) fork this repo to get started. Afterwards, follow these steps:

1. Create a [Personal Access Token](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html) with the `read_repository` scope.
2. Create a [deploy token](https://docs.gitlab.com/ce/user/project/deploy_tokens/) with the `read_registry` scope.
3. Run `python create_job.py --netid NetID --gitlab-username GitLabUsername --repo-name RepoName --branch-name BranchName --output your_job.yml --gitlab-pat GitLabPAT --deploy-token-username DeployTokenUsername --deploy-token-password DeployTokenPassword`
    - `NetID` is your NetID
    - `GitLabUsername` is your gitlab username
    - `RepoName` is the name of your fork
    - `BranchName` is the name of the branch to create the job on
    - `your_job.yml` is the path to the resulting job file
    - `GitLabPAT` is the Personal Access Token you created in step 1
    - `DeployTokenUsername` is the username of the deploy token you created in step 2
    - `DeployTokenPassword` is the password of the deploy token you created in step 2
    - Do not pass in `--gitlab-pat` if you already created the secret `NetID-gitlab`
    - Do not pass in `--deploy-token-username` or `--deploy-token-password` if you already created the secret `NetID-RepoName-regcred`

4. Adjust `test_script.py` to suit your needs. If you want to pass in arguments, do so in `your_job.yml`.
5. If you would like to develop and test code locally, install and use [`uv`](https://docs.astral.sh/uv/getting-started/installation/). Open your terminal, `cd` into this project\'s directory, and run `uv sync`. This will create a virtualenv in `.venv` containing all project dependencies.
    - You may update dependencies later on using the same command. After updating dependencies, commit and push the changes to `pyproject.toml` to build a new image. You can track the new build\'s progress in the sidebar \"Build\" -> \"Jobs\".
6. Once your changes are complete, push them to `BranchName`.
7. Finally, run the job with the following command: `kubectl create -f your_job.yml`

## FAQ

### How can I get multi-GPU support?

Install `libnccl2` in the the first layer of the Dockerfile (next to `git`).

### Why do you not include configuration for a PVC (to use with CephFS) or `rclone` (to use with Ceph S3)?

Unfortunatly, the Ceph volumes offered by the NRP have several usage restrictions. Notably, even accidentally storing python dependencies in Ceph may result in a temporary ban from accessing Nautilus resources. Moreover, HuggingFace can be used to efficiently store both [datasets](https://huggingface.co/docs/datasets/en/create_dataset) and [model checkpoints](https://huggingface.co/docs/huggingface_hub/en/guides/upload). Performance can be logged using [wandb](https://docs.wandb.ai/) or [Comet](https://www.comet.com/docs/). As such, this template does not support NRP-provided storage.

### Will I need to wait for the CI/CD job to finish after each pushed commit for my next K8s job to access new code?

No, the K8s job will pull the latest code from the `BranchName` branch of your fork. You only need to wait for the CI/CD job to finish after updating the dependencies in `pyproject.toml` or the `Dockerfile`.