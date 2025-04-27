# K8s (Kubernetes) Setup Template


## Overview

This repository is a template for running Python projects on GPU nodes in [NRP Nautilus](https://nrp.ai/documentation/). Most of the configuration is automated in `config_k8s.py`, which creates a job file and K8s secrets given user-specified arguments. This repository also provides a workflow for building and pushing Docker images to the NRP's GitLab container registry.


## Prerequisites

- Install [`kubectl`](https://kubernetes.io/docs/tasks/tools/), [`git`](https://git-scm.com/downloads), and [`uv`](https://docs.astral.sh/uv/getting-started/installation/)
- Save the [NRP-provided K8s config](https://portal.nrp-nautilus.io/authConfig) to `~/.kube/config`
- Create a [Personal Access Token](https://docs.gitlab.com/user/profile/personal_access_tokens/) with the `read_repository` scope.
- Create a [deploy token](https://docs.gitlab.com/user/project/deploy_tokens/) with the `read_registry` scope.
- Fork this repository either privately or publicly.


## Getting started

In your terminal, clone your fork of this repository and `cd` into its directory. Next, follow these steps:

1. Run `python config_k8s.py --netid NetID --output your_job.yml --pat GitLabPAT --dt-username DeployTokenUsername --dt-password DeployTokenPassword`
    - `NetID` is your NetID
    - `your_job.yml` is the path where the job file will be created
    - `GitLabPAT` is your Personal Access Token
    - `DeployTokenUsername` is your deploy token's username
    - `DeployTokenPassword` is your deploy token's password
    - `--pat`, `--dt-username`, and `--dt-password` are optional if you already created the secrets `NetID-gitlab` and `NetID-RepoName-regcred`
    - Adjust the branch name in `your_job.yml` as needed.

2. Run `uv sync`. This will create a virtualenv in `.venv` containing all Python dependencies.
    - You may update Python dependencies in `pyproject.toml` and run `uv sync` again to update the virtualenv.
    - Commit and push your changes
        - Push with changed dependencies to automatically trigger a CI/CD pipeline which builds your image and pushes it to the NRP's container registry.
        - Track the build job's progress on GitLab in the sidebar "Build" &rarr; "Jobs".

3. Adjust `run.sh` and `test_script.py` to suit your needs.

4. Modify `your_job.yml` as needed:
    - The job name (Line 7)
    - Environment variables inside your container's `env` section (Line 16)
    - Your container's resource requests/limits (Lines 24-34)

5. Once your changes are complete, push them to the current branch of your fork.

6. Once the CI/CD pipeline completes, run the job with the following command: `kubectl create -f your_job.yml`

7. Run `kubectl get pods | grep <job-name>` to get the name of the pod associated with your job.

8. Run `kubectl logs <pod-name>` to view the output of `run.sh`.

9. Read the [FAQ](#faq) for more details regarding this template and the [NRP Nautilus documentation](https://nrp.ai/documentation/) for more information on how to use K8s on Nautilus.


## FAQ

### Which files should I be changing for my own project?

Consider the following:
- `run.sh` runs when the container starts (executing your code).
- `pyproject.toml` contains Python dependencies.
- `Dockerfile` is used to build the Docker image.
- `your_job.yml` specifies the K8s job configuration.

You may modify these files as needed and add your own Python code. However, you should avoid changing `entrypoint.sh` (as this requires rebuilding the image for changes to take effect). Additional scripts may be run in `run.sh`.


### How can I prevent my CI/CD pipeline from timing out?

First, try minimizing the number of dependencies installed in `pyproject.toml` and the `Dockerfile`. Otherwise, you may increase the timeout in [`.gitlab-ci.yml`](https://gitlab.nrp-nautilus.io/varuniyer/k8s-setup-template/-/blob/main/.gitlab-ci.yml?ref_type=heads#L7).


### Why not include configuration for a PVC (to access [CephFS](https://nrp.ai/documentation/userdocs/storage/ceph/)) or `rclone` (to access [Ceph S3](https://nrp.ai/documentation/userdocs/storage/ceph-s3/))?

Unfortunately, storage offered by the NRP has several usage restrictions. Notably, even accidentally storing python dependencies in Ceph may result in a temporary ban from accessing Nautilus resources. Moreover, the [Hugging Face Hub](https://huggingface.co/docs/hub/en/index) can be used to efficiently store both [datasets](https://huggingface.co/docs/datasets/en/upload_dataset) and [model checkpoints](https://huggingface.co/docs/transformers/main/en/model_sharing). Performance can be logged using [wandb](https://docs.wandb.ai/) or [Comet](https://www.comet.com/docs/). Given the presence of these alternatives (which are not subject to the same usage restrictions), this template does not support NRP-provided storage.


### Will I need to wait for the GitLab CI/CD job to finish after each pushed commit for my next K8s job to access new code?

No, your K8s job automatically clones your current branch when the job is created. You only need to wait for the CI/CD pipeline to complete if you've modified `pyproject.toml`, the `Dockerfile`, or `.gitlab-ci.yml`, since these changes require rebuilding the container image. You should avoid modifying `entrypoint.sh`, but if you must, you will need to wait for the CI/CD pipeline to complete for your changes to take effect.


### How can I install additional CUDA binaries/libraries?

First, in the `Dockerfile`, change `base` to either `runtime` (for more CUDA libraries) or `devel` (for all CUDA development tools including `nvcc`). A multi-stage build may be used to select which CUDA binaries and libraries to copy into the final image. The minimal image size will expedite pushing your image to the container registry and starting your K8s job.
