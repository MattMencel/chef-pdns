#
# Cookbook Name:: pdns
# Attributes:: default
#
# Copyright 2014, Aetrion, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['pdns']['build_method'] = 'package'

default['pdns']['user'] = 'pdns'
default['pdns']['group'] = 'pdns'

default['pdns']['authoritative']['source']['url'] = 'https://downloads.powerdns.com/releases/pdns-3.4.1.tar.bz2'
default['pdns']['authoritative']['source']['path'] = '/opt'
default['pdns']['authoritative']['source']['backends'] = %w( pipe gpgsql gmysql )
default['pdns']['authoritative']['source']['config_dir'] = node['pdns']['authoritative']['config_dir']

# The backend to launch with the authoritative server
default['pdns']['authoritative']['launch'] = 'gpgsql'
