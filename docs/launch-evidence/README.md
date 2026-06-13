# Launch Evidence

This directory is reserved for external launch proof that cannot be created by local documentation work alone.

These files cover the 9 launch gates in [Open Source Launch Gates](../open-source-launch-gates.md).

Expected evidence files:

- `github-admin.md`
- `owner-decisions.md`
- `final-license.md`
- `community-entrance.md`
- `demo-asset.md`
- `hardware-smoke.md`
- `clean-machine.md`
- `app-gradle.md`
- `release-artifacts.md`

Use the files under `templates/` as the starting point. Copy a template into this directory only after the real check has been run or an attempted check has produced a concrete blocker. Keep blocker evidence as `Status: Draft` until the pass condition is directly observed.

Use [Launch Gate Closeout Plan](../launch-gate-closeout-plan.md) to decide which owner, evidence file, closeout action, and pass signal are required for each gate.

GitHub remote web snapshots:

- Store public webpage observations under `web-snapshots/`.
- Keep `web-snapshots/latest-github-remote.md` pointing to the newest dated GitHub remote snapshot.
- Use `templates/github-remote-web-snapshot.md` when GitHub API, `gh`, or token-based evidence is unavailable.
- Web snapshots can record visible remote state, but they cannot close a launch gate.

Gate audit rule:

- `Status: Passed` is required before an evidence file can close a launch gate.
- `Owner`, `Date`, `Environment`, `Evidence`, `Result`, and `Follow-up` must be complete.
- `Date` must be a valid YYYY-MM-DD calendar date and must not be in the future.
- `Evidence` must include a concrete traceable source marker such as a URL, repository path, exact command, screenshot/log path, checksum value, issue/PR number, release artifact URL, transcript/recording path, or commit hash. A generic sentence like `command output was reviewed` is not enough.
- Passed evidence must not contain pending tokens anywhere in the file: `TODO`, `TBD`, `PLACEHOLDER`, `REPLACE_ME`, or `UNKNOWN`.
- Draft files, missing fields, and unverified notes keep the gate unavailable.
- README, license, owner-decision, release manifest, or remote GitHub state changes are necessary inputs, but they do not close a gate without the matching evidence file.

Each evidence file should include the validation date, responsible owner, commands or screenshots used, observed result, and follow-up action if the result did not pass.
