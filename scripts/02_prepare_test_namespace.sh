#!/bin/bash
#
# Copyright (C) 2021 Red Hat, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#         http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
set -e

NS="spi-auth-demo"
echo "Using namespace $NS"

kubectl create ns $NS


# install tasks
kubectl apply -n $NS \
  -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/git-clone/0.1/git-clone.yaml \
  -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/maven/0.1/maven.yaml \
  -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/buildah/0.1/buildah.yaml \
  -f https://raw.githubusercontent.com/tektoncd/catalog/master/task/kn/0.1/kn.yaml \
  -f https://raw.githubusercontent.com/redhat-scholars/tekton-tutorial/master/workspaces/list-directory-task.yaml


# create PVC and workspace
echo "Creating PVC"
kubectl apply -n $NS -f https://raw.githubusercontent.com/redhat-scholars/tekton-tutorial/master/workspaces/sources-pvc.yaml


echo "Installing Nexus"
kubectl apply -n $NS https://raw.githubusercontent.com/redhat-scholars/tekton-tutorial/master/install/utils/nexus.yaml

echo "Preparing maven"
kubectl create -n $NS cm maven-settings --from-file=settings.xml=/maven/maven-settings.xml

echo "Done."