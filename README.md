# K8s Spot Termination Handler

## Table of contents
* [Introduction](#introduction)
* [Usage](#usage)
* [Related](#related)
* [Communication](#communication)
* [Contributing](#contributing)
* [License](#license)

## Introduction

The K8s Spot Termination handler watches the AWS metadata service when running on Spot Instances.

When a Spot Instance is due to be terminated, precisely 2 minutes before it's
termination a "termination notice" is issued.
The K8s Spot Termination Handler watches for this and then gracefully drains the
node it is running on before the node is taken away by AWS.

## Usage

### Deploy to Kubernetes
A docker image is available at `quay.io/pusher/k8s-spot-termination-handler`.
These images are currently built on pushes to master. Releases will be tagged as and when releases are made.

Sample Kubernetes manifests are available in the [deploy](deploy/) folder.

To deploy in clusters using RBAC, please apply all of the manifests (Daemonset, ClusterRole, ClusterRoleBinding and ServiceAccount) in the [deploy](deploy/) folder but uncomment the `serviceAccountName` in the [Daemonset](deploy/daemonset.yaml).

#### Requirements

For the K8s Termination Handler to schedule correctly; you will need an identifying label on your spot instances.

We add a label `node-role.kubernetes.io/spot-worker` to our spot instances and hence this is the default value in the node selector of the [Daemonset](deploy/daemonset.yaml).
```yaml
nodeSelector:
  "node-role.kubernetes.io/spot-worker": "true"
```
To achieve this, add the following flag to your Kubelet:
```
--node-labels="node-role.kubernetes.io/spot-worker=true"
```

## Related
- [K8s Spot Rescheduler](https://github.com/pusher/k8s-spot-rescheduler): Move nodes from on-demand instances to spot instances when space is available.

## Communication

* Found a bug? Please open an issue.
* Have a feature request. Please open an issue.
* If you want to contribute, please submit a pull request

## Contributing
Please see our [Contributing](CONTRIBUTING.md) guidelines.

## License
This project is licensed under Apache 2.0 and a copy of the license is available [here](LICENSE).
