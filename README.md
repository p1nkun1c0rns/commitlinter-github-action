# commitlinter-github-action

## Motivation

Out in the world, there are already a few linter and one or two commitlinter GitHub actions... BUT: either they are based on [javascript and buggy](https://github.com/conventional-changelog/commitlint/issues/613) or have not been maintained for some time.

## usage

```yaml
name: "CI"
on:
  push:
  pull_request:
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v2
        with:
          # Must fetch at least the immediate parents so that if this is
          # a pull request then we can checkout the head of the pull request.
          # Only include this option if you are running this workflow on pull requests.
          fetch-depth: 2

      # If this run was triggered by a pull request event then checkout
      # the head of the pull request instead of the merge commit.
      # Only include this step if you are running this workflow on pull requests.
      - run: git checkout HEAD^2
        if: ${{ github.event_name == 'pull_request' }}

      - name: Commit Lint
        uses: p1nkun1c0rns/commitlinter-github-action@master
```

## Inputs

### workingdir

### basebranch

### author_name_regex

### author_name_message

### author_email_regex

### author_email_message

### committer_name_regex

### committer_name_message

### committer_email_regex

### committer_email_message

### commit_message_regex

### commit_message_message

## Outputs

Currently there are no outputs yet. If you need something, just open an issue.

## TODO

- [ ] Remove the basebranch thing
- [ ] Add dependabot action update thing
- [ ] Mailaddress validation?
- [ ] ignore dependabot?
- [ ] Push image to hub for more performance?
  - [ ] How to make image tags
