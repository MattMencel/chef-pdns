#
# Cookbook Name:: pdns
# Resources:: recursor_install
#
# Copyright 2016, Aetrion, LLC DBA DNSimple
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

resource_name :pdns_recursor_install

provides :recursor_install, platform: 'ubuntu'

property :instance_name, String, name_property: true
property :version, [String, nil], default: nil

action :install do
  apt_repository 'powerdns-recursor' do
    uri 'http://repo.powerdns.com/ubuntu'
    distribution 'trusty-rec-40'
    arch 'amd64'
    components ['main']
    key 'https://repo.powerdns.com/FD380FBB-pub.asc'
  end

  apt_preference 'pdns-*' do
    pin          'origin repo.powerdns.com'
    pin_priority '600'
  end

  package 'pdns-recursor' do
    version new_resource.version
  end
end
