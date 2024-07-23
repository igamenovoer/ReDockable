# generate example configs for PeiDocker
import omegaconf as oc
import cattrs
from pei_docker.user_config import *
from pei_docker.config_processor import *
import pei_docker.pei_utils as pu
from rich import print


dir_build = './build'
fn_config = f'{dir_build}/user_config.yml'
fn_compose = f'{dir_build}/compose-template.yml'
apt_repo : str = 'tuna'
fn_output = f'pei_docker/examples/with-everything.yml'

cfg_obj = oc.OmegaConf.load(fn_config)

pu.remove_null_keys(cfg_obj)

with open(fn_output, 'w+') as f:
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
    