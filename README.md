# tekton-integration

This repo has purpose to help to test integration of SPI and Tekton on Minikube.
It is supposes that SPI already installed, so it is covetring mostly only Tekton-related stuff.
It is mostly based on the documentation located at https://redhat-scholars.github.io/tekton-tutorial/tekton-tutorial/private_reg_repos.html#_using_private_repositories_and_registries

Covered functionality is a clone private repo, build image and push it to the quay.

To install and initial configure Tekton, execute the scrips from `scripts` folder. That will install Tekton, Dashboard, configure the maven settings and maven repo using local Nexus. Also it will create 2 K8S SA-s for Tekton tasks authentication.

After scripts is finished, it is time to create GitHub and Quay secrets in the SPI. When secrets are ready, 
there is 2 commands required to create approproate AccessToken CR-s:


GH:

```
cat <<EOF | kubectl apply -n spi-auth-demo -f -
apiVersion: appstudio.redhat.com/v1beta1
kind: AccessTokenSecret
metadata:
  name: ats
spec:
  accessTokenName: <name>
  target:
    secret:
        name: github-pat-secret
        type: kubernetes.io/basic-auth  
        annotations: 
           tekton.dev/git-0: 'https://github.com'
EOF
```


and Quay: 

```
cat <<EOF | kubectl apply -n spi-auth-demo -f -
apiVersion: appstudio.redhat.com/v1beta1
kind: AccessTokenSecret
metadata:
  name: ats-t
spec:
  accessTokenName: <name>
  target:
    secret:
        name: quay-pat-secret
        type: kubernetes.io/basic-auth  
        annotations: 
           tekton.dev/docker-0: 'https://quay.io'
EOF
```


After secrets are verified to be created in the appropriate namespace,
need to upgrade the SA-s to use those secrets:

```
kubectl patch serviceaccount github-bot   -p '{"secrets": [{"name": "github-pat-secret"}]}' -n spi-auth-demo
```

and


```
kubectl patch serviceaccount build-bot   -p '{"secrets": [{"name": "quay-pat-secret"}]}' -n spi-auth-demo
```



When that is done, it is possible to create Pipelines and PipelineRuns from the `pipelines` folder:

```
kubectl create -n spi-auth-demo -f app-clone.yaml
kubectl create -n spi-auth-demo -f app-clone-run.yaml
```

wait for task finish. Then repeat for build pipeline:

```
kubectl create -n spi-auth-demo -f greeter-app-build.yaml
kubectl create -n spi-auth-demo -f greeter-app-build-run.yaml
```



TODO: maybe combine all tasks into single pipeline
