# K8s (Kubernetes) Setup Template


## Overview

This repository is a template for running Python projects on GPU nodes in [NRP Nautilus](https://nrp.ai/documentation/). The `config_k8s.py` script automatically generates a K8s job file and secrets based on your inputs. The instructions below provide a workflow for building and pushing Docker images to the NRP's GitLab container registry. You should follow the steps below inside a [Coder](https://coder.nrp-nautilus.io/) workspace or another environment where you can install the dependencies listed in the [Prerequisites](#prerequisites) section. If your workspace has enough resources, you should directly run your code there instead of using this template.


## Prerequisites

- [Fork this repository privately on the NRP's GitLab instance](https://gitlab.nrp-nautilus.io/varuniyer/k8s-setup-template)
    - Optionally, create a new branch in your fork and follow the steps in the [Getting started](#getting-started) section on this branch
- Install [`kubectl`](https://kubernetes.io/docs/tasks/tools/), [`git`](https://git-scm.com/downloads), and [`uv`](https://docs.astral.sh/uv/getting-started/installation/)
- Save the [NRP-provided K8s config](https://portal.nrp-nautilus.io/authConfig) to `~/.kube/config`
- Create a [Personal Access Token](https://docs.gitlab.com/user/profile/personal_access_tokens/) with the `read_repository` scope
- Create a [deploy token](https://docs.gitlab.com/user/project/deploy_tokens/) for your fork with the `read_registry` scope


## Getting started

In your terminal, clone your fork of this repository and `cd` into its directory. Next, follow these steps:

1. Generate a K8s job file named `your_job.yml` with the following command:
    ```
    python config_k8s.py --netid NetID --output your_job.yml --pat GitLabPAT --dt-username DeployTokenUsername --dt-password DeployTokenPassword
    ```
    - `--pat`, `--dt-username`, and `--dt-password` can be omitted if you already created the secrets `NetID-gitlab` and `NetID-RepoName-regcred`

2. Create a virtualenv for your project:
    - Update `pyproject.toml` to include your project's dependencies
    - Run `uv sync` to install them in a new virtualenv
    - Commit and push your changes
    - This will automatically start a CI/CD pipeline on GitLab to build your image and push it to the NRP's container registry
    - Navigate to "Build" &rarr; "Jobs" in the sidebar of GitLab's web UI to monitor the build job's progress

3. Add your project's run commands to `run.sh` and add your code to the repo.

4. Modify `your_job.yml` as needed:
    - The job name (line 7)
    - Environment variables inside your container's `env` section (line 36)
    - Your container's resource requests/limits (lines 42-52)
    - The branch your job will pull code from (line 66)

5. Once your changes are complete, push them to the current branch of your fork.

6. Once the CI/CD pipeline completes, run your job with the following command:
    ```
    kubectl create -f your_job.yml
    ```
    - Run `kubectl get pods | grep <job-name>` to get the name of the pod associated with your job
    - Run `kubectl logs <pod-name>` to view the output of `run.sh`


## FAQ

### Which files should I modify for my own project?

Modify the following files along with your Python code:

- `run.sh` runs your code when the container starts
- `pyproject.toml` contains Python dependencies
- `Dockerfile` is used to build the Docker image
- `your_job.yml` specifies the K8s job configuration

Avoid changing `entrypoint.sh` as this requires rebuilding the image for changes to take effect. Add commands to `run.sh` instead.


### How can I prevent my CI/CD pipeline from timing out?

Remove unnecessary dependencies from both `pyproject.toml` and the `Dockerfile`. If this is not enough, you may extend the timeout in [`.gitlab-ci.yml` (line 14)](https://gitlab.nrp-nautilus.io/varuniyer/k8s-setup-template/-/blob/main/.gitlab-ci.yml?ref_type=heads#L14).


### Why not include configuration for a [PVC](https://nrp.ai/documentation/userdocs/tutorial/storage/#learning-objectives) (to access [CephFS](https://nrp.ai/documentation/userdocs/storage/ceph/)) or [`rclone`](https://rclone.org/) (to access [Ceph S3](https://nrp.ai/documentation/userdocs/storage/ceph-s3/))?

NRP-provided storage has usage restrictions. Notably, even accidentally storing python dependencies in Ceph may result in a temporary ban from accessing Nautilus resources. Instead, use:

- [Hugging Face Hub](https://huggingface.co/docs/hub/en/index) to efficiently store both [datasets](https://huggingface.co/docs/datasets/en/upload_dataset) and [model checkpoints](https://huggingface.co/docs/transformers/main/en/model_sharing)
- [wandb](https://docs.wandb.ai/) or [Comet](https://www.comet.com/docs/) to log experiment results

Given the presence of these alternatives (which are not subject to the same usage restrictions), this template does not support NRP-provided storage.


### Will I need to wait for the GitLab CI/CD job to finish after each pushed commit for my next K8s job to access new code?

You only need to wait for the CI/CD pipeline to complete if you've modified `pyproject.toml`, the `Dockerfile`, or `.gitlab-ci.yml`, since these changes require rebuilding the container image. You should avoid modifying `entrypoint.sh`, but if you must, you will need to wait for the CI/CD pipeline to complete for your changes to take effect.


### What if I need to install other packages?

Additional packages may be listed in the [`Dockerfile` (line 15)](https://gitlab.nrp-nautilus.io/varuniyer/k8s-setup-template/-/blob/main/Dockerfile?ref_type=heads#L15).

