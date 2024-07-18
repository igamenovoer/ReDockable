# generate example configs for PeiDocker
import omegaconf as oc
from pei_docker.user_config import *
from pei_docker.config_processor import *

fn_config_template = Defaults.ConfigTemplatePath

def gen_minimal_image_with_ssh():
    ''' generate a minimal ubuntu image
    '''
    pass