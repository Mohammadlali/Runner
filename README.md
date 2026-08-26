# Runner

A **public** repository that holds no project code, only workflows.

It exists for one measured reason. A hosted runner on a public repository is
twice the machine a private one gets:

|                    | private | public |
|--------------------|---------|--------|
| cores              | 2       | **4**  |
| ram                | 7 GB    | **15 GB** |
| disk total         | 72 GB   | **145 GB** |
| free after cleanup | 43 GB   | **116 GB** |

Measured, not read off a spec sheet: run `33011733384`, job `98319465376`,
`ubuntu-24.04` image `20260823.283.1`, CPU Xeon Platinum 8573C. The same
docs that describe these machines said 14 GB of disk where 43 GB was measured,
so nothing here is believed until a job prints it.

## The rule this repo is built around

**Nothing private is ever committed here, and a public job log is public.**

The project itself lives in the private `Claud-Cloud-Project`. Workflows here
check it out into the job's workspace using a secret token. That workspace is
destroyed when the job ends; nothing from it is written back to this
repository. Results are pushed to the **private** repo's branch.

What reaches the public log is deliberately only the summary: which command
ran, and whether it passed. Full tool output goes to a transcript file that is
pushed to the private repo, never printed here.

## What it needs to work

One repository secret, which only the owner can create:

    TBS_PRIVATE_TOKEN

A fine-grained personal access token scoped to **`Mohammadlali/Claud-Cloud-Project`
only**, with `Contents: read and write`. It must not be an account-wide
classic token: a public repository's secret should be able to reach exactly
one private repository and nothing else.

Secrets are not exposed to forks, and `workflow_dispatch` here can only be
started by someone with write access, so the token is not reachable by a
stranger reading this page.

## Workflows

| file | what it does | needs the secret |
|---|---|---|
| `.github/workflows/spec.yml`  | prints what the machine actually is | no |
| `.github/workflows/gates.yml` | runs the private repo's 25 gates | yes |

## What this repo does NOT solve

Two walls are unmoved by repository visibility, and both are measured
constraints rather than opinions:

* a **6-hour ceiling** on any single job;
* **nothing persists between jobs** -- every run starts from an empty disk.

Anything with Unreal Engine in it runs up against the second one. Kaggle has
214.75 GB of persistent Datasets and a GPU; this repo has the CPU, the RAM and
the bandwidth. They are complementary, not alternatives.
