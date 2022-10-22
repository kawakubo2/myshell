#!/bin/bash

if ( gcloud config set project my-first-k8s-363600 ); then
    export PROJECT_ID=$(gcloud config get-value project); 
    echo $PROJECT_ID
else
    echo 'PROJECT_IDの設定に失敗しました。';
    exit 1;
fi

if ( gcloud config set compute/zone asia-northeast1-a ); then
    export COMPUTE_ZONE=$(gcloud config get-value compute/zone)
    echo $COMPUTE_ZONE
else
    echo 'COMPUTE_ZONEの設定に失敗しました。';
    exit 1;
fi

if ( gcloud services enable cloudapis.googleapis.com container.googleapis.com ); then
    echo 'APIの有効化に成功しました。';
else
    echo 'APIの有効化に失敗しました。'
    exit 1;
fi

if ( gcloud container clusters create first-k8s-cluster --zone $COMPUTE_ZONE --cluster-version=1.22.12-gke.300 --async ); then
    echo 'clusterの作成に成功しました。';
else
    echo 'clusterの作成に失敗しました。';
    exit 1;
fi