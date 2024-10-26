# Release Action

Release is a GitHub action for automatically generating GitHub
releases, using sem-ver, when pull requests are merged.

## Usage

To use this action create a workflow (example below) to run when pull
requests are merged. You MUST checkout with a fetch-depth of '0' in
order to pull tags.

```yaml
# .github/workflows/release.yml
name: release
on:
  pull_request:
    types:
      - closed

jobs:
  if_merged:
    if: github.event.pull_request.merged == true
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: read
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: '0' # with tags, required for release
    - uses: bboughton/release-action
```

To validate that release labels have been properly added to the pull
request use the sub-action *check-version-category-label*.

```yaml
name: triage
on:
  pull_request:
    types:
      - opened
      - synchronize
      - labeled
      - unlabeled

jobs:
  check_version_category_label:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    steps:
    - uses: actions/checkout@v4
    - uses: bboughton/release-action/check-version-category-label
```

## Labels

This action uses the following set of labels to identify which segment
of the version number to increment or if the version shouldn't change:
`release/major`, `release/minor`, `release/patch`, `release/none`.
Multiple release labels on the same pull request will result in an
error.

## Monorepos

If your repository produces releases multiple artifacts that you
want to version independently you can set the action variable
*monorepo* to *true*. When this is enabled an additional label is
required to be present on pull requests. This label determines the
name of the "module" that is being released. This name is prepended to
the version when creating the release. For example if the label
`module/a` is added to the pull request the release version will be
`a/v0.0.0`. The new version of each module is determined by the
release label but based on the previous version of that module. This
means if the `release/patch` label is used then each module will have
its patch version incremented. You CANNOT specify different release
segments for different modules in the same pull request.

You can change the prefix of the module label by changing
`module_label_prefix` to something more appropriate to your use case.

To automatically label pull requests with a module label checkout the
[labeler](https://github.com/actions/labeler) action.
