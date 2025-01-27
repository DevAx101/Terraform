## DevContainer

Run these steps before making changes to the code. They will help automate the commands to lint the code or run tests. These steps help to ensure high code quality and reduce the likelihood that the changes inadvertently break something.


### Install latest terraform version

```shell
terraform --version
```

### Install pre-commit hooks

> This will ensure that the commands we want to execute before each commit are executed automatically.

```shell
pre-commit install
```

### Execute pre-commit hooks manually on all files

```shell
## All hooks
pre-commit run --all-files

## Checkov
pre-commit run checkov --all-files

## Terraform docs
pre-commit run terraform_docs --all-files
```

### Update pre-commit hooks

```shell
pre-commit autoupdate
```

### Execute tests manually

```shell
terraform test
```

## Reporting Bugs/Feature Requests

We welcome you to use the GitHub issue tracker to report bugs or suggest features.

When filing an issue, please check existing open, or recently closed, issues to make sure somebody else hasn't already
reported the issue. Please try to include as much information as you can. Details like these are incredibly useful:

- A reproducible test case or series of steps
- The version of our code being used
- Any modifications you've made relevant to the bug
- Anything unusual about your environment or deployment

## Contributing via Pull Requests

Contributions via pull requests are much appreciated. Before sending us a pull request, please ensure that:

1. You are working against the latest source on the *main* branch.
2. You check existing open, and recently merged, pull requests to make sure someone else hasn't addressed the problem already.
3. You open an issue to discuss any significant work - we would hate for your time to be wasted.

To send us a pull request, please:

1. Fork the repository.
2. Modify the source; please focus on the specific change you are contributing. If you also reformat all the code, it will be hard for us to focus on your change.
3. Ensure local tests pass.
4. Commit to your fork using clear commit messages.
5. Send us a pull request, answering any default questions in the pull request interface.
6. Pay attention to any automated CI failures reported in the pull request, and stay involved in the conversation.
