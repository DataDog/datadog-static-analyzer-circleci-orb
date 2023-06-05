# Datadog Static Analyzer CircleCI Orb

[![CircleCI Build Status](https://circleci.com/gh/DataDog/datadog-static-analyzer-circleci-orb.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/DataDog/datadog-static-analyzer-circleci-orb) [![CircleCI Orb Version](https://badges.circleci.com/orbs/DataDog/datadog-static-analyzer-circleci-orb.svg)](https://circleci.com/developer/orbs/orb/DataDog/datadog-static-analyzer-circleci-orb) [![GitHub License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/DataDog/datadog-static-analyzer-circleci-orb/main/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

## Overview

Run a Datadog Static Analysis job in your CircleCI workflows.

## Setup

To use Datadog Static Analysis, you need to add a `static-analysis.datadog.yml` file in your repository's root directory to specify which rulesets to use.

```yaml
rulesets:
  - <ruleset-name>
  - <ruleset-name>
```

### Example for Python

You can see an example for Python-based repositories:

```yaml
rulesets:
  - python-code-style
  - python-best-practices
  - python-inclusive
```

## Workflow

Create a file in `.circleci` to run a Datadog Static Analysis job.

The following is a sample workflow file.

```yaml
version: 2.1
orbs:
  datadog-static-analysis: datadog/datadog-static-analyzer-circleci-orb@1.0.0
jobs:
  run-static-analysis-job:
    docker:
      - image: cimg/node:current
    steps:
      - checkout
      - datadog-static-analysis/analyze:
          service: my-service
workflows:
  main:
    jobs:
      - run-static-analysis-job
```

### Environment variables

Set the following environment variables in the [CircleCI Project Settings page][1].

| Name         | Description                                                                                                                | Required |
|--------------|----------------------------------------------------------------------------------------------------------------------------|----------|
| `DD_API_KEY` | Your Datadog API key. This key is created by your [Datadog organization][2] and should be stored as a secret.              | True     |
| `DD_APP_KEY` | Your Datadog application key. This key is created by your [Datadog organization][3] and should be stored as a secret.      | True     |

## Inputs

To customize your workflow, you can set the following parameters for Static Analysis.

| Name         | Description                                                                                                                | Required | Default         |
|--------------|----------------------------------------------------------------------------------------------------------------------------|----------|-----------------|
| `service` | The service you want your results tagged with.                                                                                | True     |                 |
| `env`     | The environment you want your results tagged with. Datadog recommends using `ci` as the value for this input.                 | False    | `none`          |
| `site`    | The [Datadog site][4] to send information to. Your Datadog site is {{< region-param key="dd_site" code="true" >}}.                                                                               | False    | {{< region-param key="dd_site" code="true" >}}   |

## Further Reading

Additional helpful documentation, links, and articles:

- [Static Analysis Configuration][5]

[1]: https://circleci.com/docs/set-environment-variable/#set-an-environment-variable-in-a-project
[2]: https://docs.datadoghq.com/account_management/api-app-keys/#api-keys
[3]: https://docs.datadoghq.com/account_management/api-app-keys/#application-keys
[4]: https://docs.datadoghq.com/getting_started/site/
[5]: https://docs.datadoghq.com/continuous_integration/static_analysis/configuration/
