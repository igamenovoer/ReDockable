mkdir /workspace/conda-pkgs
set CONDA_PKGS_DIRS=/workspace/conda-pkgs

conda install pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia --download-only