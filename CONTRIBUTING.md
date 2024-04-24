# Contribute

## How to release?

In the `main` branch:

1. Create a new tag using `vX.Y.Z` version.
```
git tag vX.Y.Z
git push --tags
```
2. Create a new release and mark it as `Latest release` in GitHub.
3. Replace the tag pointing to the major version using to the same commit than the `vX.Y.Z` tag.
```
git tag --delete vX
git push --delete origin vX
git tag vX 
git push --tags
```
