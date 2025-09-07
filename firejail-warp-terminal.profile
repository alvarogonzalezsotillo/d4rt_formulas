# launch as: firejail --profile=firejail-warp-terminal.profile /opt/warpdotdev/warp-terminal/warp
private /home/alvaro/repos/d4rt_formulas/
blacklist /datos-1T
blacklist /datos-luks/
blacklist /media

# net none          # disable network
# noroot            # don't run as root
caps.drop all     # drop Linux capabilities
# seccomp           # enable syscall filtering
First version of a formula widget