FSTYPE=$(findmnt -n -o FSTYPE /)
if [ "$FSTYPE" != "ext4" ]; then
	return
fi

# Get the device mounted as root
ROOT_DEV=$(findmnt -no SOURCE /)

# Enable the fast commits
tune2fs -O fast_commit "$ROOT_DEV"
systemctl enable --now fstrim.timer

# Resolve to base device (handle LVM, /dev/root, etc.)
if [[ "$ROOT_DEV" == /dev/mapper/* ]]; then
  UUID=$(blkid -s UUID -o value "$ROOT_DEV")
else
  ROOT_REAL=$(readlink -f "$ROOT_DEV")
  UUID=$(blkid -s UUID -o value "$ROOT_REAL")
fi

# Backup existing fstab
cp /etc/fstab /etc/fstab.bak.$(date +%s)

# Replace the line that has our uuid
sed -i "s|^UUID=$UUID .*|UUID=$UUID / ext4 noatime,data=journal,journal_async_commit,fast_commit,commit=60 0 1|" /etc/fstab

echo "✅ /etc/fstab updated with optimized root mount options."
