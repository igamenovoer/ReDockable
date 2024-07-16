# main command of PeiDocker utility
import omegaconf as oc
from omegaconf import DictConfig
from dataclasses import dataclass, field
import click
import os
import shutil
import logging
from rich import print
from pei_docker.user_config import *
logging.basicConfig(level=logging.INFO)
import sys

# TODO: use cattrs to convert the yaml to the stage config
    
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
    ConfigTemplatePath='templates/config-template-full.yml'
    ComposeTemplatePath='templates/base-image.yml'
    OutputConfigName='config.yml'
    OutputComposeName='docker-compose.yml'
    BuildDir='build'
    ContainerInstallationRoot='/init-me'
    HostInstallationRoot='./installation'
    Stage1_ImageName='pei-image:stage-1'
    Stage2_ImageName='pei-image:stage-2'
    Stage1_BaseImageName='ubuntu:22.04'
    RunDevice='cpu'
    
class PeiConfigProcessor:
    def __init__(self) -> None:
        self.m_config : DictConfig = None
        self.m_compose_template : DictConfig = None
        self.m_compose_output : DictConfig = None
        
        # collect from all stages
        self.m_stage_1 : StageConfig = StageConfig(base_image=Defaults.Stage1_BaseImageName, output_image=Defaults.Stage1_ImageName)
        self.m_stage_2 : StageConfig = StageConfig(base_image=Defaults.Stage1_ImageName, output_image=Defaults.Stage2_ImageName)
        
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
    
    # TODO: changed StageConfig to user_config.StageConfig, modify source to adapt
    def _check_custom_scripts(self, custom_config : DictConfig, stage_config : StageConfig):
        ''' check if all custom scripts listed in the config exist, and update the stage config
        
        parameters
        -------------
        stage_config: StageConfig
            the stage configuration object to store the scripts
        '''
        
        oc_get = oc.OmegaConf.select
        
        on_build_scripts = stage_config.custom.on_build
        if on_build_scripts is not None:
            # check if all files listed in on_build_scripts exist, and replace it
            for i, script in enumerate(on_build_scripts):
                host_path = self.m_host_dir + '/' + script
                if not os.path.exists(host_path):
                    raise FileNotFoundError(f'Script {host_path} not found')
            
        on_first_run_scripts = stage_config.custom.on_first_run
        if on_first_run_scripts is not None:
            # check if all files listed in on_first_run_scripts exist
            for i, script in enumerate(on_first_run_scripts):
                host_path = self.m_host_dir + '/' + script
                if not os.path.exists(host_path):
                    raise FileNotFoundError(f'Script {host_path} not found')
            
        on_every_run_scripts : list[str] = oc_get(custom_config, 'on-every-run')
        if on_every_run_scripts is not None:
            # check if all files listed in on_every_run_scripts exist
            for script in on_every_run_scripts:
                host_path = self.m_host_dir + '/' + script
                if not os.path.exists(host_path):
                    raise FileNotFoundError(f'Script {host_path} not found')
    
    def _apply_apt(self, apt_config : DictConfig, build_compose : DictConfig):
        ''' process the apt configuration and update the compose template
        
        parameters
        -------------
        apt_config: DictConfig
            the apt section from the user config, path is 'stage-1.apt'
        build_compose: DictConfig
            the build section from the compose template, path is 'x-cfg-stage-?.build'
        '''
        
        oc_get = oc.OmegaConf.select
        oc_set = oc.OmegaConf.update
        
        repo_source = oc_get(apt_config, 'repo_source')
        
        # check if the repo path exists
        _repo_path_host = self.m_host_dir + '/' + repo_source
        if not os.path.exists(_repo_path_host):
            raise FileNotFoundError(f'Repo source path {_repo_path_host} not found')
        
        # set it to the compose template
        _repo_path_container = self.m_container_dir + '/' + repo_source
        oc_set(build_compose, 'apt.source_file', _repo_path_container)
        
        # keep repo after build?
        keep_repo = oc_get(apt_config, 'keep_repo_after_build')
        keep_repo = bool(keep_repo)
        oc_set(build_compose, 'apt.keep_source_file', keep_repo)
        
        # use proxy?
        use_proxy = oc_get(apt_config, 'use_proxy')
        use_proxy = bool(use_proxy)
        oc_set(build_compose, 'apt.use_proxy', use_proxy)
        
        # keep proxy after build?
        keep_proxy = oc_get(apt_config, 'keep_proxy_after_build')
        keep_proxy = bool(keep_proxy)
        oc_set(build_compose, 'apt.keep_proxy', keep_proxy)
    
    def _apply_proxy(self, proxy_config : DictConfig, build_compose : DictConfig):
        ''' process the proxy configuration and update the compose template
        
        parameters
        -------------
        proxy_config: DictConfig
            the proxy section from the user config, path is 'stage-1.proxy'
        build_compose: DictConfig
            the build section from the compose template, path is 'x-cfg-stage-?.build'
        '''
        
        oc_get = oc.OmegaConf.select
        oc_set = oc.OmegaConf.update
        
        adr = oc_get(proxy_config, 'address')
        oc_set(build_compose, 'proxy.address', adr)
        
        port = oc_get(proxy_config, 'port')
        oc_set(build_compose, 'proxy.port', port)
    
    def _apply_ssh_to_x_compose(self, ssh_config : SSHConfig, build_compose : DictConfig):
        ''' process the ssh configuration and update the compose template
        
        parameters
        -------------
        stage_config: StageConfig
            the stage configuration object, to store the port mapping
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
                
    def _apply_and_collect_device_info(self, stage_config : StageConfig, run_compose : DictConfig):
        ''' process the device configuration and update the compose template
        
        parameters
        -------------
        device_config: DictConfig
            the device section from the user config, path is 'stage-?.device'
        run_compose : DictConfig
            the run section from the compose template, path is 'x-cfg-stage-?.run'
        stage_config: StageConfig
            the stage configuration object, to store the device information
        '''
        oc_get = oc.OmegaConf.select
        
        device_name = stage_config.device
        if device_name is None:
            device_name = Defaults.RunDevice
            
        assert device_name in ['cpu', 'gpu'], 'Device type must be either cpu or gpu'
        
        # set to compose
        oc.OmegaConf.update(run_compose, 'run.device', device_name)
        
    def _process_config_and_apply_x_compose(self, user_config : UserConfig, compose_template : DictConfig):
        ''' given user config, collect information about all the stages, and apply to the x-cfg-stage-? in compose template
        
        parameters
        -------------
        user_config: UserConfig
            the user configuration for all the stages, read from the yaml config file
        compose_template: DictConfig
            the compose template to be updated
        '''
        user_cfg = user_config
        compose_cfg = compose_template
        oc_get = oc.OmegaConf.select
        
        stage_1 : StageConfig = StageConfig(base_image=Defaults.Stage1_BaseImageName, output_image=Defaults.Stage1_ImageName)
        stage_2 : StageConfig = StageConfig(base_image=Defaults.Stage1_ImageName, output_image=Defaults.Stage2_ImageName)
        
        user_compose_obj = [
            (oc_get(user_cfg, 'stage-1'), oc_get(compose_cfg, 'x-cfg-stage-1'), stage_1),
            (oc_get(user_cfg, 'stage-2'), oc_get(compose_cfg, 'x-cfg-stage-2'), stage_2),
        ]
        
        for ith_stage, _configs in enumerate(user_compose_obj):
            _user, _compose, _obj = _configs
            
            output_image_name : str = oc_get(_user, 'image.output')
            assert output_image_name, 'Output image name must be set'
            _obj.output_image = output_image_name
            
            base_image : str = oc_get(_user, 'image.base')
            assert base_image, 'Base image name must be set'
            _obj.base_image = base_image
            
            build_compose = oc_get(_compose, 'build')
            run_compose = oc_get(_compose, 'run')
            
            # ssh
            ssh_config = oc_get(_user, 'ssh')
            if ssh_config is not None:
                assert ith_stage == 0, 'SSH is only available for stage 1'
                self._apply_ssh(ssh_config, build_compose = build_compose, stage_config=_obj)
        
            # proxy
            proxy_config = oc_get(_user, 'proxy')
            if proxy_config is not None:
                assert ith_stage == 0, 'Proxy is only available for stage 1'
                self._apply_proxy(proxy_config, build_compose = build_compose)
                
            # apt
            apt_config = oc_get(_user, 'apt')
            if apt_config is not None:
                assert ith_stage == 0, 'APT is only available for stage 1'
                self._apply_apt(apt_config, build_compose=build_compose)            
            
            # environment
            env_config = oc_get(_user, 'environment')
            if env_config is not None:
                self._collect_env(env_config, _obj)
                
            # additional port mapping
            port_mapping = oc_get(_user, 'ports')
            if port_mapping is not None:
                self._collect_port_mapping(port_mapping, _obj)
                
            # device
            device_config = oc_get(_user, 'device')
            if device_config is not None:
                self._apply_and_collect_device_info(device_config, run_compose=run_compose, stage_config=_obj)
            
            # custom scripts
            custom_config = oc_get(_user, 'custom')
            if custom_config is not None:
                self._resolve_custom_scripts(custom_config, stage_config= _obj)
            
            # storage option, only for stage 2
            storage_config = oc_get(_user, 'storage')
            if storage_config is not None:
                assert ith_stage == 1, 'Storage options are only available for stage 2'
                self._collect_storage_options(storage_config, stage_config=_obj)
                
        return stage_1, stage_2
        
    def _apply_stage_config_to_compose(self, stage_config : StageConfig, stage_compose : DictConfig, base_compose : DictConfig):
        ''' apply the stage configuration to the compose template of that stage
        
        parameters
        --------------
        stage_config: StageConfig
            the stage configuration object
        stage_compose: DictConfig
            the compose template for that stage, whose key is 'services.stage-?', which will be modified in place
        base_compose: DictConfig
            the base compose template, which is the top-level compose template
        '''
        
        # port mapping
        port_strings : list[str] = [f'{host}:{container}' for host, container in stage_config.ports.items()]
        oc.OmegaConf.update(stage_compose, 'ports', port_strings)
        
        # environment variables
        env_strings : list[str] = [f'{k}={v}' for k, v in stage_config.environment.items()]
        oc.OmegaConf.update(stage_compose, 'environment', env_strings)
        
        vol_strings : list[str] = []
        for prefix, storage_opt in stage_config.storage.items():
            if storage_opt == StorageTypes.AutoVolume:
                vol_strings.append(f'{storage_opt}:{storage_opt.soft_path}')
        
    
    def process(self):
        ''' process the config and compose template to generate the compose output
        '''
        # user_cfg = self.m_config
        # compose_cfg = self.m_compose_template.copy()
        
        # read files for test
        fn_template = r'templates/base-image.yml'
        fn_config = r'templates/config-template-full.yml'
        user_cfg = oc.OmegaConf.load(fn_config)
        compose_cfg = oc.OmegaConf.load(fn_template)
        stage_1, stage_2 = self._process_config_and_apply_x_compose(user_cfg, compose_cfg)
        
        # TODO: apply stage config to compose_cfg
        
        # resolve the compose file
        compose_resolved = compose_cfg.copy()
        oc.OmegaConf.resolve(compose_resolved)
        
        # apply stage_1 config
        
        return compose_cfg
    
cfg = PeiConfigProcessor().process()
print(oc.OmegaConf.to_container(cfg))
assert False
        
    
@click.group()
def cli():
    pass
    
# create the output dir and copy the template files there
@click.command()
@click.option('--output-dir', '-o', default=f'./{Defaults.BuildDir}', help='Output directory')
def create(output_dir):
    print('Creating PeiDocker project in', output_dir)
    os.makedirs(output_dir, exist_ok=True)
    
    # copy files using shutil and rename them
    file_from : list[str] = [
        Defaults.ConfigTemplatePath,
    ]
    file_to : str = [
        os.path.join(output_dir, Defaults.OutputConfigName),
    ]
    
    for i in range(len(file_from)):
        shutil.copy(file_from[i], file_to[i])
        logging.info(f'Copied {file_from[i]} to {file_to[i]}')
    logging.info('Done')
        
# generate the docker compose file from the config file
@click.command()
@click.option('--config', '-c', default=f'./{Defaults.BuildDir}/{Defaults.OutputConfigName}', help='Config file')
def configure(config):
    print('Configuring PeiDocker project from', config)
    
    # read the config file
    in_config = oc.OmegaConf.load(config)
    
    # read the compose template file
    in_compose = oc.OmegaConf.load(Defaults.ComposeTemplatePath)
    out_compose = in_compose.copy()
    oc.OmegaConf.resolve(out_compose)
    out_yaml = oc.OmegaConf.to_yaml(out_compose)
    
    # write the compose file to the same directory as config file
    out_compose_path = os.path.join(os.path.dirname(config), Defaults.OutputComposeName)
    logging.info(f'Writing compose file to {out_compose_path}')
    with open(out_compose_path, 'w') as f:
        f.write(out_yaml)
    
    logging.info('Done')
        
cli.add_command(create)
cli.add_command(configure)

if __name__ == '__main__':
    cli()