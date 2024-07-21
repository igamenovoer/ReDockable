# utility methods
import omegaconf as oc
from omegaconf.omegaconf import DictConfig

def remove_null_keys(cfg: DictConfig) -> DictConfig:
    ''' remove all keys with value None in place
    '''
    shadow = cfg.copy()
    for k, v in shadow.items():
        if v is None:
            print(f'removing key {k}')
            cfg.pop(k)
        elif isinstance(v, DictConfig):
            remove_null_keys(cfg.get(k))
    return cfg