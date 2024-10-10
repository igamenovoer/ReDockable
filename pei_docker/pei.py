# main command of PeiDocker utility
import logging

# configure logging
logging.basicConfig(level=logging.INFO, format='[%(levelname)s]\t%(message)s')

import click
import os
import shutil

import omegaconf as oc
from pei_docker.config_processor import *
        
@click.group()
def cli():
    pass
    
# create the output dir and copy the template files there
@click.command()
@click.option('--project-dir', '-p', help='project directory', required=True, 
              type=click.Path(exists=False, file_okay=False))
@click.option('--with-examples', '-e', is_flag=True, default=False, 
              help='copy example files to the project dir')
@click.option('--with-contrib', is_flag=True, default=False, help='copy contrib directory to the project dir')
def create(project_dir : str, with_examples : bool, with_contrib : bool):
    logging.info(f'Creating PeiDocker project in {project_dir}')
    os.makedirs(project_dir, exist_ok=True)
    
    # the directory should be empty
    # if len(os.listdir(project_dir)) > 0:
    #     logging.error(f'Directory {project_dir} is not empty')
    #     return
    
    # copy all the files and folders in project_files to the output dir
    this_dir : str = os.path.dirname(os.path.realpath(__file__))
    project_template_dir = f'{this_dir}/project_files'    
    for item in os.listdir(project_template_dir):
        s = os.path.join(project_template_dir, item)
        d = os.path.join(project_dir, item)
        if os.path.isdir(s):
            logging.info(f'Copying directory {s} to {d}')
            shutil.copytree(s, d, dirs_exist_ok=True)
        else:
            logging.info(f'Copying file {s} to {d}')
            shutil.copy2(s, d)
            
    # copy config and compose template files to the output dir
    src_config_template : str = f'{this_dir}/{Defaults.ConfigTemplatePath}'
    dst_config_template : str = f'{project_dir}/{Defaults.OutputConfigName}'
    logging.info(f'Copying config template {src_config_template} to {dst_config_template}')
    shutil.copy2(src_config_template, dst_config_template)
    
    src_compose_template : str = f'{this_dir}/{Defaults.ComposeTemplatePath}'
    dst_compose_template : str = f'{project_dir}/{Defaults.OutputComposeTemplateName}'
    logging.info(f'Copying compose template {src_compose_template} to {dst_compose_template}')
    shutil.copy2(src_compose_template, dst_compose_template)
    
    # copy example files to the project dir
    # the examples is in Defaults.ConfigExamplesDir
    if with_examples:
        examples_dir : str = f'{this_dir}/{Defaults.ConfigExamplesDir}'
        
        # copy this dir to project_dir/examples
        examples_dst_dir : str = f'{project_dir}/examples'
        logging.info(f'Copying examples from {examples_dir} to {examples_dst_dir}')
        shutil.copytree(examples_dir, examples_dst_dir, dirs_exist_ok=True)
        
    if with_contrib:
        contribs_dir : str = f'{this_dir}/{Defaults.ContribDir}'
        
        # copy this dir to project_dir/contrib
        contribs_dst_dir : str = f'{project_dir}/contrib'
        logging.info(f'Copying contribs from {contribs_dir} to {contribs_dst_dir}')
        shutil.copytree(contribs_dir, contribs_dst_dir, dirs_exist_ok=True)
        
    logging.info('Done')
        
# generate the docker compose file from the config file
@click.command()
@click.option('--project-dir', '-p', help='project directory', required=True, 
              type=click.Path(exists=False, file_okay=False))
@click.option('--config', '-c', default=f'{Defaults.OutputConfigName}', help='config file name, relative to the project dir', 
              type=click.Path(exists=False, file_okay=True, dir_okay=False))
@click.option('--full-compose', '-f', is_flag=True, default=False, help='generate full compose file with x-??? sections')
def configure(project_dir:str, config:str, full_compose:bool):
    logging.info(f'Configuring PeiDocker project from {project_dir}/{config}')
    
    import os
    # is config file a relative path?
    # if yes, then append to project dir
    # if no, then use as is
    if not os.path.isabs(config) or config == Defaults.OutputConfigName:
        config_path = os.path.join(project_dir, config)
    else:
        config_path = config

    
    # file exists?
    if not os.path.exists(config_path):
        logging.error(f'Config file {config_path} does not exist')
        return
    
    in_config = oc.OmegaConf.load(config_path)
    
    # read the compose template file
    compose_path : str = os.path.join(project_dir, Defaults.OutputComposeTemplateName)
    in_compose = oc.OmegaConf.load(compose_path)
    
    # process the config file
    proc : PeiConfigProcessor = PeiConfigProcessor.from_config(in_config, in_compose, project_dir=project_dir)
    out_compose = proc.process(remove_extra=not full_compose)
    out_yaml = oc.OmegaConf.to_yaml(out_compose)
    
    # write the compose file to the same directory as config file
    out_compose_path = os.path.join(project_dir, Defaults.OutputComposeName)
    logging.info(f'Writing compose file to {out_compose_path}')
    with open(out_compose_path, 'w') as f:
        f.write(out_yaml)
    
    logging.info('Done')
        
cli.add_command(create)
cli.add_command(configure)

if __name__ == '__main__':
    # Run the command line interface
    cli()