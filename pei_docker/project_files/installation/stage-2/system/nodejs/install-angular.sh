#!/bin/bash

echo "installing angular/cli"
pnpm install -g @angular/cli

echo "using pnpm as angular package manager"
ng config -g cli.packageManager pnpm