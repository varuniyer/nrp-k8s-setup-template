"""Fills in template_job.yml with user-specified values"""

import argparse
from pathlib import Path
from subprocess import run


def main():
    parser = argparse.ArgumentParser(
        description="Fills in template_job.yml with user-specified values"
    )
    parser.add_argument("--netid", required=True, help="Your NetID")
    parser.add_argument("--username", required=True, help="Your GitLab username")
    parser.add_argument("--repo", required=True, help="Name of your forked repository")
    parser.add_argument(
        "--branch", default="main", help="Name of the branch to create the job on"
    )
    parser.add_argument(
        "--output", required=True, help="Output file name (default: job.yml)"
    )
    parser.add_argument("--pat", default="", help="Your GitLab Personal Access Token")
    parser.add_argument(
        "--dt-username",
        default="",
        help="GitLab deploy token username (gitlab+deploy-token-XXX)",
    )
    parser.add_argument(
        "--dt-password", default="", help="GitLab deploy token password"
    )

    args = parser.parse_args()
    repo_lower = args.repo.lower()

    template_vars = {
        "netid": args.netid,
        "username": args.username,
        "repo": args.repo,
        "repo_lower": repo_lower,
        "branch": args.branch,
    }

    job_content = Path("template_job.yml").read_text().format(**template_vars)
    Path(args.output).write_text(job_content)

    print(f"\nSuccessfully created {args.output}")

    if args.pat:
        print("\nCreating GitLab authentication secrets...")
        gitlab_pat_cmd = [
            "kubectl",
            "create",
            "secret",
            "generic",
            f"{args.netid}-gitlab",
            "--from-literal=user=" + args.username,
            "--from-literal=password=" + args.pat,
        ]
        run(gitlab_pat_cmd, check=True)
    else:
        print("\nSkipping GitLab authentication secret since no PAT was provided")

    if args.dt_username and args.dt_password:
        print("\nCreating registry secret...")
        registry_cmd = [
            "kubectl",
            "create",
            "secret",
            "docker-registry",
            f"{args.netid}-{repo_lower}-regcred",
            "--docker-server=gitlab-registry.nrp-nautilus.io/"
            + args.username
            + "/"
            + repo_lower,
            "--docker-username=" + args.dt_username,
            "--docker-password=" + args.dt_password,
        ]
        run(registry_cmd, check=True)
    else:
        print("\nSkipping registry secret since no deploy token was provided")

    print("\nSetup complete! You can now run your job with:")
    print(f"kubectl create -f {args.output}")


if __name__ == "__main__":
    main()
