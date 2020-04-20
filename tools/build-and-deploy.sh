#!/bin/sh

# set -e

which butler

echo "Checking application versions..."
echo "-----------------------------"
cat ~/.local/share/godot/templates/3.2.stable/version.txt
godot --version
butler -V
echo "-----------------------------"

mkdir build/
mkdir build/linux/
mkdir build/osx/
mkdir build/win/

echo "EXPORTING FOR LINUX"
echo "-----------------------------"
godot --export "Linux/X11" build/linux/defend-your-plant.x86_64 -v
echo "EXPORTING FOR OSX"
echo "-----------------------------"
godot --export "Mac OSX" build/osx/defend-your-plant.dmg -v
echo "EXPORTING FOR WINDOZE"
echo "-----------------------------"
godot --export "Windows Desktop" build/win/defend-your-plant.exe -v
echo "-----------------------------"

echo "CHANGING FILETYPE AND CHMOD EXECUTABLE FOR OSX"
echo "-----------------------------"
cd build/osx/
mv defend-your-plant.dmg defend-your-plant-osx-alpha.zip
unzip defend-your-plant-osx-alpha.zip
rm defend-your-plant-osx-alpha.zip
chmod +x defend-your-plant.app/Contents/MacOS/defend-your-plant
zip -r defend-your-plant-osx-alpha.zip defend-your-plant.app
rm -rf defend-your-plant.app
cd ../../

ls -al
ls -al build/
ls -al build/linux/
ls -al build/osx/
ls -al build/win/

echo "ZIPPING FOR WINDOZE"
echo "-----------------------------"
cd build/win/
zip -r defend-your-plant-win-alpha.zip defend-your-plant.exe defend-your-plant.pck
rm -r defend-your-plant.exe defend-your-plant.pck
cd ../../

echo "ZIPPING FOR LINUX"
echo "-----------------------------"
cd build/linux/
zip -r defend-your-plant-linux-alpha.zip defend-your-plant.x86_64 defend-your-plant.pck
rm -r defend-your-plant.x86_64 defend-your-plant.pck
cd ../../

echo "Logging in to Butler"
echo "-----------------------------"
butler login

echo "Pushing builds with Butler"
echo "-----------------------------"
butler push build/linux/ synsugarstudio/ld-46:linux-alpha
butler push build/osx/ synsugarstudio/ld-46:osx-alpha
butler push build/win/ synsugarstudio/ld-46:win-alpha
