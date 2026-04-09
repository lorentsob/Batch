# Contributing

Thanks for checking out the repository.

## Branching

- Open pull requests against **`develop`** for features, fixes, and reviews. That is where active development happens.
- **`main`** is the default branch on clone and the release snapshot; **do not open pull requests against `main`** unless you are the repository maintainer. Pull requests to `main` from other accounts are closed automatically with instructions to retarget **`develop`**.

The maintainer (@lorentsob) integrates on `develop` and merges or aligns to `main` when appropriate.

## Before opening a PR

1. Start from an up-to-date `develop` (`git fetch origin && git checkout develop && git pull`).
2. Create a feature or fix branch (`feature/…` or `fix/…`).
3. Open the PR with **base `develop`**.

## CI

CI uses a self-hosted runner; external forks may not get a green build without an equivalent environment. See [docs/ci-cd.md](docs/ci-cd.md).
