#!/bin/bash

set -e

#. ./scripts/travis-doc-upload.cfg
PROJECT_OWNER=austin-suborbitals
PROJECT_NAME=arwen
SSH_KEY_TRAVIS_ID=07882cb7e624

if [[ "$TRAVIS_BRANCH" != master || "$TRAVIS_PULL_REQUEST" = true ]]; then
    echo "refusing to build docs for branch or PR"
    exit 0
fi

eval key=\$encrypted_${SSH_KEY_TRAVIS_ID}_key
eval iv=\$encrypted_${SSH_KEY_TRAVIS_ID}_iv

mkdir -p ~/.ssh
openssl aes-256-cbc -K $key -iv $iv -in scripts/arwen_publish.enc -out ~/.ssh/id_rsa -d
chmod 600 ~/.ssh/id_rsa

git clone --branch gh-pages git@github.com:$PROJECT_OWNER/$PROJECT_NAME deploy_docs

rm -rf deploy_docs/*
cd deploy_docs
git config user.name "Travis-Generated Documentation"
git config user.email "$PROJECT_NAME@travis-ci.org"

echo "copying docs to deploy_docs..."
cp -rf ../doc/* ./

# create a pdf redirect
echo "<meta http-equiv=\"refresh\" content=\"0; URL='$PROJECT_NAME.pdf'\" />" > index.html

git add --all .
echo "commiting...."
git commit -m "doc upload for $PROJECT_NAME ($TRAVIS_COMMIT)"
echo "pushing..."
git push origin gh-pages
