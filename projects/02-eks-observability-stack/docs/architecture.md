                             +-------------------------------+
                             |             AWS               |
                             +-------------------------------+
                                           |
                                           v
                             +-------------------------------+
                             |              VPC              |
                             |     2+ AZs, public/private    |
                             +-------------------------------+
                              |                           |
                              v                           v
                 +----------------------+     +----------------------+
                 |    Public Subnets    |     |   Private Subnets    |
                 |  (IGW route → ALB)   |     | (NAT GW → kube nodes)|
                 +----------------------+     +----------------------+
                                                     |
                                                     v
                                           +------------------------+
                                           |      EKS Cluster       |
                                           |   Managed Node Group   |
                                           +------------------------+
                                                     |
                                ------------------------------------------------
                                |                                              |
                                v                                              v

                +---------------------------+                 +---------------------------+
                |       apps Namespace      |                 |  observability Namespace  |
                +---------------------------+                 +---------------------------+
                | nginx Deployment          |   metrics --->  | Prometheus (k8s stack)    |
                | nginx Service             |  <--- scrape    | kube-state-metrics        |
                +---------------------------+                 | node-exporter             |
                                                              | Alertmanager              |
                                                              +-------------+-------------+
                                                                            |
                                                                            v
                                                             +-----------------------------+
                                                             |          Grafana            |
                                                             |  Dashboards:                |
                                                             |   - Cluster health          |
                                                             |   - Pod/Node metrics        |
                                                             |   - nginx HTTP metrics      |
                                                             +-----------------------------+

                                           |
                                           v
                             +-------------------------------------+
                             |  kubectl / AWS CLI (your laptop)    |
                             |  port-forward → Grafana dashboards  |
                             +-------------------------------------+
