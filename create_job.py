"""Fills in template_job.yml with user-specified values"""

import argparse
from pathlib import Path
from subprocess import run


def main():
    parser = argparse.ArgumentParser(
        description="Fills in template_job.yml with user-specified values"
    )
    parser.add_argument("--netid", required=True, help="Your NetID")
    parser.add_argument("--gitlab-username", required=True, help="Your GitLab username")
    parser.add_argument(
        "--repo-name", required=True, help="Name of your forked repository"
    )
    parser.add_argument(
        "--branch-name", default="main", help="Name of the branch to create the job on"
    )
    parser.add_argument(
        "--output", required=True, help="Output file name (default: job.yml)"
    )
    parser.add_argument(
        "--gitlab-pat", default="", help="Your GitLab Personal Access Token"
    )
    parser.add_argument(
        "--deploy-token-username",
        default="",
        help="GitLab deploy token username (gitlab+deploy-token-XXX)",
    )
    parser.add_argument(
        "--deploy-token-password", default="", help="GitLab deploy token password"
    )

    args = parser.parse_args()
    repo_name_lower = args.repo_name.lower()

    template_vars = {
        "netid": args.netid,
        "gitlab_username": args.gitlab_username,
        "repo_name": args.repo_name,
        "repo_name_lower": repo_name_lower,  # Add lowercase version for registry paths
        "branch_name": args.branch_name,
    }

    job_content = Path("template_job.yml").read_text().format(**template_vars)
    Path(args.output).write_text(job_content)

    print(f"\nSuccessfully created {args.output}")

    if args.gitlab_pat:
        print("\nCreating GitLab authentication secrets...")
        gitlab_pat_cmd = [
            "kubectl",
            "create",
            "secret",
            "generic",
            f"{args.netid}-gitlab",
            "--from-literal=user=" + args.gitlab_username,
            "--from-literal=password=" + args.gitlab_pat,
        ]
        run(gitlab_pat_cmd, check=True)
    else:
        print("\nSkipping GitLab authentication secret since no PAT was provided")

    if args.deploy_token_username and args.deploy_token_password:
        print("\nCreating registry secret...")
        registry_cmd = [
            "kubectl",
            "create",
            "secret",
            "docker-registry",
            f"{args.netid}-{repo_name_lower}-regcred",
            "--docker-server=gitlab-registry.nrp-nautilus.io/"
            + args.gitlab_username
            + "/"
            + repo_name_lower,
            "--docker-username=" + args.deploy_token_username,
            "--docker-password=" + args.deploy_token_password,
        ]
        run(registry_cmd, check=True)
    else:
        print("\nSkipping registry secret since no deploy token was provided")

    print("\nSetup complete! You can now run your job with:")
    print(f"kubectl create -f {args.output}")


if __name__ == "__main__":
    main()
