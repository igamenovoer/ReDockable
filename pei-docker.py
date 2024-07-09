# main command of PeiDocker utility
import omegaconf as oc
from omegaconf import DictConfig
from dataclasses import dataclass, field
import click
import os
import shutil
import logging
from rich import print
logging.basicConfig(level=logging.INFO)

# def get_script_path():
#     return os.path.dirname(os.path.realpath(sys.argv[0]))

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
    
@dataclass
class StorageOption:
    ''' storage options for the container
    '''
    storage_type : str = field(default='auto-volume')
    
    # path to the host directory
    host_path : str | None = field(default=None)
    
    # path to the container directory
    volume_name : str | None = field(default=None)
    
    def __post_init__(self):
        # storage type must be one of the following: auto-volume, manual-volume, host, image
        if self.storage_type not in ['auto-volume', 'manual-volume', 'host', 'image']:
            raise ValueError(f'Invalid storage type {self.storage_type}')

@dataclass
class StageConfig:
    ''' configuration for each stage
    '''
    # image name for the output
    output_image_name : str = field()
    
    # environment variables
    environment : dict[str, str] = field(default_factory=dict)
    
    # port mapping from host to container
    ports : dict[int, int] = field(default_factory=dict)
    
    # run on which device
    device : str | None = field(default=None)
    
    # storage options
    storage : StorageOption | None = field(default=None)
    
    # scripts to run
    on_build_scripts : list[str] = field(default_factory=list)
    on_first_run_scripts : list[str] = field(default_factory=list)
    on_every_run_scripts : list[str] = field(default_factory=list)
    
class PeiConfigProcessor:
    def __init__(self) -> None:
        self.m_config : DictConfig = None
        self.m_compose_template : DictConfig = None
        self.m_compose_output : DictConfig = None
        
        # collect from all stages
        self.m_stage_1 : StageConfig = StageConfig('pei-image:stage-1')
        self.m_stage_2 : StageConfig = StageConfig('pei-image:stage-2')
        
    @classmethod
    def from_config(cls, config : DictConfig, compose_template : DictConfig) -> 'PeiConfigProcessor':
        self = cls()
        self.m_config = config
        self.m_compose_template = compose_template
        return self
    
    def _process_env(self, env_config : DictConfig, stage_config : StageConfig):
        ''' process the env configuration from config
        
        parameters
        -------------
        env_config: DictConfig
            the env section from the user config, path is 'stage-1.environment'
        stage_config: StageConfig
            the stage configuration object to store the environment variables
        '''
        
        oc_get = oc.OmegaConf.select
        
        envs = oc_get(env_config, 'environment')
        
        if envs is None or len(envs) == 0:
            return
        
        # if it is a list, convert it to a dictionary
        # each entry is "xxx=yyy", split by '=' and add to the dictionary
        if isinstance(envs, list):
            envs = {k:v for k, v in [e.split('=') for e in envs]}
            
        # add to the environment variables
        stage_config.environment.update(envs)
    
    def _process_apt(self, apt_config : DictConfig, apt_compose : DictConfig):
        ''' process the apt configuration and update the compose template
        
        parameters
        -------------
        apt_config: DictConfig
            the apt section from the user config, path is 'stage-1.apt'
        apt_compose: DictConfig
            the apt section from the compose template, path is 'x-cfg-stage-?.build.apt'
        '''
        
        oc_get = oc.OmegaConf.select
        oc_set = oc.OmegaConf.update
        
        repo_source = oc_get(apt_config, 'repo_source')
        
        # check if the repo path exists
        _repo_path_host = Defaults.HostInstallationRoot + '/' + repo_source
        if not os.path.exists(_repo_path_host):
            raise FileNotFoundError(f'Repo source path {_repo_path_host} not found')
        
        # set it to the compose template
        _repo_path_container = Defaults.ContainerInstallationRoot + '/' + repo_source
        oc_set(apt_compose, 'source_file', _repo_path_container)
        
        # keep repo after build?
        keep_repo = oc_get(apt_config, 'keep_repo_after_build')
        keep_repo = bool(keep_repo)
        oc_set(apt_compose, 'keep_source_file', keep_repo)
        
        # use proxy?
        use_proxy = oc_get(apt_config, 'use_proxy')
        use_proxy = bool(use_proxy)
        oc_set(apt_compose, 'use_proxy', use_proxy)
        
        # keep proxy after build?
        keep_proxy = oc_get(apt_config, 'keep_proxy_after_build')
        keep_proxy = bool(keep_proxy)
        oc_set(apt_compose, 'keep_proxy', keep_proxy)
    
    def _process_proxy(self, proxy_config : DictConfig, proxy_compose : DictConfig):
        ''' process the proxy configuration and update the compose template
        
        parameters
        -------------
        proxy_config: DictConfig
            the proxy section from the user config, path is 'stage-1.proxy'
        proxy_compose: DictConfig
            the proxy section from the compose template, path is 'x-cfg-stage-?.build.proxy'
        '''
        
        oc_get = oc.OmegaConf.select
        oc_set = oc.OmegaConf.update
        
        adr = oc_get(proxy_config, 'address')
        oc_set(proxy_compose, 'address', adr)
        
        port = oc_get(proxy_config, 'port')
        oc_set(proxy_compose, 'port', port)
    
    def _process_ssh(self, ssh_config : DictConfig, ssh_compose : DictConfig, stage_config : StageConfig):
        ''' process the ssh configuration and update the compose template
        
        parameters
        -------------
        ssh_config: DictConfig
            the ssh section from the user config, path is 'stage-1.ssh'
        ssh_compose: DictConfig
            the ssh section from the compose template, path is 'x-cfg-stage-?.build.ssh'
        stage_config: StageConfig
            the stage configuration object, to store the port mapping
            
        '''
        
        oc_get = oc.OmegaConf.select
        oc_set = oc.OmegaConf.update
        
        # set ssh
        enable_ssh = oc_get(ssh_config, 'enable')
        if enable_ssh:
            # in-container port
            ssh_port = oc_get(ssh_config, 'port')
            oc_set(ssh_compose, 'port', ssh_port)
            
            # host port
            host_ssh_port = oc_get(ssh_config, 'host_port')
            stage_config.ports[host_ssh_port] = ssh_port
            
            # users
            ssh_users = oc_get(ssh_config, 'users')
            _ssh_names : list[str] = []
            _ssh_pwds : list[str] = []
            _ssh_pubkeys : list[str] = []
            for name, info in ssh_users.items():
                _ssh_names.append(name)
                
                pw = oc_get(info, 'password')
                if pw is None:
                    _ssh_pwds.append('')
                else:
                    _ssh_pwds.append(str(pw))   # convert to string, in case it's a number
                    
                pubkey_file = oc_get(info, 'pubkey_file')
                if pubkey_file is None:
                    _ssh_pubkeys.append('')
                else:
                    _ssh_pubkeys.append(str(pubkey_file))
                    
            # set config
            oc_set(ssh_compose, 'username', ','.join(_ssh_names))
            oc_set(ssh_compose, 'password', ','.join(_ssh_pwds))
            oc_set(ssh_compose, 'pubkey_file', ','.join(_ssh_pubkeys))
                    
    def _process_port_mapping(self, port_mapping : list[str], stage_config : StageConfig):
        ''' process the port mapping configuration and update the compose template
        
        parameters
        -------------
        port_mapping: list[str]
            the port mapping section from the user config, path is 'stage-1.ports',
            following docker compose format, host:container, e.g. ['8080:80', '8081:81']
        stage_config: StageConfig
            the stage configuration object, to store the port mapping
        '''
        
        oc_get = oc.OmegaConf.select
        oc_set = oc.OmegaConf.update
        
        if port_mapping is None or len(port_mapping) == 0:
            return
        
        for host_port, container_port in [e.split(':') for e in port_mapping]:
            stage_config.ports[int(host_port)] = int(container_port)
        
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
        
        oc_get = oc.OmegaConf.select
        oc_set = oc.OmegaConf.update
        oc_asdict = oc.OmegaConf.to_container
        
        # stage-1
        # set image name
        s1_output_image_name : str = oc_get(user_cfg, 'stage-1.image.output')
        oc_set(compose_cfg, 'x-cfg-stage-1.build.output_image_name', s1_output_image_name)
        
        # ssh
        ssh_config = oc_get(user_cfg, 'stage-1.ssh')
        ssh_compose = oc_get(compose_cfg, 'x-cfg-stage-1.build.ssh')
        if ssh_config is not None:
            self._process_ssh(ssh_config, ssh_compose, self.m_stage_1)
        
        # proxy
        proxy_config = oc_get(user_cfg, 'stage-1.proxy')
        proxy_compose = oc_get(compose_cfg, 'x-cfg-stage-1.build.proxy')
        if proxy_config is not None:
            self._process_proxy(proxy_config, proxy_compose)
        
        # environment
        env_config = oc_get(user_cfg, 'stage-1.environment')
        if env_config is not None:
            self._process_env(env_config, self.m_stage_1)
            
        # additional port mapping
        port_mapping = oc_get(user_cfg, 'stage-1.ports')
        if port_mapping is not None:
            self._process_port_mapping(port_mapping, self.m_stage_1)
            
        # device
        device = oc_get(user_cfg, 'stage-1.device.type')
        self.m_stage_1.device = device
        
        # TODO: here we need to process the storage options
        
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