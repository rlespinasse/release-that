# Release That

> An opinionated GitHub Action to ease the release of a repository using semantic versioning

Minimal setup to enable semantic release on any repository

- **Step 1:** Add the  following content inside `.github/workflows/release-that.yaml` file

  ```yaml
  name: Release that
  on: [push]
  jobs:
    release-that:
      runs-on: ubuntu-latest
      steps:
        - name: Checkout sources
          uses: actions/checkout@v2

        - name: Release That
          uses: rlespinasse/release-that@v1.x
  ```

- **Step 2:** Enjoy your automatic release system

## Inputs

### `dry-run`

Whether to run semantic release in `dry-run` mode

```yaml
- uses: rlespinasse/release-that@v1.x
  with:
    dry-run: true
```

### `without-prefix`

Remove prefix from released version, like `v1.0.0` -> `1.0.0`.

```yaml
- uses: rlespinasse/release-that@v1.x
  with:
    without-prefix: true
```

### `github-token`

Whether to use a Personal Access Token instead of the default GitHub Token for release

```yaml
- uses: rlespinasse/release-that@v1.x
  with:
    github-token: ${{ secrets.YOUR_PERSONAL_ACCESS_TOKEN }}
```

By default `${{ github.token }}` is used to make a release.
[Due to limitation for security concerns][token-security], if you want to build a workflows that react when a new release is made, you must use a Personal Access Token.

## Outputs

Following outputs are from [cycjimmy/semantic-release-action][semantic-release] (see `Under the wood` section).

- new_release_published
- new_release_version
- new_release_major_version
- new_release_minor_version
- new_release_patch_version
- last_release_version

## Under the wood

This is a wrapper around [cycjimmy/semantic-release-action@v2][semantic-release] action with

- No mandatory configuration like `package.json` or `.releaserc` files
- Support of [Default branches][default-branches]
  - with the addition of `vN.x` kind of branches
- Auto-publication of a GitHub release with changelog based on the commit history

In a near future, the `release-that` action will support more release system with an opinionated way of doing it.

[semantic-release]: https://github.com/cycjimmy/semantic-release-action
[default-branches]: https://github.com/cycjimmy/semantic-release-action#branches
