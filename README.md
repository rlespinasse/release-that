# Release That

> An opinionated GitHub Action to ease the release of a repository using semantic versioning

Just add this content inside `.github/workflows/release-that.yaml` and that all

```yaml
name: Release that
on: [push]
jobs:
  release-that:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
      - uses: rlespinasse/release-that@v1.x
```

## Additional inputs

- **dry-run** : Whether to run semantic release in `dry-run` mode

  ```yaml
  - uses: rlespinasse/release-that@v1.x
    with:
      dry-run: true
  ```

- **without-prefix** : Remove prefix from released version (`v1.0.0` -> `1.0.0`)

  ```yaml
  - uses: rlespinasse/release-that@v1.x
    with:
      without-prefix: true
  ```

## Under the wood

This is a wrapper around [cycjimmy/semantic-release-action@v2][semantic-release] action with

- Where the`package.json` file is not mandatory
- Support of [Default branches][default-branches]
  - with the addition of `vN.x` kind of branches
- Auto-publication of a GitHub release with changelog based on the commit history

[semantic-release]: https://github.com/cycjimmy/semantic-release-action
[default-branches]: https://github.com/cycjimmy/semantic-release-action#branches
