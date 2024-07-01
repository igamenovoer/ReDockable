import omegaconf as oc
import yaml
from attrs import define, field
import attrs.validators as av

class ComposeGenerator:
    def __init__(self):
        self.m_config = oc.OmegaConf.create()
        pass

    def generate(self):
        return yaml.dump(self.config)