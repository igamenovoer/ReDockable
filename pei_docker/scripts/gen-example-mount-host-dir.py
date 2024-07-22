# generate example configs for PeiDocker
import omegaconf as oc
from pei_docker.user_config import *
from pei_docker.config_processor import *
import pei_docker.pei_utils as pu
from rich import print
import os


dir_build = './build'
fn_config = f'{dir_build}/user_config.yml'
fn_compose = f'{dir_build}/compose-template.yml'
apt_repo : str = 'tuna'

# remove useless keys from both stage-1 and stage-2
useful_keys : list[str] = ['image', 'ssh', 'apt','storage']
ssh_user = 'me'
cfg_obj = oc.OmegaConf.load(fn_config)
cfg_stage_1 = cfg_obj['stage_1']
cfg_stage_2 = cfg_obj['stage_2']

stages : list[oc.DictConfig] = [
    cfg_obj['stage_1'], cfg_obj['stage_2']
]

for s in stages:
    keys_to_remove = [k for k in s.keys() if k not in useful_keys]
    # remove those keys
    for k in keys_to_remove:
        s.pop(k)

# configure stage-1
cfg_obj.stage_1.apt.repo_source = apt_repo
cfg_obj.stage_1.apt.pop('keep_repo_after_build')
cfg_obj.stage_1.apt.pop('use_proxy')
cfg_obj.stage_1.apt.pop('keep_proxy_after_build')

# remove all other ssh users
ssh_users_to_remove = set(cfg_obj.stage_1.ssh.users.keys())-set([ssh_user])
for u in ssh_users_to_remove:
    cfg_obj.stage_1.ssh.users.pop(u)

# configure stage-2
s2_storage = cfg_obj.stage_2.storage
dir_build_abs = os.path.abspath(dir_build)
for prefix, opt in s2_storage.items():
    opt.type='host'
    host_dir = f'{dir_build_abs}/storage/{prefix}'.replace('\\','/')
    os.makedirs(host_dir, exist_ok=True)
    opt.host_path=host_dir
    
# remove null keys
pu.remove_null_keys(cfg_obj)

# write to file
with open(f'pei_docker/examples/minimal-mount-host.yml', 'w+') as f:
    f.write(oc.OmegaConf.to_yaml(cfg_obj))

# cfg_dict = oc.OmegaConf.to_container(cfg_obj, resolve=True, throw_on_missing=True)
# user_config : UserConfig = cattrs.structure(cfg_dict, UserConfig)
# print(user_config)

compose : oc.DictConfig = oc.OmegaConf.load(fn_compose)
pei = PeiConfigProcessor.from_config(cfg_obj, compose, project_dir=dir_build)
resolved_compose = pei.process()
yaml_text = oc.OmegaConf.to_yaml(resolved_compose)
print(yaml_text)
with open(f'{dir_build}/docker-compose.yml', 'w+') as f:
    f.write(yaml_text)
    