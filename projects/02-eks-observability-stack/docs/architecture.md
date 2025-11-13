                        +---------------------------+
                        |       Developer (You)     |
                        |  git push / kubectl / CI  |
                        +-------------+-------------+
                                      |
                                      v
                        +---------------------------+
                        |         GitHub Repo       |
                        | aws-devops-portfolio      |
                        +-------------+-------------+
                                      |
                                      v
                        +---------------------------+
                        |     GitHub Actions CI     |
                        | terraform fmt/validate    |
                        | (optional) plan/apply     |
                        +-------------+-------------+
                                      |
                                      v
                  =================================================
                  |                AWS Account                    |
                  =================================================
                                      |
                                      v
                        +---------------------------+
                        |           VPC             |
                        |  2+ AZs, public/private   |
                        +-------------+-------------+
                                      |
         +----------------------------+----------------------------+
         |                                                         |
         v                                                         v
+-----------------------+                              +-----------------------+
|   Public Subnets      |                              |   Private Subnets     |
|  (NAT GW, IGW route)  |                              |  (EKS worker nodes)   |
+-----------+-----------+                              +-----------+-----------+
            |                                                          |
            |                                                          v
            |                                           +-----------------------+
            |                                           |     EKS Cluster       |
            |                                           |  (managed nodegroups) |
            |                                           +-----------+-----------+
            |                                                       |
            |                            +--------------------------+--------------------------+
            |                            |                                                     |
            |                            v                                                     v
            |              +---------------------------+                        +---------------------------+
            |              |   apps Namespace          |                        |  observability Namespace  |
            |              |---------------------------|                        |---------------------------|
            |              |  nginx Deployment         |                        |  Prometheus (k8s stack)   |
            |              |  nginx Service            |<------ ServiceMonitor--|  kube-state-metrics       |
            |              |  /metrics endpoint        |                        |  Grafana                  |
            |              +---------------------------+                        +-------------+-------------+
            |                                                                                 |
            |                                                                                 v
            |                                                                   +---------------------------+
            |                                                                   |   Grafana Dashboards      |
            |                                                                   |  - Cluster health         |
            |                                                                   |  - Pod/Node metrics       |
            |                                                                   |  - nginx HTTP metrics     |
            |                                                                   +---------------------------+
            |
            v
+-----------------------+
|    kubectl / AWS CLI  |
|   (from your laptop)  |
+-----------------------+
