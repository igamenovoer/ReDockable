# main command of PeiDocker utility
import os
import logging
from rich import print
from pei_docker.user_config import *

import omegaconf as oc
from omegaconf import DictConfig
import cattrs

logging.basicConfig(level=logging.INFO)

__all__ = [
    'StorageTypes',
    'StoragePrefixes',
    'StoragePaths',
    'Defaults',
    'PeiConfigProcessor',
]
    
class StoragePrefixes:
    App = 'app'
    Data = 'data'
    Workspace = 'workspace'
    
    @classmethod
    def get_all_prefixes(cls) -> list[str]:
        return [cls.App, cls.Data, cls.Workspace]
    
class StoragePaths:
    ''' In-container storage paths
    '''
    Soft = '/soft'
    HardImage = '/hard/image'
    HardVolume = '/hard/volume'

class Defaults:
    ConfigTemplatePath='./pei_docker/templates/config-template-full.yml'
    ComposeTemplatePath='./pei_docker/templates/base-image.yml'
    OutputConfigName='config.yml'
    OutputComposeName='docker-compose.yml'
    BuildDir='build'
    ContainerInstallationRoot='/init-me'
    HostInstallationRoot='./pei_docker/project_files/installation'
    Stage1_ImageName='pei-image:stage-1'
    Stage2_ImageName='pei-image:stage-2'
    Stage1_BaseImageName='ubuntu:22.04'
    RunDevice='cpu'
    
class PeiConfigProcessor:
    def __init__(self) -> None:
        self.m_config : DictConfig = None
        self.m_compose_template : DictConfig = None
        self.m_compose_output : DictConfig = None
        
        # root of installation in host
        self.m_host_dir = os.getcwd() +'/' + Defaults.HostInstallationRoot
        assert os.path.exists(self.m_host_dir), f'Host installation root {self.m_host_dir} not found'
        self.m_host_dir = os.path.abspath(self.m_host_dir).replace('\\', '/')
        
        self.m_container_dir = Defaults.ContainerInstallationRoot
        
    @classmethod
    def from_config(cls, config : DictConfig, compose_template : DictConfig) -> 'PeiConfigProcessor':
        self = cls()
        self.m_config = config
        self.m_compose_template = compose_template
        return self
    
    @classmethod
    def from_files(cls, config_file : str, compose_template_file : str) -> 'PeiConfigProcessor':
        self = cls()
        self.m_config = oc.OmegaConf.load(config_file)
        self.m_compose_template = oc.OmegaConf.load(compose_template_file)
        return self
    
    def _check_custom_scripts(self, custom_config : CustomScriptConfig) -> bool:
        ''' check if all custom scripts listed in the config exist, and update the stage config
        
        parameters
        -------------
        custom_config : CustomScriptConfig
            the custom script list from the user config
            
        return
        -----------
        is_ok : bool
            True if all scripts exist, False otherwise
        '''
        
        on_build_scripts = custom_config.on_build
        if on_build_scripts is not None:
            # check if all files listed in on_build_scripts exist, and replace it
            for i, script in enumerate(on_build_scripts):
                host_path = self.m_host_dir + '/' + script
                if not os.path.exists(host_path):
                    raise FileNotFoundError(f'Script {host_path} not found')
            
        on_first_run_scripts = custom_config.on_first_run
        if on_first_run_scripts is not None:
            # check if all files listed in on_first_run_scripts exist
            for i, script in enumerate(on_first_run_scripts):
                host_path = self.m_host_dir + '/' + script
                if not os.path.exists(host_path):
                    raise FileNotFoundError(f'Script {host_path} not found')
            
        on_every_run_scripts : list[str] = custom_config.on_every_run
        if on_every_run_scripts is not None:
            # check if all files listed in on_every_run_scripts exist
            for script in on_every_run_scripts:
                host_path = self.m_host_dir + '/' + script
                if not os.path.exists(host_path):
                    raise FileNotFoundError(f'Script {host_path} not found')
                
        return True
    
    def _apply_apt(self, apt_config : AptConfig, build_compose : DictConfig):
        ''' process the apt configuration and update the compose template
        
        parameters
        -------------
        apt_config: AptConfig
            the apt section from the user config, path is 'stage-1.apt'
        build_compose: DictConfig
            the build section from the compose template, path is 'x-cfg-stage-?.build'
        '''
        
        oc_set = oc.OmegaConf.update
        repo_source = apt_config.repo_source
        
        # check if the repo path exists
        _repo_path_host = self.m_host_dir + '/' + repo_source
        if not os.path.exists(_repo_path_host):
            raise FileNotFoundError(f'Repo source path {_repo_path_host} not found')
        
        # set it to the compose template
        _repo_path_container = self.m_container_dir + '/' + repo_source
        oc_set(build_compose, 'apt.source_file', _repo_path_container)
        
        # keep repo after build?
        keep_repo = bool(apt_config.keep_repo_after_build)  # convert to bool explicitly in case it's None
        oc_set(build_compose, 'apt.keep_source_file', keep_repo)
        
        # use proxy?
        use_proxy = bool(apt_config.use_proxy)
        oc_set(build_compose, 'apt.use_proxy', use_proxy)
        
        # keep proxy after build?
        keep_proxy = bool(apt_config.keep_proxy_after_build)
        oc_set(build_compose, 'apt.keep_proxy', keep_proxy)
    
    def _apply_proxy(self, proxy_config : ProxyConfig, build_compose : DictConfig):
        ''' process the proxy configuration and update the compose template
        
        parameters
        -------------
        proxy_config: ProxyConfig
            the proxy section from the user config, path is 'stage-1.proxy'
        build_compose: DictConfig
            the build section from the compose template, path is 'x-cfg-stage-?.build'
        '''
        oc_set = oc.OmegaConf.update
        
        adr = proxy_config.address
        oc_set(build_compose, 'proxy.address', adr)
        
        port = proxy_config.port
        oc_set(build_compose, 'proxy.port', port)
    
    def _apply_ssh_to_x_compose(self, ssh_config : SSHConfig, build_compose : DictConfig):
        ''' process the ssh configuration and update the compose template
        
        parameters
        -------------
        ssh_config: SSHConfig
            the ssh section from the user config, path is 'stage-1.ssh'
        build_compose : DictConfig
            the build section from the compose template, path is 'x-cfg-stage-?.build'    
        '''
        
        oc_get = oc.OmegaConf.select
        oc_set = oc.OmegaConf.update
        
        # set ssh
        enable_ssh = ssh_config.enable
        if enable_ssh:
            # in-container port
            ssh_port = ssh_config.port
            oc_set(build_compose, 'ssh.port', ssh_port)
            
            # users
            ssh_users = ssh_config.users
            _ssh_names : list[str] = []
            _ssh_pwds : list[str] = []
            _ssh_pubkeys : list[str] = []
            for name, info in ssh_users.items():
                _ssh_names.append(name)
                
                pw = info.password
                if pw is None:
                    _ssh_pwds.append('')
                else:
                    _ssh_pwds.append(str(pw))   # convert to string, in case it's a number
                    
                pubkey_file = info.pubkey_file
                
                if pubkey_file is not None and len(pubkey_file) > 0:
                    # check if the pubkey file exists
                    p = self.m_host_dir + '/' + pubkey_file
                    if not os.path.exists(p):
                        raise FileNotFoundError(f'Pubkey file {p} not found')
                    
                    if pubkey_file is None:
                        _ssh_pubkeys.append('')
                    else:
                        _ssh_pubkeys.append(self.m_container_dir + '/' + pubkey_file)
                    
            # set config
            oc_set(build_compose, 'ssh.username', ','.join(_ssh_names))
            oc_set(build_compose, 'ssh.password', ','.join(_ssh_pwds))
            oc_set(build_compose, 'ssh.pubkey_file', ','.join(_ssh_pubkeys))
                
    def _apply_device(self, device_config : DeviceConfig, run_compose : DictConfig):
        ''' process the device configuration and update the compose template
        
        parameters
        -------------
        device_config: DeviceConfig
            the device configuration object, to store the device type
        run_compose : DictConfig
            the run section from the compose template, path is 'x-cfg-stage-?.run'
        '''
        device_name = device_config.type
        if device_name is None:
            device_name = Defaults.RunDevice
        
        # set to compose
        oc.OmegaConf.update(run_compose, 'run.device', device_name)
        
    def _process_config_and_apply_x_compose(self, user_config : UserConfig, compose_template : DictConfig):
        ''' given user config, collect information about all the stages, and apply to the x-cfg-stage-? in compose template
        
        parameters
        -------------
        user_config: UserConfig
            the user configuration for all the stages, read from the yaml config file
        compose_template: DictConfig
            the compose template to be updated in place
            
        return
        ----------
        stage_1, stage_2: tuple[StageConfig, StageConfig]
            the stage configuration objects for stage 1 and stage 2, respectively
        '''
        user_cfg = user_config
        compose_cfg = compose_template
        oc_get = oc.OmegaConf.select
        oc_set = oc.OmegaConf.update
        
        user_compose_obj = [
            (user_cfg.stage_1, oc_get(compose_cfg, 'x-cfg-stage-1')),
            (user_cfg.stage_2, oc_get(compose_cfg, 'x-cfg-stage-2')),
        ]
        
        install_root_host : str = self.m_host_dir
        oc_set(compose_cfg, 'x-paths.installation_root_host', install_root_host)
        
        for ith_stage, _configs in enumerate(user_compose_obj):
            _stage, _compose = _configs
            
            build_compose = oc_get(_compose, 'build')
            run_compose = oc_get(_compose, 'run')
            
            # set base
            image_config = _stage.image
            if image_config is not None:
                base_image = image_config.base
                oc_set(build_compose, 'base_image', base_image)
            
            # ssh
            ssh_config = _stage.ssh
            if ssh_config is not None:
                assert ith_stage == 0, 'SSH is only available for stage 1'
                self._apply_ssh_to_x_compose(ssh_config, build_compose = build_compose)
        
            # proxy
            proxy_config = _stage.proxy
            if proxy_config is not None:
                assert ith_stage == 0, 'Proxy is only available for stage 1'
                self._apply_proxy(proxy_config, build_compose = build_compose)
                
            # apt
            apt_config = _stage.apt
            if apt_config is not None:
                assert ith_stage == 0, 'APT is only available for stage 1'
                self._apply_apt(apt_config, build_compose=build_compose)
            
            # custom scripts
            custom_config = _stage.custom
            if custom_config is not None:
                self._check_custom_scripts(custom_config)
                
            # device
            device_type : str = _stage.device.type
            if device_type is not None:
                oc_set(run_compose, 'device', device_type)
        
    def _apply_config_to_resolved_compose(self, user_config : UserConfig, compose_template : DictConfig):
        ''' apply the stage configuration to the compose template of that stage
        
        parameters
        --------------
        user_config: UserConfig
            the user configuration for all the stages
        compose_template: DictConfig
            the compose template to be updated in place, must have been resolved by OmegaConf
        '''
        
        stages : list[tuple[StageConfig, oc.DictConfig]] = [
            (user_config.stage_1, oc.OmegaConf.select(compose_template, 'services.stage-1')),
            (user_config.stage_2, oc.OmegaConf.select(compose_template, 'services.stage-2')),
        ]
        
        for ith_stage, _data in enumerate(stages):
            stage_config, stage_compose = _data
        
            # TODO: add ssh port mapping here
            # port mapping
            port_strings : list[str] = stage_config.ports
            oc.OmegaConf.update(stage_compose, 'ports', port_strings)
            
            # environment variables
            env_strings : list[str] = [f'{k}={v}' for k, v in stage_config.environment.items()]
            oc.OmegaConf.update(stage_compose, 'environment', env_strings)
            
            # stage 2 storage
            if ith_stage == 0:
                assert stage_config.storage is None or len(stage_config.storage) == 0, 'Storage is only available for stage 2'
            else:   # at stage 2
                vol_strings : list[str] = []
                for prefix, storage_opt in stage_config.storage.items():
                    soft_path = StoragePaths.Soft + '/' + prefix
                    if storage_opt.type == StorageTypes.AutoVolume:
                        # add volume to docker compose
                        oc.OmegaConf.update(compose_template, f'volumes.{prefix}', {})
                        
                        # map volume to soft path
                        vol_strings.append(f'{prefix}:{soft_path}')
                    elif storage_opt.type == StorageTypes.ManualVolume:
                        assert storage_opt.volume_name is not None, 'volume_name must be provided for manual-volume storage'
                        
                        # add volume to docker compose
                        oc.OmegaConf.update(compose_template, f'volumes.{prefix}', 
                                            {'external': True, 'name': storage_opt.volume_name})
                        
                        # map volume to soft path
                        vol_strings.append(f'{prefix}:{soft_path}')
                    elif storage_opt.type == StorageTypes.Host:
                        assert storage_opt.host_path is not None, 'host_path must be provided for host storage'
                        
                        # map host path to soft path
                        vol_strings.append(f'{storage_opt.host_path}:{soft_path}')
                    elif storage_opt.type == StorageTypes.Image:
                        # nothing to do here
                        pass
                # write to compose
                oc.OmegaConf.update(stage_compose, 'volumes', vol_strings)
        
    
    def process(self):
        ''' process the config and compose template to generate the compose output
        '''
        # user_cfg = self.m_config
        # compose_cfg = self.m_compose_template.copy()
        
        # read files for test
        # fn_template = r'templates/base-image.yml'
        # fn_config = r'templates/config-template-full.yml'
        # user_cfg = oc.OmegaConf.load(fn_config)
        # compose_cfg = oc.OmegaConf.load(fn_template)
        
        user_config : UserConfig = cattrs.structure(oc.OmegaConf.to_container(self.m_config, resolve=True), UserConfig)
        compose_template : DictConfig = self.m_compose_template.copy()
        
        # set the x-cfg-stage-? to the compose template
        self._process_config_and_apply_x_compose(user_config, compose_template)
        
        # resolve the compose template
        # oc.OmegaConf.resolve(compose_template)
        _resolve_dict = oc.OmegaConf.to_container(compose_template, resolve=True, 
                                                  throw_on_missing=True, 
                                                  structured_config_mode=oc.SCMode.DICT_CONFIG)
        compose_resolved = oc.OmegaConf.create(_resolve_dict)
        
        # apply the stage configuration to the compose template
        self._apply_config_to_resolved_compose(user_config, compose_resolved)
        
        # strip the x-? from the compose template
        useless_keys = []
        for key in list(compose_resolved.keys()):
            if key.startswith('x-'):
                useless_keys.append(key)
        for key in useless_keys:
            del compose_resolved[key]
            
        # resolve the compose template
        
        self.m_compose_output = compose_resolved