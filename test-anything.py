import omegaconf as oc
from rich import print

fn_test = 'octest.yml'
cfg = oc.OmegaConf.load(fn_test)
dict_cfg = oc.OmegaConf.to_container(cfg, throw_on_missing=True)