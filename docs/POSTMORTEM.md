# Postmortem: getting the CI/CD pipeline to actually work

This pipeline existed since May but had never once completed successfully —
every run failed within seconds, before reaching anything interesting. This
is what it took to get from "has never run" to a verified live deployment.

## Starting state

- No `AWS_ROLE_ARN` GitHub secret, and no IAM role trusting the GitHub OIDC
  provider existed for this repo. Every run failed at the credentials step.
- `terraform fmt -check` had been failing on two files, blocking the plan
  job before it could even reach `terraform init`.

## What surfaced once credentials worked

Fixing the OIDC role only got the pipeline far enough to hit the next layer
of bugs — the kind that only show up when you actually try to run something,
not when you read the code:

| Bug | Symptom | Fix |
|---|---|---|
| Region mismatch | Workflow hardcoded `AWS_REGION=us-east-1`; every `.tf` file targeted `eu-west-2` | Corrected the workflow env var to match the code, not the other way around |
| Terraform version too old | `TF_VERSION: "1.5.7"` pinned, but the S3 backend used `use_lockfile` (needs >= 1.10) | Bumped to 1.10.5 |
| Stale bootstrap docs | README told you to create a DynamoDB lock table and `sed`-replace a bucket placeholder that no longer existed in `provider.tf` | Rewrote to match the real (already-hardcoded) bucket + lockfile-based locking |
| Missing IAM permission | `iam:TagPolicy` wasn't in the CI role's policy — `aws_iam_policy` tags on creation | Added the missing action |
| Deprecated Aurora version | `engine_version = "15.4"` — AWS had removed it | Bumped to the current minimum available (15.10) |
| Missing lockfile | `app/package-lock.json` was never committed; `npm ci` requires one | Generated and committed it |
| Concurrent state-lock collision | A pre-existing `terraform-plan` job had no guard against `workflow_dispatch`, so it ran at the same time as the new on-demand `apply` job against the same `dev` state key | Added `if: github.event_name != 'workflow_dispatch'` to the plan job |
| Destroy-time ECR failure | `terraform destroy` failed because the ECR repo still had images (`force_delete` defaults to false) | Added `force_delete = var.environment != "prod"` — dev tears down cleanly, prod keeps the safety net |
| `force_delete` didn't retroactively apply | Adding `force_delete` to config didn't help an already-existing repo — `terraform destroy` builds its plan from prior *state*, not current config, and the attribute was never in state | Deleted the stuck repo directly via `aws ecr delete-repository --force` once; not a recurring issue afterward |

## Result

Once all of the above was fixed: `dev` and `prod` both applied cleanly,
deployed a real Docker image to ECS Fargate, and served live traffic behind
an ALB — verified with a real screenshot in the main README, not just log
output claiming success.

## Takeaway

None of these bugs were visible from reading the Terraform files or the
GitHub Actions YAML in isolation — they only surfaced by actually running
the pipeline end to end. "The code looks right" and "the pipeline works"
turned out to be two different claims.
