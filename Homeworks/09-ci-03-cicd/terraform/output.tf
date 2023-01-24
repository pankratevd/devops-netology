resource "local_file" "hosts" {
    content  = "sonar01: ${yandex_compute_instance.sonar-01.network_interface.0.nat_ip_address}\nnexus01: ${yandex_compute_instance.nexus-01.network_interface.0.nat_ip_address}"

        filename = "../playbook/group_vars/all/outputs.yml"
}