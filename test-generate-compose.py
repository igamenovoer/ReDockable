import omegaconf as oc
from rich import print

fn_template = r'templates\base-image.yml'
fn_output = r'docker-compose.yml'
cfg_source = oc.OmegaConf.load(fn_template)
# cfg_source['x-config'].apt.source_file=''
cfg = cfg_source.copy()
oc.OmegaConf.resolve(cfg)
del cfg['x-config']
cfg_yaml = oc.OmegaConf.to_yaml(cfg)
print(cfg_yaml)

with open(fn_output, 'w') as f:
    f.write(cfg_yaml)