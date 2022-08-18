# CloudWatch notes

We use CloudWatch to collect and manage network logs in the VPC. The current
deployment creates two CloudWatch log groups: `/aws/eks/populare-cluster/cluster`
and `populare`; the former collects logs for traffic to the EKS control plane
elements, specifically the API server and authenticator, while the latter
collects logs for the network interfaces inside the VPC.

## EKS control plane CloudWatch logs

The EKS control plane CloudWatch logs contain network events involving one or
more of the control plane elements. Node Kubelets, the Controller Manager, and
the Scheduler frequently communicate with the API server to get information
about the cluster. Cluster admins can also make requests on the API using
`kubectl`, and developers can create apps that make direct calls on the API
server (although this is not usually advisable). We can see all of these logs
in the AWS console under CloudWatch, the `/aws/eks/populare-cluster/cluster`
log group, and the API server network interface.

We can trigger a logging event by reaching out to the API server with
`kubectl`. It can be difficult to find the exact event because there are so
many components interacting with the API server, but after careful examination
you can find it.

```bash
kubectl get secrets
```

We can now filter log events on `"kubernetes-admin"` (with quotes), which will
filter for the `kubectl` events. Here we can see I listed the secrets from my
Mac and my public IP is from a VPN server.

```
{
    "kind": "Event",
    "apiVersion": "audit.k8s.io/v1",
    "level": "Metadata",
    "auditID": "d1d2d29c-3642-478f-9ceb-582956e5ecda",
    "stage": "ResponseComplete",
    "requestURI": "/api/v1/namespaces/default/secrets?limit=500",
    "verb": "list",
    "user": {
        "username": "kubernetes-admin",
        "uid": "redacted",
        "groups": [
            "system:masters",
            "system:authenticated"
        ],
        "extra": {
            "accessKeyId": [
                "redacted"
            ],
            "arn": [
                "redacted"
            ],
            "canonicalArn": [
                "redacted"
            ],
            "sessionName": [
                ""
            ]
        }
    },
    "sourceIPs": [
        "redacted"
    ],
    "userAgent": "kubectl/v1.21.3 (darwin/amd64) kubernetes/ca643a4",
    "objectRef": {
        "resource": "secrets",
        "namespace": "default",
        "apiVersion": "v1"
    },
    "responseStatus": {
        "metadata": {},
        "code": 200
    },
    "requestReceivedTimestamp": "2022-08-18T14:46:26.706658Z",
    "stageTimestamp": "2022-08-18T14:46:26.715507Z",
    "annotations": {
        "authorization.k8s.io/decision": "allow",
        "authorization.k8s.io/reason": ""
    }
}
```

## VPC logs

The `populare` log group captures network events within the VPC. This does not
include external network interfaces, such as the elastic IPs. We can create
events by logging into bulwark and interacting with other servers in the VPC.

```bash
ssh ubuntu@10.0.4.201
# From bulwark (10.0.4.201) to a web server in the VPC (10.0.4.218).
# Ping accepted.
ping 10.0.4.218
# Curl rejected.
curl 10.0.4.86
# Curl rejected.
curl 10.0.4.86:443
```

We can see the following CloudWatch log events on one of the interfaces. The
first two are from the ping. The third and fourth are from curl. The
granularity of these events is not as fine, so some appear out of order: the
ping request and response are listed in reverse, and the HTTPS curl appears
before the HTTP curl.

```
2 890362829064 eni-013a800986ea5fcaf 10.0.4.218 10.0.4.201 0 0 1 3 252 1660830163 1660830189 ACCEPT OK
2 890362829064 eni-013a800986ea5fcaf 10.0.4.201 10.0.4.218 0 0 1 3 252 1660830163 1660830189 ACCEPT OK
2 890362829064 eni-013a800986ea5fcaf 10.0.4.201 10.0.4.218 44804 443 6 2 120 1660830192 1660830220 REJECT OK
2 890362829064 eni-013a800986ea5fcaf 10.0.4.201 10.0.4.218 49782 80 6 2 120 1660830192 1660830220 REJECT OK
```
