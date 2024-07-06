import omegaconf as oc
from rich import print

fn_template = r'templates/base-image.yml'
fn_config = r'templates/config-template-full.yml'

ocs = oc.OmegaConf.select
compose_cfg = oc.OmegaConf.load(fn_template)