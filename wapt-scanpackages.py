#!/opt/wapt/bin/python
# -*- coding: utf-8 -*-
# -----------------------------------------------------------------------
#    This file is part of WAPT
#    Copyright (C) 2013  Tranquil IT Systems http://www.tranquil.it
#    WAPT aims to help Windows systems administrators to deploy
#    setup and update applications on users PC.
#
#    WAPT is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    WAPT is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with WAPT.  If not, see <http://www.gnu.org/licenses/>.
#
# -----------------------------------------------------------------------
from __future__ import absolute_import
import os
import sys

try:
    wapt_root_dir = os.path.abspath(os.path.dirname(os.path.realpath(__file__)))
except:
    wapt_root_dir = 'c:/tranquilit/wapt'

from waptutils import __version__,setloglevel
from waptpackage import update_packages,WaptLocalRepo
from waptserver.model import *
import waptserver.config

from optparse import OptionParser
import logging

logger = logging.getLogger()

__doc__ = """\
%prog <wapt_directory>

Build a "Packages" file from all wapt file in the specified directory
"""

def update_packages_table(conf,wapt_path):
    load_db_config(conf)
    repo = WaptLocalRepo(wapt_path)
    return Packages.update_from_repo(repo)


def main():
    parser=OptionParser(usage=__doc__)
    parser.add_option("-f","--force",    dest="force",    default=False, action='store_true', help="Force (default: %default)")
    parser.add_option("-r","--canonical-filenames", dest="canonical_filenames",  default=False, action='store_true', help="Rename package filenames to comply with latest canonical naming (default: %default)")
    parser.add_option("-l","--loglevel", dest="loglevel", default=None, type='choice',  choices=['debug','warning','info','error','critical'], metavar='LOGLEVEL',help="Loglevel (default: warning)")
    parser.add_option("-p","--proxy",    dest="proxy",    default=None, help="http proxy (default: %default)")
    parser.add_option("-b","--update-db",    dest="update_db",   default=False, action='store_true', help="Update the Packages database table (default: %default)")
    parser.add_option(
        '-c',
        '--config',
        dest='configfile',
        default=waptserver.config.DEFAULT_CONFIG_FILE,
        help='Config file full path (default: %default)')
    (options,args) = parser.parse_args()

    conf = waptserver.config.load_config(options.configfile)

    loglevel = options.loglevel

    if len(logger.handlers) < 1:
        hdlr = logging.StreamHandler(sys.stderr)
        hdlr.setFormatter(logging.Formatter(
            u'%(asctime)s %(levelname)s %(message)s'))
        logger.addHandler(hdlr)

    if loglevel:
        setloglevel(logger,loglevel)
    else:
        setloglevel(logger,'warning')

    if args:
        wapt_path = args[0]
    else:
        wapt_path = conf['wapt_folder']

    if os.path.exists(wapt_path)==False:
        logger.error("Directory does not exist: %s", wapt_path)
        sys.exit(1)
    if os.path.isdir(wapt_path)==False:
        logger.error("%s is not a directory", wapt_path)
        sys.exit(1)


    res = update_packages(wapt_path,force = options.force,
        proxies = {'http':options.proxy,'https':options.proxy},
        canonical_filenames=options.canonical_filenames)

    if res and os.name == 'posix':
        logger.info('Set Packages file ownership to wapt')
        import pwd
        pwd_entry = pwd.getpwnam('wapt')
        uid, gid = pwd_entry.pw_uid, pwd_entry.pw_gid
        os.chown(res['packages_filename'], uid, gid) # pylint: disable=no-member

    if options.update_db:
        logger.info('Updating the Packages database table from local repo packages index')
        res = len(update_packages_table(conf,wapt_path))
        logger.info('Database records updated: %s' % res)

if __name__ == "__main__":
    main()
