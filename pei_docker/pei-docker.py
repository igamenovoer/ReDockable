# main command of PeiDocker utility
import omegaconf as oc
from omegaconf import DictConfig
import click
import os
import shutil
from pei_docker.config_processor import *
        
# @click.group()
# def cli():
#     pass
    
# # create the output dir and copy the template files there
# @click.command()
# @click.option('--output-dir', '-o', default=f'./{Defaults.BuildDir}', help='Output directory')
# def create(output_dir):
#     print('Creating PeiDocker project in', output_dir)
#     os.makedirs(output_dir, exist_ok=True)
    
#     # copy files using shutil and rename them
#     file_from : list[str] = [
#         Defaults.ConfigTemplatePath,
#     ]
#     file_to : str = [
#         os.path.join(output_dir, Defaults.OutputConfigName),
#     ]
    
#     for i in range(len(file_from)):
#         shutil.copy(file_from[i], file_to[i])
#         logging.info(f'Copied {file_from[i]} to {file_to[i]}')
#     logging.info('Done')
        
# # generate the docker compose file from the config file
# @click.command()
# @click.option('--config', '-c', default=f'./{Defaults.BuildDir}/{Defaults.OutputConfigName}', help='Config file')
# def configure(config):
#     print('Configuring PeiDocker project from', config)
    
#     # read the config file
#     in_config = oc.OmegaConf.load(config)
    
#     # read the compose template file
#     in_compose = oc.OmegaConf.load(Defaults.ComposeTemplatePath)
#     out_compose = in_compose.copy()
#     oc.OmegaConf.resolve(out_compose)
#     out_yaml = oc.OmegaConf.to_yaml(out_compose)
    
#     # write the compose file to the same directory as config file
#     out_compose_path = os.path.join(os.path.dirname(config), Defaults.OutputComposeName)
#     logging.info(f'Writing compose file to {out_compose_path}')
#     with open(out_compose_path, 'w') as f:
#         f.write(out_yaml)
    
#     logging.info('Done')
        
# cli.add_command(create)
# cli.add_command(configure)

# if __name__ == '__main__':
#     cli()