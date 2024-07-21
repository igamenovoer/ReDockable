# generate example configs for PeiDocker
import omegaconf as oc
import cattrs
from pei_docker.user_config import *
from pei_docker.config_processor import *
from rich import print


dir_build = './build'
fn_config = f'{dir_build}/user_config.yml'
fn_compose = f'{dir_build}/compose-template.yml'

# def gen_minimal_image_with_ssh(fn_config : str):
#     ''' generate a minimal ubuntu image
#     '''
useful_keys : list[str] = ['image', 'ssh', 'apt','storage']
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

cfg_obj.stage_1.apt.repo_source = 'aliyun'
# cfg_obj.stage_1.apt.repo_source = '163'
cfg_obj.stage_1.apt.pop('keep_repo_after_build')
cfg_obj.stage_1.apt.pop('use_proxy')
cfg_obj.stage_1.apt.pop('keep_proxy_after_build')

# cfg_obj.pop('stage_2')

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
    