DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" 
echo "Executing $DIR/_custom-on-build.sh" 
bash $DIR/../custom/stage-2/custom/my-build-1.sh
bash $DIR/../custom/stage-2/custom/my-build-2.sh