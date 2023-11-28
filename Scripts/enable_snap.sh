SysCtl="sudo systemctl"
$SysCtl unmask snapd.service
$SysCtl enable snapd.seeded.service
$SysCtl enable snapd.socket
$SysCtl enable snapd.service
