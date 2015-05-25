#!/usr/bin/env python

# TN316
# Regarding *-journal file http://stackoverflow.com/questions/26209091/what-is-the-journal-sqlite-database-in-android

import sys, os

def forensicFiles():

  listFiles = [
  {'location':'data/com.google.android.apps.wearable.settings/shared_prefs/com.google.android.clockwork.settings.bluetooth.xml:', 'description':'Paired Android Device', 'filetype':'file/xml'},
  {'location':'data/com.google.android.gms/databases/node.db', 'description':'notifications', 'filetype':'file/binary'},
  {'location':'data/com.google.android.gms/databases/node.db-journal', 'description':'nofications', 'filetype':'file/binary'}
  {'location':'app/', 'description':'(third) party applications', 'filetype':'directory'},
  {'location':'misc/keychain/serial_blacklist.txt', 'description':'ADB Blacklisted Serials', 'filetype':'file/plain'},
  {'location':'misc/keychain/pubkey_blacklist.txt', 'description':'ADB Blacklisted Pubkeys', 'filetype':'file/plain'},
  {'location':'misc/bluedroid/bt_config.xml', 'description':'Bluetooth Config file 1', 'filetype':'file/xml'},
  {'location':'misc/bluedroid/bt_config.old', 'description':'Bluetooth Config file 2', 'filetype':'file/xml'},
  {'location':'misc/adb/adb_keys', 'description':'ADB Allowed Keys', 'filetype':'file/plain'},
  {'location':'property/persist.sys.timezone', 'description':'Currently set Timezone', 'filetype':'file/plain'},
  {'location':'data/com.google.android.gms/files/incomingmessages', 'filetype':'directory'},
  {'location':'data/com.android.providers.settings/databases/settings.db', 'description':'LG Watch Settings', 'filetype':'file/sqlite'},
  {'location':'data/com.android.providers.settings/databases/settings.db', 'description':'LG Watch Settings', 'filetype':'file/sqlite'},
  {'location':'data/com.google.android.deskclock/shared_prefs', 'description':'Stopwatch times', 'filetype':'file/xml'},
  {'location':'data/com.google.android.gsf/databases/googlesettings.db', 'description':'Enabled location yes/no', 'filetype':'file/sqlite'}
  {'location':'data/com.google.android.gsf/databases/gservices.db', 'description':'Enabled Google services', 'filetype':'file/sqlite'},
  {'location':'data/com.npi.wearminilauncher/databases/wml.db', 'description':'installed apps overview', 'filetype':'file/sqlite'}
  ]

  return listFiles


if __name__ == "__main__":

  try:
    imageFile = sys.argv[1]

  except IndexError:
    print("No Image file specified")
    quit()

  fileListing = forensicFiles()
  analyseFile(imageFile, fileListing)

  #listFiles = forensicFiles
  #analyseFiles(listFiles)