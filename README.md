# Erazor
Eraze all disks plug in server and LSI megaraid controller

# How to use this script ?
- Boot in PXE (*ALL* disks will be erazed !)
- Get this script with wget :
```bash
wget https://raw.githubusercontent.com/Oxalide/erazor/master/disks.sh
wget https://raw.githubusercontent.com/Oxalide/erazor/master/erazor.sh
chmod +x erazor.sh
./erazor.sh
```

- Plug in all disks to eraze, launch the script. 

# Important
- After the script launch, Ctrl + C will stop all shred process found on system (in case you realize you forgot to unplug a disk). It's also possible to manually do a `killall shred`
- Watch the disks LED. 
- Check shred process in another tty (Ctrl + alt + F2) with `ps faux | grep shred | wc -l`, this number should correspond to the number of plugged disks
- SSD disks *CANNOT* be erazed with this script ! 
