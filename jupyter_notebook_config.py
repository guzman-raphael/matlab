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

c.NotebookApp.default_url = '/tree'

c.NotebookApp.notebook_dir = '.'

c.FileContentsManager.root_dir = getenv('HOME', '/home/muser')
