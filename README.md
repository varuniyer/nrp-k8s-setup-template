# K8s Setup Template


## Overview

This repository is a template for running Python projects on [Nautilus](https://nrp.ai/documentation/) using Kubernetes. The following instructions assume you have installed [`kubectl`](https://kubernetes.io/docs/tasks/tools/) and saved the [NRP-provided K8s config](https://portal.nrp-nautilus.io/authConfig) to `~/.kube/config`. Most of the configuration is automated in `config_k8s.py`, which creates a job file and K8s secrets given user-specified arguments. This repository also provides a workflow for building and pushing Docker images to the NRP's GitLab container registry. For more details on how to use this template, see the [FAQ](#faq). 


## Getting started

First, (privately) fork this repo. Then follow these steps:

1. Create a [Personal Access Token](https://docs.gitlab.com/user/profile/personal_access_tokens/) with the `read_repository` scope.
2. Create a [deploy token](https://docs.gitlab.com/user/project/deploy_tokens/) with the `read_registry` scope.
3. Run `python config_k8s.py --netid NetID --username GitLabUsername --repo RepoName --branch BranchName --output your_job.yml --pat GitLabPAT --dt-username DeployTokenUsername --dt-password DeployTokenPassword`
    - `NetID` is your NetID
    - `GitLabUsername` is your gitlab username
    - `RepoName` is the name of your fork
    - `BranchName` is the name of the branch containing the code to run
    - `your_job.yml` is the path where the job file will be created
    - `GitLabPAT` is the Personal Access Token you created in step 1
    - `DeployTokenUsername` is the username of the deploy token you created in step 2
    - `DeployTokenPassword` is the password of the deploy token you created in step 2
    - Do not pass in `--pat` if you already created the secret `NetID-gitlab`
    - Do not pass in `--dt-username` or `--dt-password` if you already created the secret `NetID-RepoName-regcred`

4. Install and use [`uv`](https://docs.astral.sh/uv/getting-started/installation/) for local development. Run `uv sync`. Initially, this will create a virtualenv in `.venv` containing all project dependencies.
    - You may update Python dependencies in `pyproject.toml` and run `uv sync` again to update the virtualenv. After updating dependencies, commit and push your changes to `BranchName` to build your first image. You can track the build's progress on GitLab in the sidebar "Build" &rarr; "Jobs". Step 7 will only work after the image has been built.
5. Adjust `run.sh` and `test_script.py` to suit your needs. Modify `your_job.yml` to pass in arguments as needed.
6. Once your changes are complete, push them to `BranchName`.
7. Finally, run the job with the following command: `kubectl create -f your_job.yml`


## FAQ


### Which files should I be changing for my own project?

Consider the following:
- `run.sh` is the script that runs `test_script.py` when the job is executed.
- `pyproject.toml` contains Python dependencies.
- `Dockerfile` is used to build the Docker image.
- `your_job.yml` specifies the K8s job configuration.

You should only change the job's name (Line 7) and the main container's requests/limits (Lines 33-42) in `your_job.yml`. Do not change any other part of `your_job.yml`. Adjust the command in `run.sh` as needed. The dependencies in `pyproject.toml` and the `Dockerfile` may be updated as needed (see Step 4 [above](#getting-started) for more details).


### Why is my CI/CD pipeline timing out?

First, try minimizing the number of dependencies installed in `pyproject.toml` and the `Dockerfile`. Otherwise, you may increase the timeout in [`.gitlab-ci.yml`](https://gitlab.nrp-nautilus.io/varuniyer/k8s-setup-template/-/blob/main/.gitlab-ci.yml?ref_type=heads#L7).


### Why not include configuration for a PVC (to access [CephFS](https://nrp.ai/documentation/userdocs/storage/ceph/)) or `rclone` (to access [Ceph S3](https://nrp.ai/documentation/userdocs/storage/ceph-s3/))?

Unfortunately, storage offered by the NRP has several usage restrictions. Notably, even accidentally storing python dependencies in Ceph may result in a temporary ban from accessing Nautilus resources. Moreover, HuggingFace can be used to efficiently store both [datasets](https://huggingface.co/docs/datasets/en/create_dataset) and [model checkpoints](https://huggingface.co/docs/huggingface_hub/en/guides/upload). Performance can be logged using [wandb](https://docs.wandb.ai/) or [Comet](https://www.comet.com/docs/). Given the presence of these alternatives (which are not subject to the same usage restrictions), this template does not support NRP-provided storage.


### Will I need to wait for the GitLab CI/CD job to finish after each pushed commit for my next K8s job to access new code?

No, your K8s job automatically clones your fork's `BranchName` branch when the job is created. You only need to wait for the CI/CD pipeline to complete if you've modified either `pyproject.toml` or the `Dockerfile`, since these changes require rebuilding the container image.
