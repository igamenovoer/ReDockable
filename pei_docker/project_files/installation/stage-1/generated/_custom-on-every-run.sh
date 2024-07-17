DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" 
echo "Executing $DIR/_custom-on-every-run.sh" 
bash $DIR/../custom/stage-1/custom/my-on-every-run-1.sh
bash $DIR/../custom/stage-1/custom/my-on-every-run-2.sh