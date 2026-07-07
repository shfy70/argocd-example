# Blue Green

The blue green strategy is not supported by built-in Kubernetes Deployment but available via third-party Kubernetes controller.
This example demonstrates how to implement blue-green deployment via [Argo Rollouts](https://github.com/argoproj/argo-rollouts):

1. Install Argo Rollouts controller: https://github.com/argoproj/argo-rollouts#installation
2. Create a sample application and sync it.

```
argocd app create --name blue-green --repo https://github.com/argoproj/argocd-example-apps --dest-server https://kubernetes.default.svc --dest-namespace default --path blue-green && argocd app sync blue-green
```

Once the application is synced you can access it using `blue-green-helm-guestbook` service.

3. Change image version parameter to trigger blue-green deployment process:
Save and sync to gitee!