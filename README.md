# Release That

> [!WARNING]  
> **This repository is unmaintained and has been archived.**

This project is no longer under active development. Issues and pull requests will not be monitored or reviewed.

### Migration Guide

If you were using this action, we highly recommend migrating directly to the release steps provided in `rlespinasse/release-that`. You can find the exact code snippet to use here:
👉 **[rlespinasse/release-that/action.yml#L68-L81](https://github.com/rlespinasse/release-that/blob/v1.x/action.yml#L68-L81)**

### Why was this archived?

The "major tag" feature that this action relied upon is **no longer a recommended behavior**. 

The GitHub Actions ecosystem is moving away from mutable major tags (like `@v1`) in favor of more secure and reliable methods, such as SHA pinning. You can read more about these policy changes and best practices in the official GitHub Changelog:
🔗 **[GitHub Actions policy now supports blocking and SHA pinning actions](https://github.blog/changelog/2025-08-15-github-actions-policy-now-supports-blocking-and-sha-pinning-actions/)**

Thank you to everyone who used (mainly me 😄) this project over the years!

---

> An opinionated GitHub Action to ease the release of a repository using semantic versioning

Minimal setup to enable semantic release on any repository

- **Step 1:** Add the following content inside `.github/workflows/release-that.yaml` file

  ```yaml
  name: Release that
  on: [push]
  jobs:
    release-that:
      runs-on: ubuntu-latest
      permissions:
        id-token: write
        contents: write
        issues: write
        pull-requests: write
      steps:
        - name: Checkout sources
          uses: actions/checkout@v4

        - name: Release That
          uses: rlespinasse/release-that@v1
  ```

- **Step 2:** Enjoy your automatic release system

## Inputs

### `dry-run`

Whether to make a release in `dry-run` mode. The outputs act like a release was published.

```yaml
- uses: rlespinasse/release-that@v1
  with:
    dry-run: true
```

### `without-prefix`

Remove prefix from released version, like `v1.0.0` -> `1.0.0` (doesn't apply to major tag)

```yaml
- uses: rlespinasse/release-that@v1
  with:
    without-prefix: true
```

### `major-tag`

Activate the publication a major tag based on released version. Possible values `true`, `false`, and `auto`.
If this tag already exists, it will be overwritten.

```yaml
- uses: rlespinasse/release-that@v1
  with:
    major-tag: true
```

By default, the value is `auto` to activate it (like `true`) on some conditions, otherwise, it's skip (like `false`).

- the repository is a [GitHub Action due to metadata file presence][metadata-file] `action.yml` or `action.yaml` (to follow [GitHub Action recommandation][action-versionning])
- _do not hesitate to propose the next condition through issue or pull-request_

### `github-token`

Whether to use a Personal Access Token instead of the default GitHub Token for release

```yaml
- uses: rlespinasse/release-that@v1
  with:
    github-token: ${{ secrets.YOUR_PERSONAL_ACCESS_TOKEN }}
```

By default `${{ github.token }}` is used to make a release.
[Due to limitation for security concerns][token-security], if you want to build a workflows that react when a new release is made, you must use a Personal Access Token.

On [repositories created][token-change] before `2023-02-02`, the default token was enough to let this action do its job.
Now, new repository will always need to setup `permissions` to work properly.
Please refer to **setup** documentation.

> [!TIP]
> If you get a error on your workflow run about `EGITNOPERMISSION Cannot push to the Git repository.`, you can add `persist-credentials: false` to fix it
>
> ```yaml
> - name: Checkout sources
>   uses: actions/checkout@v4
>   with:
>     persist-credentials: false
> ```

## Outputs

- **major_tag_published**: Whether a major tag was published (`true` or `false`)
- **major_tag**: Value of the published major tag, otherwise empty (e.g. `v1`)

And the following outputs from [cycjimmy/semantic-release-action][semantic-release] (see `Under the wood` section).

- **new_release_published**: Whether a new release was published (`true` or `false`)
- **new_release_version**: Version of the new release. (e.g. `1.3.0`)
- **new_release_major_version**: Major version of the new release. (e.g. `1`)
- **new_release_minor_version**: Minor version of the new release. (e.g. `3`)
- **new_release_patch_version**: Patch version of the new release. (e.g. `0`)
- **last_release_version**: Version of the previous release, if there was one. (e.g. `1.2.0`)

## Under the wood

This is a wrapper around [cycjimmy/semantic-release-action][semantic-release] action with

- No mandatory configuration like `package.json` or `.releaserc` files
- Support of [Default branches][default-branches]
  - with the addition of `vN.x` kind of branches
- Auto-publication of a GitHub release with changelog based on the commit history

[semantic-release]: https://github.com/cycjimmy/semantic-release-action
[default-branches]: https://github.com/cycjimmy/semantic-release-action#branches
[metadata-file]: https://docs.github.com/en/actions/creating-actions/metadata-syntax-for-github-actions
[action-versionning]: https://github.com/actions/toolkit/blob/master/docs/action-versioning.md#versioning
[token-security]: https://docs.github.com/en/actions/security-guides/automatic-token-authentication
[token-change]: https://github.blog/changelog/2023-02-02-github-actions-updating-the-default-github_token-permissions-to-read-only/
