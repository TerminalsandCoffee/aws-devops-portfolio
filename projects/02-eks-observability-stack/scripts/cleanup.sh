#!/bin/bash
cd terraform && terraform destroy -auto-approve
kubectl delete ns monitoring