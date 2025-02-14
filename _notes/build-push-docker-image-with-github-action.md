---
layout: note
title: Build and Push Docker Image with GitHub Actions
draft: false
date: 2025-02-14 12:00:00 +0200
author: Victor Hachard
categories: ['Docker', 'CI/CD']
---

## Purpose

This guide outlines the setup for automating the build and push of a Docker image to GitHub Container Registry (GHCR) using GitHub Actions. The workflow is triggered on:

- **Tag pushes**: Whenever a new tag is pushed.
- **Manual dispatch**: The workflow can be manually triggered.

## Prerequisites

Ensure that:
- Your repository is hosted on GitHub.
- You have **GitHub Actions** enabled.
- Your repository has permissions to push to GHCR.

## Workflow Breakdown

<pre class="mermaid">
graph LR
    B[Checkout code]
    B --> C[Get short commit hash]
    C --> D[Log in to GHCR]
    D --> E[Build Docker image]
    E --> F[Push Docker image]
</pre>

The workflow file `.github/workflows/docker-build-push.yml` follows a structured format. The resulting Docker image will be named as `ghcr.io/<REPO_OWNER>/<REPO_NAME>:<TAG>`. The tagging mechanism differentiates between two scenarios:
- For non-tag pushes (Manual dispatch), the image is tagged using the short commit hash.
- For tag pushes, the image is tagged with the corresponding tag nam

```yaml
name: Build and Push Docker Image

on:
  push:
    tags:
      - "*"
  workflow_dispatch:

jobs:
  build-and-push:
    runs-on: ubuntu-latest

    steps:
    # Checkout the repository
    - name: Checkout code
      uses: actions/checkout@v4

    # Get the short commit hash
    - name: Get short commit hash
      id: vars
      run: echo "SHORT_SHA=$(git rev-parse --short HEAD)" >> $GITHUB_ENV

    # Log in to GitHub Docker Registry
    - name: Log in to GitHub Docker Registry
      run: echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin

    # Build the Docker image
    - name: Build Docker image
      run: |
        REPO_OWNER=$(echo "${{ github.repository_owner }}" | tr '[:upper:]' '[:lower:]')
        REPO_NAME=$(echo "${{ github.repository }}" | tr '[:upper:]' '[:lower:]')
        IMAGE_TAG=$([[ "${{ github.event_name }}" == "push" && "${{ github.event.ref }}" =~ ^refs/tags/ ]] && echo "${{ github.ref_name }}" || echo "${{ env.SHORT_SHA }}")
        docker build . --file Dockerfile --tag ghcr.io/$REPO_OWNER/$REPO_NAME:${IMAGE_TAG}
        docker tag ghcr.io/$REPO_OWNER/$REPO_NAME:${IMAGE_TAG} ghcr.io/$REPO_OWNER/$REPO_NAME:latest

    # Push the Docker image to GitHub Container Registry
    - name: Push Docker image
      run: |
        REPO_OWNER=$(echo "${{ github.repository_owner }}" | tr '[:upper:]' '[:lower:]')
        REPO_NAME=$(echo "${{ github.repository }}" | tr '[:upper:]' '[:lower:]')
        IMAGE_TAG=$([[ "${{ github.event_name }}" == "push" && "${{ github.event.ref }}" =~ ^refs/tags/ ]] && echo "${{ github.ref_name }}" || echo "${{ env.SHORT_SHA }}")
        docker push ghcr.io/$REPO_OWNER/$REPO_NAME:${IMAGE_TAG}
        docker push ghcr.io/$REPO_OWNER/$REPO_NAME:latest
```
