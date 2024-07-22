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

def retain_ssh_users(ssh_config: DictConfig, user: list[str]):
    ''' retain only the ssh user specified
    
    parameters
    -------------
    ssh_config : DictConfig
        the ssh configuration, in the stage_?.ssh section
    user : list[str]
        the list of users to retain
    '''
    assert isinstance(user, list), 'user must be a list'
    
    ssh_users_to_remove = set(ssh_config.users.keys())-set(user)
    for u in ssh_users_to_remove:
        ssh_config.users.pop(u)