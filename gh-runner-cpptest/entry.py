import os
import requests
import sys
import subprocess


def resolve_api_url():
    url = os.getenv('GITHUB_REPO_URL') or os.getenv('GITHUB_ORG_URL')
    if not url:
        print('Need GITHUB_REPO_URL or GITHUB_ORG_URL!')
        sys.exit(1)

    scope = 'repos' if os.getenv('GITHUB_REPO_URL') else 'orgs'
    name = url.lstrip('https://github.com/')

    return f'https://api.github.com/{scope}/{name}'


def get_runner_token():
    token = os.getenv('GITHUB_RUNNER_TOKEN')
    if token:
        return token

    api_token = os.getenv('GITHUB_API_TOKEN')
    if not api_token:
        print('Need GITHUB_API_TOKEN or GITHUB_RUNNER_TOKEN!')
        sys.exit(1)

    resp = requests.post(
        f'{API_URL}/actions/runners/registration-token',
        headers={
            'Accept': 'application/vnd.github.v3+json',
            'Authorization': f'token {api_token}',
        }
    )

    if resp.ok:
        json = resp.json()
        return json['token']
    else:
        print("Cannot get token from API!")
        sys.exit(1)


def configure_runner():
    token = get_runner_token()
    label = os.getenv('GITHUB_RUNNER_LABEL')
    name = os.getenv('GITHUB_RUNNER_NAME')
    replace = os.getenv('GITHUB_RUNNER_REPLACE')
    url = os.getenv('GITHUB_REPO_URL') or os.getenv('GITHUB_ORG_URL')
    work_dir = "_work"

    exe = ['./config.sh',
           '--unattended',
           '--token', token,
           '--name', name,
           '--url', url,
           '--work', work_dir]

    if label:
        exe.extend(['--labels', label])

    if replace:
        exe.append('--replace')

    proc = subprocess.run(exe)

    if proc.returncode != 0:
        print(f'{" ".join(exe)} failed!')
        sys.exit(1)


API_URL = resolve_api_url()

if not os.path.isfile('.runner'):
    configure_runner()

if len(sys.argv) > 1:
    os.execv(sys.argv[1], sys.argv[1:])
