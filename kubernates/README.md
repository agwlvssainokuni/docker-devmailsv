# Kubernetes向け定義体

## Podで実行
「kubectl run webmail01 --image=... --dry-run=client -o yaml」の出力
を加工して定義体を形成。

    kubectl apply -f webmail01-pod.yml
    kubectl expose pod webmail01 --port=80 --type=NodePort
    kubectl get pod webmail01

## Deploymentで実行
「kubectl create deployment webmail01 --image=... --dry-run=client -o yaml」
の出力を加工して定義体を形成。

    kubectl apply -f webmail01-deployment.yml
    kubectl expose deployment webmail01 --port=80 --type=NodePort
    kubectl get deployment webmail01

以上。
