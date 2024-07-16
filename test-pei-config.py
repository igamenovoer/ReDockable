import omegaconf as oc
from attrs import define, field
from pei_docker.config_processor import *

fn_compose_template = r'pei_docker/templates/base-image-gen.yml'
fn_user_config = r'pei_docker/templates/config-template-full.yml'

cfg = oc.OmegaConf.load(fn_user_config)
compose = oc.OmegaConf.load(fn_compose_template)

obj = PeiConfigProcessor.from_config(cfg, compose)
obj.process()
compose_output = obj.m_compose_output

print(oc.OmegaConf.to_yaml(compose_output))