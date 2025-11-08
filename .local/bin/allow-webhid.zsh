#!/usr/bin/zsh

function allowwebhid() {
  local device
  local changed=0
  local failed=0

  for device in /dev/hidraw*; do
    if [[ ! -e $device ]]; then
      echo "❌ No HIDRAW devices found."
      return 1
    fi

    echo "🔧 Setting permissions on $device..."
    if sudo chmod a+rw "$device"; then
      local perms
      perms=$(ls -l "$device" | awk '{print $1, $3, $4}')
      echo "✅ $device permissions set: $perms"
      ((changed++))
    else
      echo "❌ Failed to set permissions on $device"
      ((failed++))
    fi
  done

  echo "\n📊 Summary:"
  echo "  ✅ Success: $changed"
  echo "  ❌ Failed:  $failed"
}
