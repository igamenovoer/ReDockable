import omegaconf as oc
from attrs import define, field
import attrs.validators as av
import cattrs
from rich import print

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
]

@define(kw_only=True)
class ImageConfig:
    base : str = field()
    output : str = field()
    
@define(kw_only=True)
class SSHUserConfig:
    password : str | None = field(default=None)
    pubkey_file : str | None = field(default=None)
    
    def __attrs_post_init__(self):
        if self.password is None and self.pubkey_file is None:
            raise ValueError('Either password or pubkey_file must be provided')
    
@define(kw_only=True)
class SSHConfig:
    enable : bool = field(default=False)
    port : int = field(default=22)
    host_port : int | None = field(default=None)
    users : dict[str, SSHUserConfig] = field(factory=dict)
    
@define(kw_only=True)
class ProxyConfig:
    address : str = field()
    port : int = field()
    
@define(kw_only=True)
class AptConfig:
    repo_source : str | None = field(default=None)
    keep_repo_after_build : bool = field(default=False)
    use_proxy : bool = field(default=False)
    keep_proxy_after_build : bool = field(default=False)
    
@define(kw_only=True)
class DeviceConfig:
    type : str = field(default='cpu')
    
@define(kw_only=True)
class CustomScriptConfig:
    on_build : list[str] = field(factory=list)
    on_first_run : list[str] = field(factory=list)
    on_every_run : list[str] = field(factory=list)
    
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
    
    def __attrs_post_init__(self):
        if self.type == 'manual-volume' and self.volume_name is None:
            raise ValueError('volume_name must be provided for manual-volume storage')
        if self.type == 'host' and self.host_path is None:
            raise ValueError('host_path must be provided for host storage')
        
    def get_volume_name(self, prefix : str) -> str:
        return f'{prefix}-{self.type}'

@define(kw_only=True)
class StageConfig:
    image : ImageConfig | None = field(default=None)
    ssh : SSHConfig | None = field(default=None)
    proxy : ProxyConfig | None = field(default=None)
    apt : AptConfig | None = field(default=None)
    environment : dict[str, str] | None = field(factory=dict)
    ports : list[int] | None = field(factory=list)
    device : DeviceConfig | None = field(default=None)
    custom : CustomScriptConfig | None = field(default=None)
    storage : dict[str, StorageOption] | None = field(factory=dict)
    
@define(kw_only=True)
class UserConfig:
    stage_1 : StageConfig | None = field(default=None)
    stage_2 : StageConfig | None = field(default=None)
    
# fn_config = r'templates/config-template-full.yml'
# cfg = oc.OmegaConf.load(fn_config)
# cfg_dict = oc.OmegaConf.to_container(cfg, resolve=True, throw_on_missing=False)
# # cfg_struct = UserConfig(**cfg_dict)
# cfg_struct = cattrs.structure_attrs_fromdict(cfg_dict, UserConfig)
