"""Fills in job_template.yml with user-specified values"""

import argparse
from pathlib import Path
from subprocess import run
from typing import NamedTuple


def secret_exists(name: str) -> bool:
    """Check if a K8s secret exists"""

    error = run(["kubectl", "get", "secret", name], capture_output=True).stderr.decode()
    missing = "NotFound" in error
    if error and not missing:
        raise Exception(f"Error getting secret {name}: {error}")
    return not missing


def create_secret(secret_type: str, name: str, args: list[str]):
    """Create a K8s secret if it doesn't exist, otherwise delete it and create a new one"""

    if secret_exists(name):
        run(["kubectl", "delete", "secret", name], check=True)
    run(["kubectl", "create", "secret", secret_type, name] + args, check=True)


class TemplateVars(NamedTuple):
    """Filled-in values for job_template.yml"""

    netid: str
    username: str
    repo: str
    repo_lower: str
    branch: str
    gitlab_secret: str
    registry_secret: str
    registry_server: str


def main():
    # Set up command line argument parser
    parser = argparse.ArgumentParser(
        description="Fills in job_template.yml with user-specified values"
    )

    # Required arguments
    parser.add_argument("--netid", required=True, help="Your NetID")
    parser.add_argument("--output-path", required=True, help="Output file path")

    # Optional arguments
    parser.add_argument("--pat", default="", help="Your GitLab Personal Access Token")
    parser.add_argument(
        "--dt-username",
        default="",
        help="GitLab deploy token username",
    )
    parser.add_argument(
        "--dt-password", default="", help="GitLab deploy token password"
    )

    # Parse command line arguments
    args = parser.parse_args()

    # Define values to fill in the template file
    username = (
        run(["git", "remote", "get-url", "origin"], capture_output=True)
        .stdout.decode()
        .split("/")[-2]
    )
    repo = (
        run(["git", "rev-parse", "--show-toplevel"], capture_output=True)
        .stdout.decode()
        .strip()
        .split("/")[-1]
    )
    repo_lower = repo.lower()
    branch = (
        run(["git", "branch", "--show-current"], capture_output=True)
        .stdout.decode()
        .strip()
    )
    template_vars = TemplateVars(
        args.netid,
        username,
        repo,
        repo_lower,
        branch,
        f"{args.netid}-gitlab",
        f"{args.netid}-{repo_lower}-regcred",
        "gitlab-registry.nrp-nautilus.io",
    )

    # Read template file, fill in values, and write to output file
    job_content = Path("job_template.yml").read_text().format(**template_vars._asdict())
    Path(args.output_path).write_text(job_content)

    print(f"\nSuccessfully created {args.output_path}")

    # Validate secrets and parameters
    gitlab_secret_exists = secret_exists(template_vars.gitlab_secret)
    registry_secret_exists = secret_exists(template_vars.registry_secret)

    if not gitlab_secret_exists and not args.pat:
        raise ValueError(
            f"Secret '{template_vars.gitlab_secret}' does not exist and no PAT provided. Use --pat to provide a Personal Access Token."
        )

    if not registry_secret_exists and (not args.dt_username or not args.dt_password):
        raise ValueError(
            f"Secret '{template_vars.registry_secret}' does not exist and deploy token credentials incomplete. Use --dt-username and --dt-password to provide deploy token credentials."
        )

    # Create GitLab authentication secret if PAT is provided
    if args.pat:
        print("\nCreating GitLab authentication secrets...")
        create_secret(
            "generic",
            template_vars.gitlab_secret,
            ["--from-literal=pat=" + args.pat],
        )
    else:
        print(f"\nUsing existing GitLab secret: {template_vars.gitlab_secret}")

    # Create Docker registry secret if deploy token credentials are provided
    if args.dt_username and args.dt_password:
        print("\nCreating registry secret...")
        create_secret(
            "docker-registry",
            template_vars.registry_secret,
            [
                "--docker-server=" + template_vars.registry_server,
                "--docker-username=" + args.dt_username,
                "--docker-password=" + args.dt_password,
            ],
        )
    else:
        print(f"\nUsing existing registry secret: {template_vars.registry_secret}")

    # Provide instructions for running the job
    print("\nSetup complete! You can now run your job with:")
    print(f"kubectl create -f {args.output_path}")


if __name__ == "__main__":
    main()
