
# install pytorch
conda install pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia

# install pip packages
PIP_COMMON_PACKAGES=opencv-contri-python \
    albumentations \
    timm \
    torchshow \
    torchmetrics \
    einops \
    imageio \
    scipy \
    scikit-learn \
    scikit-image \
    matplotlib \
    pandas \
    ipykernel

# use pip to install all the packages, yes to all
pip install $PIP_COMMON_PACKAGES

# install additional packages
pip install nvidia-dali-cuda110
pip install mmcv==2.2.0 -f https://download.openmmlab.com/mmcv/dist/cu118/torch2.3/index.html
