netsh advfirewall firewall set rule group=”network discovery” new enable=yes
netsh firewall set service type=fileandprint mode=enable profile=all