#!/bin/sh

# Usage:
#   makeApp.sh <appname> <url> <iconurl>
#
# Examples:
#   ./makeApp.sh Gmail https://gmail.com http://3.bp.blogspot.com/_rx1dHU9EQFY/THCcfaArRsI/AAAAAAAAB-k/-T1oLDCAEZg/s1600/gmail_logo_contact.png
#   ./makeApp.sh Gmail file:///path/to/my/downloaded/icon

# The app name. Example "Gmail". No spaces.
name=$1

# The url.
url=$2

# The icon url. Can be whatever curl can download (http://, file://, ...)
iconUrl=$3

chromePath="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
appRoot="$HOME/Applications"



# various paths used when creating the app
resourcePath="$appRoot/$name.app/Contents/Resources"
execPath="$appRoot/$name.app/Contents/MacOS" 
profilePath="$appRoot/$name.app/Contents/Profile"
plistPath="$appRoot/$name.app/Contents/Info.plist"

# make the directories
mkdir -p  $resourcePath $execPath $profilePath

# Download the icon file 
icon=/tmp/$RANDOM
curl $iconUrl > $icon

# convert the icon and copy into Resources
if [ -f $icon ] ; then
    echo "Converting icon $icon"
    sips -s format tiff $icon --out $resourcePath/icon.tiff --resampleWidth 128
    tiff2icns -noLarge $resourcePath/icon.tiff >& /dev/null
fi

# create the executable
cat >$execPath/$name <<EOF
#!/bin/sh
exec $chromePath  --app="$url" --user-data-dir="$profilePath" "\$@"
EOF
chmod +x $execPath/$name

# create the Info.plist 
cat > $plistPath <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" “http://www.apple.com/DTDs/PropertyList-1.0.dtd”>
<plist version=”1.0″>
<dict>
<key>CFBundleExecutable</key>
<string>$name</string>
<key>CFBundleIconFile</key>
<string>icon</string>
</dict>
</plist>
EOF

