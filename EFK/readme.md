# The 5 yaml were helped with ChatGPT
# Hardware limit: 3 worker nodes and 1 master nodes, each with 2 vCPU and ~15G RAM
# NFS is 192.168.1.40, only support NFS3, /volume1/k8s/ were created first, but note when ./kibana and ./elasticsearch created, both also have to be properly permissioned, otherwise kibana/elastic pods won't start
# both sub directory permission set to 770, only for lab purpose
# Due to old Synology, "no root squash" not used, instead "no mapping" used, security is 'sys', enabled asynchronous; allow connection from non-priviledge ; allow users to access mounted subfolder all enabled
# When creating PV and PVC, 60G is used, ';'subaru' become the default storage class
# /volume1/k8s/elasticsearch and  /volume1/k8s/kibana used to mount separately.
# fluentd not installed on master node, for elasticsearch and kibana, only a single pods provisioned
# K8S load balancer used!
# Performance might not be good, if deployed for a more powerful lab, use SSD for NAS and two 10G ( or even 10G uplinks)
# K8S is version v1.28.6, the suggested elasticsearch ver is 8.19.17 , kibana is ver 8.19.17, fluentd is v1.19.3
