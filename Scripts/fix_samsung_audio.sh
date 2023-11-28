set -e

Password="sf"
DocsDir="$HOME/Documents"

sudo -S <<< "$Password" $DocsDir/necessary-verbs.sh
