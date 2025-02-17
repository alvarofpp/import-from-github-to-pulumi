# Import from GitHub to Pulumi

This repository contains a configured Docker image with scripts to import your personal
repositories or repositories, members and teams of an organization into Pulumi.

After running the import script, two sets of artifacts are generated
and saved in the `resources/`:

- `import_*.txt`: files with commands for importing resources.
- `members/*.ts`, `repositories/*.ts` and `teams/*.ts`: Pulumi resource files.

The [alvarofpp/template-infra-pulumi][template-infra] repository has a directory structure
that you can use as a basis.

## How to use

This repository can be used for two purposes:

- Importing your personal repositories.
- Importing members of an organization's repositories and teams.

For both cases, you first need to run `make build` to generate the
Docker image that will be used to run the scripts.

The commands using `make` that will be shown below can be found in the `Makefile` file.
If you choose not to use the [Makefile](`Makefile`), you can copy and paste the commands
into your terminal.

### Importing my repositories

1. Export the GitHub access token with the permissions for your repositories:

```shell
export GITHUB_ACCESS_TOKEN=github_pat_...
```

2. You also need to export your username:

```shell
export GITHUB_USER=...
```

3. Run:

```shell
make import-my-repos
```

### Importing an organization

1. Export the GitHub access token with permissions for repositories, members and teams:

```shell
export GITHUB_ACCESS_TOKEN=github_pat_...
```

2. You also need to export the organization identifier:

```shell
export GITHUB_ORG=...
```

3. Run:

```shell
make import-org
```

[template-infra]: https://github.com/alvarofpp/template-infra-pulumi
