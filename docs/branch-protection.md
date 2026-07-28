# Branch Protection / Ruleset

The SDD process is only meaningful if `main` cannot be updated while bypassing the trust gates. Configure a GitHub ruleset or branch protection rule for `main` with:

- pull request required before merge;
- CI required and green (`CI / verify`);
- stale approvals dismissed after new commits;
- conversations resolved before merge;
- force-push disabled;
- branch deletion disabled;
- bypass limited to the repository owner for emergencies only.

Suggested `gh` check:

```bash
gh api repos/luispablosegovia/ios-sdd-template/branches/main/protection
```

If the API returns `Branch not protected`, the repository process and the documented SDD process are out of sync.
