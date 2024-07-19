# generate example configs for PeiDocker
import omegaconf as oc
import cattrs
from pei_docker.user_config import *
from pei_docker.config_processor import *
from rich import print

fn_config = 'pei_docker/' + Defaults.ConfigTemplatePath
fn_compose = 'pei_docker/' + Defaults.ComposeTemplatePath
dir_build = './build'

# def gen_minimal_image_with_ssh(fn_config : str):
#     ''' generate a minimal ubuntu image
#     '''
useful_keys : list[str] = ['image', 'ssh', 'apt', 'custom']
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

cfg_obj.stage_1.apt.repo_source = 'cn'
cfg_obj.pop('stage_2')
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