# !/bin/bash

cd ./rpm/
rm -rf BUILD BUILDROOT RPMS SRPMS plasma-*.tar.* *.buildlog
cd ./../
rsync -av --exclude='.git' --exclude='rpm' ./ ./plasma-workspace-5.25.5
tar  -czf ./rpm/plasma-workspace-5.25.5.tar.gz plasma-workspace-5.25.5
rm -rf ./plasma-workspace-5.25.5
cd ./rpm/
dnf builddep plasma-workspace.spec
abb build --nodeps --target=aarch64-openmandriva-linux
cd ./../