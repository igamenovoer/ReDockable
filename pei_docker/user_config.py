from attrs import define, field
import attrs.validators as av

__all__ = [
    'ImageConfig',
    'SSHUserConfig',
    'SSHConfig',
    'ProxyConfig',
    'AptConfig',
    'DeviceConfig',
    'CustomScriptConfig',
    'StorageOption',
    'StageConfig',
    'StorageTypes',
    'UserConfig',
    'port_mapping_str_to_dict',
    'port_mapping_dict_to_str',
    'env_str_to_dict',
    'env_dict_to_str',
]

def port_mapping_str_to_dict(port_mapping : list[str]) -> dict[int, int]:
    ''' get port mapping from a list of strings in the format 'host:container' to a dict,
    mapping host port to container port.
    '''
    output : dict[int, int] = {}
    
    for ent in port_mapping:
        # split the string into host and container port
        host_port, container_port = ent.split(':')
        
        # are we mapping a range of ports? in the format 'host_start-host_end:container_start-container_end'
        if '-' in host_port:
            # find the range of host ports
            host_port_start, host_port_end = host_port.split('-')
            host_port_start = int(host_port_start)
            host_port_end = int(host_port_end)
            
            # find the range of container ports
            container_port_start, container_port_end = container_port.split('-')
            container_port_start = int(container_port_start)
            container_port_end = int(container_port_end)
            
            # check if the ranges are of the same length
            if host_port_end - host_port_start != container_port_end - container_port_start:
                raise ValueError('Port ranges must be of the same length')
            
            # add the port mappings to the output
            for u, v in zip(range(host_port_start, host_port_end + 1), range(container_port_start, container_port_end + 1)):
                output[u] = v
        else:
            output[int(host_port)] = int(container_port)
    return output
    
def port_mapping_dict_to_str(port_mapping: dict[int, int]) -> list[str]:
    ''' get port mapping from a dict mapping host port to container port to a list of strings in the format 'host:container'
    '''
    
    output : list[str] = []
    
    if len(port_mapping) == 0:
        return output
    
    port_from_range_start : int = -1
    port_to_range_start : int = -1
    port_from_prev : int = -1
    port_to_prev : int = -1
    
    for port_from, port_to in sorted(port_mapping.items()):
        # first port, initialize the range
        if port_from_prev == -1:
            port_from_range_start = port_from
            port_to_range_start = port_to
        elif port_from_prev == port_from - 1 and port_to_prev == port_to - 1:
            # we are in a range, no need to do anything
            pass
        else:
            # the previous range has ended, add it to the output
            if port_from_range_start == port_from_prev: # single port
                port_mapping_entry : str = f'{port_from_range_start}:{port_to_range_start}'
                output.append(port_mapping_entry)
            else:
                port_mapping_entry : str = f'{port_from_range_start}-{port_from_prev}:{port_to_range_start}-{port_to_prev}'
                output.append(port_mapping_entry)
            
            # start a new range
            port_from_range_start = port_from
            port_to_range_start = port_to
            
        # update prev
        port_from_prev = port_from
        port_to_prev = port_to
        
    # output the last range
    if port_from_range_start == port_from_prev: # single port
        port_mapping_entry : str = f'{port_from_range_start}:{port_to_range_start}'
        output.append(port_mapping_entry)
    else:
        port_mapping_entry : str = f'{port_from_range_start}-{port_from_prev}:{port_to_range_start}-{port_to_prev}'
        output.append(port_mapping_entry)
            
    return output
    
    # return [f'{k}:{v}' for k, v in port_mapping.items()]

def env_str_to_dict(env_list: list[str]) -> dict[str, str]:
    ''' get environment variables from a list of strings in the format 'key=value' to a dict
    '''
    return {x.split('=')[0]: x.split('=')[1] for x in env_list}

def env_dict_to_str(env_dict: dict[str, str]) -> list[str]:
    ''' get environment variables from a dict to a list of strings in the format 'key=value'
    '''
    return [f'{k}={v}' for k, v in env_dict.items()]

@define(kw_only=True)
class ImageConfig:
    base : str | None = field(default=None)
    output : str | None = field(default=None)
    
@define(kw_only=True)
class SSHUserConfig:
    password : str | None = field(default=None)
    pubkey_file : str | None = field(default=None)
    
    def __attrs_post_init__(self):
        if self.password is None and self.pubkey_file is None:
            raise ValueError('Either password or pubkey_file must be provided')
    
@define(kw_only=True)
class SSHConfig:
    # HACK: default to True to enable ssh if not specified
    enable : bool = field(default=True)
    port : int = field(default=22)
    host_port : int | None = field(default=None)
    users : dict[str, SSHUserConfig] = field(factory=dict)
    
@define(kw_only=True)
class ProxyConfig:
    address : str | None = field(default=None)
    port : int | None = field(default=None)
    enable_globally : bool | None = field(default=None)
    remove_after_build : bool | None = field(default=None)
    use_https : bool = field(default=False)
    
@define(kw_only=True)
class AptConfig:
    repo_source : str | None = field(default=None)
    
    #HACK: default to True to avoid removing the repo after build
    keep_repo_after_build : bool = field(default=True)
    
    use_proxy : bool = field(default=False)
    keep_proxy_after_build : bool = field(default=False)
    
@define(kw_only=True)
class DeviceConfig:
    type : str = field(default='cpu')
    
@define(kw_only=True)
class CustomScriptConfig:
    ''' paths of custom scripts to run at different stages of the container lifecycle,
    relative to the installation directory
    '''
    on_build : list[str] = field(factory=list)
    on_first_run : list[str] = field(factory=list)
    on_every_run : list[str] = field(factory=list)
    on_user_login : list[str] = field(factory=list)
    
class StorageTypes:
    AutoVolume = 'auto-volume'
    ManualVolume = 'manual-volume'
    Host = 'host'
    Image = 'image'
    
    @classmethod
    def get_all_types(cls) -> list[str]:
        return [cls.AutoVolume, cls.ManualVolume, cls.Host, cls.Image]
    
@define(kw_only=True)
class StorageOption:
    ''' storage options for the container
    '''
    # auto-volume, manual-volume, host, image
    type : str = field(validator=av.in_(StorageTypes.get_all_types()))
    host_path : str | None = field(default=None)
    volume_name : str | None = field(default=None)
    dst_path : str | None = field(default=None)
    
    def __attrs_post_init__(self):
        if self.type == 'manual-volume' and self.volume_name is None:
            raise ValueError('volume_name must be provided for manual-volume storage')
        if self.type == 'host' and self.host_path is None:
            raise ValueError('host_path must be provided for host storage')

def env_converter(x : list[str] | dict[str, str] | None) -> dict[str, str] | None:
    ''' convert environment variable from list to dict
    '''
    if x is None:
        return None
    if isinstance(x, list):
        return env_str_to_dict(x)
    else:
        return x
@define(kw_only=True)
class StageConfig:
    image : ImageConfig | None = field(default=None)
    ssh : SSHConfig | None = field(default=None)
    proxy : ProxyConfig | None = field(default=None)
    apt : AptConfig | None = field(default=None)
    environment : dict[str,str] | None = field(default=None, converter=env_converter)
    ports : list[str] | None = field(factory=list)  # list of port mappings in docker format (e.g. 8080:80)
    device : DeviceConfig | None = field(default=None)
    custom : CustomScriptConfig | None = field(default=None)
    storage : dict[str, StorageOption] | None = field(factory=dict)
    mount: dict[str, StorageOption] | None = field(factory=dict)
    
    def get_port_mapping_as_dict(self) -> dict[int, int]:
        ''' get port mapping as a dict mapping host port to container port
        '''
        if self.ports is not None:
            return port_mapping_str_to_dict(self.ports)
        
    def set_port_mapping_from_dict(self, port_mapping: dict[int, int]):
        ''' set port mapping from a dict mapping host port to container port
        '''
        self.ports = port_mapping_dict_to_str(port_mapping)
        
    def get_environment_as_dict(self) -> dict[str, str]:
        ''' get environment variables as a dict
        '''
        if self.environment is not None and isinstance(self.environment, list):
            return env_str_to_dict(self.environment)
        else:
            return self.environment
    
@define(kw_only=True)
class UserConfig:
    stage_1 : StageConfig | None = field(default=None)
    stage_2 : StageConfig | None = field(default=None)