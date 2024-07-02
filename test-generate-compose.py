import omegaconf as oc
from rich import print

fn_template = r'templates\base-image.yml'
fn_output = r'docker-compose.yml'
cfg_source = oc.OmegaConf.load(fn_template)
cfg_source['x-cfg-stage-1'].run.device='cpu'
cfg = cfg_source.copy()
oc.OmegaConf.resolve(cfg)

# keys_to_del = []
# for k in cfg.keys():
#     if k.startswith('x_') or k.startswith('x-'):
#         keys_to_del.append(k)
        
# for k in keys_to_del:
#     del cfg[k]

cfg_yaml = oc.OmegaConf.to_yaml(cfg)
print(cfg_yaml)

with open(fn_output, 'w') as f:
    f.write(cfg_yaml)