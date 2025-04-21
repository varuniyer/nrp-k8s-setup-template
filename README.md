# K8s Setup Template

## Overview

This repository is a template for running Python projects on Nautilus using Kubernetes. The following instructions assume you have installed [`kubectl`](https://kubernetes.io/docs/tasks/tools/) and saved the [NRP-provided K8s config](https://portal.nrp-nautilus.io/authConfig) to `~/.kube/config`. Most of the work is done by `create_job.py`, which automatically creates a job file and K8s secrets based on user-specified arguments. Do not modify this file. This repository also provides a workflow for building and pushing Docker images to the NRP's GitLab container registry. For more details on how to use this template, see the [FAQ](#faq). 

## Getting started

First, (privately) fork this repo. Then follow these steps:

1. Create a [Personal Access Token](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html) with the `read_repository` scope.
2. Create a [deploy token](https://docs.gitlab.com/ce/user/project/deploy_tokens/) with the `read_registry` scope.
3. Run `python create_job.py --netid NetID --gitlab-username GitLabUsername --repo-name RepoName --branch-name BranchName --output your_job.yml --gitlab-pat GitLabPAT --deploy-token-username DeployTokenUsername --deploy-token-password DeployTokenPassword`
    - `NetID` is your NetID
    - `GitLabUsername` is your gitlab username
    - `RepoName` is the name of your fork
    - `BranchName` is the name of the branch containing the code to run
    - `your_job.yml` is the path where the job file will be created
    - `GitLabPAT` is the Personal Access Token you created in step 1
    - `DeployTokenUsername` is the username of the deploy token you created in step 2
    - `DeployTokenPassword` is the password of the deploy token you created in step 2
    - Do not pass in `--gitlab-pat` if you already created the secret `NetID-gitlab`
    - Do not pass in `--deploy-token-username` or `--deploy-token-password` if you already created the secret `NetID-RepoName-regcred`

4. Install and use [`uv`](https://docs.astral.sh/uv/getting-started/installation/) for local development. Run `uv sync`. Initially, this will create a virtualenv in `.venv` containing all project dependencies.
    - You may update Python dependencies in `pyproject.toml` and run `uv sync` again to update the virtualenv. After updating dependencies, commit and push your changes to build a new image. You can track the new build\'s progress on GitLab in the sidebar \"Build\" -> \"Jobs\".
5. Adjust `test_script.py` to suit your needs. Modify `your_job.yml` to pass in arguments as needed.
6. Once your changes are complete, push them to `BranchName`.
7. Finally, run the job with the following command: `kubectl create -f your_job.yml`

## FAQ

### Which files should I be changing for my own project?

Consider the following:
- `test_script.py` is run when the job is executed.
- `pyproject.toml` contains Python dependencies.
- `Dockerfile` is used to build the Docker image.
- `your_job.yml` specifies the K8s job configuration.

When changing `your_job.yml`, only change the first set of requests and limits. You can replace `python test_script.py` with a different command you want to run. Otherwise, do not change the K8s job configuration. The dependencies in `pyproject.toml` and the `Dockerfile` may be updated as needed (see Step 4 [above](#getting-started) for more details).

### How can I get multi-GPU support?

Install `libnccl2` in the [`Dockerfile`](https://gitlab.nrp-nautilus.io/varuniyer/k8s-setup-template/-/blob/main/Dockerfile?ref_type=heads#L8) (next to `git`).

### Why not include configuration for a PVC (to access [CephFS](https://nrp.ai/documentation/userdocs/storage/ceph/)) or `rclone` (to access [Ceph S3](https://nrp.ai/documentation/userdocs/storage/ceph-s3/))?

Unfortunately, storage offered by the NRP has several usage restrictions. Notably, even accidentally storing python dependencies in Ceph may result in a temporary ban from accessing Nautilus resources. Moreover, HuggingFace can be used to efficiently store both [datasets](https://huggingface.co/docs/datasets/en/create_dataset) and [model checkpoints](https://huggingface.co/docs/huggingface_hub/en/guides/upload). Performance can be logged using [wandb](https://docs.wandb.ai/) or [Comet](https://www.comet.com/docs/). Given the presence of these alternatives (which are not subject to the same usage restrictions), this template does not support NRP-provided storage.

### Will I need to wait for the GitLab CI/CD job to finish after each pushed commit for my next K8s job to access new code?

No, your K8s job automatically fetches the most recent code from your fork's `BranchName` branch. You only need to wait for the CI/CD pipeline to complete if you've modified either `pyproject.toml` or the `Dockerfile`, since these changes require rebuilding the container image.