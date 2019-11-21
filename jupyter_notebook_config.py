# Configuration file for ipython-notebook.
from os import getenv
from IPython.lib import passwd

c = get_config()


#------------------------------------------------------------------------------
# NotebookApp configuration
#------------------------------------------------------------------------------

# NotebookApp will inherit config from: BaseIPythonApplication, Application

# The IPython password to use i.e. "datajoint".
c.NotebookApp.password = passwd(getenv('JUPYTER_PASSWORD', 'datajoint')).encode("ascii")

# Allow root access.
c.NotebookApp.allow_root = True

# The IP to serve on.
c.NotebookApp.ip = u'0.0.0.0'

# The Port to serve on.
c.NotebookApp.port = 8888

# Landing entrypoint to Jupyter Notebook.
c.NotebookApp.default_url = '/tree'

# Utilize container WORKDIR as current directory on launched notebooks.
# Minor bug in Jupyter Notebook (jupyter/notebook#5072)
c.NotebookApp.notebook_dir = '.'

# Utilize USER home as root for notebook UI navigation.
c.FileContentsManager.root_dir = getenv('HOME', '/home/muser')
