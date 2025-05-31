# K8s (Kubernetes) Setup Template


## Overview

This repository is a template for running Python projects on GPU nodes in [NRP Nautilus](https://nrp.ai/documentation/). `config_k8s.py` is a script that automatically generates a K8s job file and secrets based on your inputs. The instructions below provide a workflow for building and pushing Docker images to the NRP's GitLab container registry. You should follow the steps below inside either a [Coder](https://coder.nrp-nautilus.io/) workspace or your own. If your workspace has enough resources, you should directly run your code there instead of using this template.


## Prerequisites

- [Fork this repository privately on the NRP's GitLab instance](https://gitlab.nrp-nautilus.io/varuniyer/k8s-setup-template)
    - Optionally, create a new branch in your fork and follow the steps in the [Getting started](#getting-started) section on this branch
- Install [`kubectl`](https://kubernetes.io/docs/tasks/tools/), [`git`](https://git-scm.com/downloads), and [`uv`](https://docs.astral.sh/uv/getting-started/installation/)
- Save the [NRP-provided K8s config](https://portal.nrp-nautilus.io/authConfig) to `~/.kube/config`
- Create a [Personal Access Token](https://docs.gitlab.com/user/profile/personal_access_tokens/) with the `read_repository` scope
- Create a [deploy token](https://docs.gitlab.com/user/project/deploy_tokens/) for your fork with the `read_registry` scope


## Getting started

In your terminal, clone your fork of this repository and `cd` into its directory. Next, follow these steps:

1. **Generate a K8s job file** named `your_job.yml` with the following command:
    ```
    python config_k8s.py --netid NetID --output-path your_job.yml --pat GitLabPAT --dt-username DeployTokenUsername --dt-password DeployTokenPassword
    ```
    - `--pat`, `--dt-username`, and `--dt-password` are only required the first time you run this script
        - You may pass them in again to modify the values of their corresponding K8s secrets

2. **Update `pyproject.toml`** to include your project's Python dependencies:
    - Run `uv sync` to install them in a new virtualenv
    - Activate the virtualenv with `source .venv/bin/activate`

3. **Add your Python code** to the repo:
    - Place commands to run your code in `entrypoint.sh`
    - Commit and push all additions and changes

4. **Build your container image**:
    - The image will automatically build when you push changes that modify `pyproject.toml`, the `Dockerfile`, or `.gitlab-ci.yml`
    - Navigate to "Build" &rarr; "Jobs" in GitLab's web UI to monitor the build's progress
    - Expect 30-90 minutes for builds with default dependencies (maximum 3 hours)

5. **Modify the corresponding lines** in `your_job.yml` to suit your needs:
    - The job name ([line 7](https://gitlab.nrp-nautilus.io/varuniyer/k8s-setup-template/-/blob/main/job_template.yml?ref_type=heads#L7))
    - Environment variables inside your container's `env` section ([line 35](https://gitlab.nrp-nautilus.io/varuniyer/k8s-setup-template/-/blob/main/job_template.yml?ref_type=heads#L35))
    - Your container's resource requests/limits ([line 43](https://gitlab.nrp-nautilus.io/varuniyer/k8s-setup-template/-/blob/main/job_template.yml?ref_type=heads#L43))
    - The branch your job will pull code from ([line 67](https://gitlab.nrp-nautilus.io/varuniyer/k8s-setup-template/-/blob/main/job_template.yml?ref_type=heads#L67))

6. **Once your container image builds successfully, run your job** with the following command: `kubectl create -f your_job.yml`


## Monitoring and Troubleshooting

Once your job is running, follow these steps to monitor its performance and troubleshoot runtime errors:

1. **Check job status and logs**:
    - Run `kubectl get pods | grep <job-name>` to get the name of the pod associated with your job
    - Run `kubectl logs <pod-name>` to view your job's output and check for errors
    - Run `kubectl describe pod <pod-name>` to get detailed information about the pod's status and events

2. **Monitor resource usage from inside the pod**:
    - Run `kubectl exec -it <pod-name> -- /bin/bash` to login to your pod while it is running
        - Run `btop` to monitor CPU, GPU, memory, and networking usage in real-time
        - Run `nvidia-smi` to get more detailed GPU usage information

3. **Monitor externally using Grafana dashboards**:
    - [CPU, memory, and networking usage](https://grafana.nrp-nautilus.io/d/85a562078cdf77779eaa1add43ccec1e/kubernetes-compute-resources-namespace-pods?orgId=1&from=now-3h&to=now&refresh=10s)
    - [GPU utilization](https://grafana.nrp-nautilus.io/d/dRG9q0Ymz/k8s-compute-resources-namespace-gpus?orgId=1&from=now-3h&to=now&refresh=30s)


## FAQ

### Which files should I modify for my own project?

Modify the following files along with your Python code:

- `entrypoint.sh` runs your code when the container starts
- `pyproject.toml` contains Python dependencies
- `Dockerfile` is used to build the Docker image
- `your_job.yml` specifies the K8s job configuration


### What if I need to install other packages?

Additional packages may be listed in the [`Dockerfile` (line 14)](https://gitlab.nrp-nautilus.io/varuniyer/k8s-setup-template/-/blob/main/Dockerfile?ref_type=heads#L14).


### How can I prevent my CI/CD pipeline from timing out?

Remove unnecessary dependencies from both `pyproject.toml` and the `Dockerfile`. If this is not enough, you may extend the timeout in [`.gitlab-ci.yml` (line 14)](https://gitlab.nrp-nautilus.io/varuniyer/k8s-setup-template/-/blob/main/.gitlab-ci.yml?ref_type=heads#L14).


### Why not include configuration for a [PVC](https://nrp.ai/documentation/userdocs/tutorial/storage/#learning-objectives) (to access [CephFS](https://nrp.ai/documentation/userdocs/storage/ceph/)) or [`rclone`](https://rclone.org/) (to access [Ceph S3](https://nrp.ai/documentation/userdocs/storage/ceph-s3/))?

NRP-provided storage has usage restrictions. Notably, even accidentally storing Python dependencies in Ceph may result in a temporary ban from accessing Nautilus resources. Instead, use:

- [Hugging Face Hub](https://huggingface.co/docs/hub/en/index) to efficiently store both [datasets](https://huggingface.co/docs/datasets/en/upload_dataset) and [model checkpoints](https://huggingface.co/docs/transformers/main/en/model_sharing)
- [wandb](https://docs.wandb.ai/) or [Comet](https://www.comet.com/docs/) to log experiment results

Given the presence of these alternatives (which are not subject to the same usage restrictions), this template does not support NRP-provided storage.


### Where can I learn more about using Kubernetes on Nautilus?

Check out the NRP's official [documentation](https://nrp.ai/documentation/) for more information.
