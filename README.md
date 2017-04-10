# PowerDNS Community Cookbook

Provides resources for installing and configuring both PowerDNS authoritative and recursor. It uses the official PowerDNS repositories for packages and installs the appropiate configuration for your platform's init system.

## Requirements

IMPORTANT: Please read the Compatibility Notes version below since there is breaking changes between 2 and 3 versions of this cookbook.

### Compatibility Notes

**This cookbook is being completely rewritten, transitioning from an attribute centric design to a newer resource based design. 

TLDR: 

BREAKING CHANGES, Please pin your PowerDNS installs pin your cookbook to the latest 2.5.0 version. We also advise to read this document carefully.
**


The current version of the cookbook provides basic support for recursors and authoritative servers with a handful of platforms, backends and init systems supported. You can find what is supported in this table:


| Platform | Backends         | Init Systems |
|----------|------------------|--------------|
| Debian   | bind, postgresql | SysVinit     |
| CentOS   | bind, postgresql | SysVinit     |

### Platforms:

* Ubuntu (14.04)
* CentOS (6.8)

### Chef:

- Chef 12.5+

### Init Systems:

Only SysVinit is supported for now, Systemd is next, and along it other platforms such us Debian 8, Ubuntu 16.04 and CentOS 7.2 will be available.

### Required Cookbooks:

* apt
* yum

### Suggested Cookbooks:

* postgres (for the PostgreSQL backend)

## Usage

Combine the different resources in order to install, configure and manage your PowerDNS instances. This is a list of resouces that can be used:

  | Resource                            | Functionality                                     |
  |-------------------------------------|---------------------------------------------------|
  | pdns_authoritative_install          | Installs an authoritative server                  |
  | pdns_authoritative_config           | Configures an authoritative instance              |
  | pdns_authoritative_service          | Manages an authoritative instance                 |
  | pdns_authoritative_backend          | Installs authoritative backend                    |
  | pdns_recursor_install               | Installs a recusor                                |
  | pdns_recursor_config                | Configures a recursor instance                    |
  | pdns_recursor_service               | Manages a a recursor instance                     | 

To fully configure an authoritative server you need to add at least 3 resources to your run list, `pdns_authoritative_install`, `pdns_authoritative_config` and `pdns_authoritative_service`. If you want to install any backend than the default (bind) for the authoritative server you need to add a fourth resource: `pdns_authoritative_backend`. There is a some good usage examples on `test/cookbooks/pdns_test/recipes/`.

For a recursor use the `pdns_recursor_install`, `pdns_recursor_config`, and `pdns_recursor_service` resources in your wrapper cookbooks to install, configure, and define PowerDNS recursors. Set the different properties on the resources according to your install and configuration needs. You can see a good example on this on `test/cookbooks/pdns_test/recipes_recursor_install_single.rb`

For advanced use it is recommended to take a look at the chef resources themselves.

### Properties

PowerDNS uses hyphens `-` in their configuration files, chef resources and ruby symbols don't get very well with hyphens, so using underscore `_` in this cookbook for properties is required and will be tranlated automatically to hyphens in the configuration templates, example:

```
pdns_authoritative_config 'server-01' do
  action :create
  launch ['gpgsql']
  variables(
    gpgsql_host: '127.0.0.1',
    gpgsql_user: 'pdns',
    gpgsql_port: 5432,
    gpgsql_dbname: 'pdns',
    gpgsql_password: 'wadus'
    )
end
```

Will become in `/etc/powerdns/pdns-authoritative-server-01.conf`: 

```
launch ['gpgsql']
gpgsql-host=127.0.0.1
gpgsql-user=pdns
gpgsql-port=5432
gpgsql-dbname=pdns
gpgsql-password=wadus
```

Most properties are simple ruby strings, but there is another cases that need attention.
Properties specified as elements in arrays will be splitted up (see split ruby method) and separated by commas.
Boolean properties will be always translated to 'yes' or 'no'.
Some properties need to set consistently accross resources, they will be noted in their specific sections. 
Most of the properties are optional and have sane defaults, so they are only recommended for customized installs.

### pdns_authoritative_install

Installs PowerDNS authoritative server 4.X series using PowerDNS official repository in the supported platforms.

#### Properties

| Name          | Class       |  Default value | Consistent?|
|---------------|-------------|----------------|------------|
| instance_name | String      | name_property  | Yes|
| version       | String, nil | nil            | No |
| debug         | true, false | false          | No |

#### Usage example

Install a PowerDNS authoritative server package named `server-01` with the latest version available in the repository.

```
pdns_authoritative_install 'server-01' do
  action :install
end
```

### pdns_authoritative_config

Creates a PowerDNS recursor configuration, there is a fixed set of required properties (listed below) but most of the configuration is left to the user freely, every property set in the `variables` hash property will be rendered in the config template. Remember that using underscores `_` for property names is required and it's translated to hyphens `-` in configuration templates.

#### Properties

| Name           | Class      |  Default value  | Consistent? |
|----------------|------------|-----------------|-------------|
| instance_name  | String     | name_property   | Yes         |
| launch         | Array, nil | ['bind']        | No          |
| config_dir     | String     | see `default_authoritative_config_directory` helper method | Yes |
| socket_dir     | String     | "/var/run/#{resource.instance_name}" | Yes | 
| run_group      | String     | see `default_authoritative_run_user` helper method  | No |
| run_user       | String     | see `default_authoritative_run_user` helper method  | No |
| run_user_home  | String     | see `default_user_attributes` helper method | No |
| run_user_shell | String     | see `default_user_attributes` helper method | No |
| setuid         | String     | resource.run_user | No |
| setgid         | String     | resource.run_group | No |
| source         | String,nil | 'authoritative_service.conf.erb' | No |
| cookbook       | String,nil | 'pdns' | No |
| variables      | Hash]      | { bind_config:  "#{resource.config_dir}/bindbackend.conf" } | No |

#### Usage Example

Create a PowerDNS authoritative configuration file named `server-01`:

```
pdns_authoritative_config 'server-01' do
  action :create
  launch ['gpgsql']
  variables(
    gpgsql_host: '127.0.0.1',
    gpgsql_user: 'pdns',
    gpgsql_port: 5432,
    gpgsql_dbname: 'pdns',
    gpgsql_password: 'wadus',
    allow_axfr_ips: [ '127.0.0.0/8', '::1', '195.234.23,34'],
    api: true,
    api-_eadonly: true
    )
end
```

### pdns_authoritative_service

Creates a init service to manage a PowerDNS authoritative instance. This service supports all the regular actions (start, stop, restart, etc.). Check the compatibility section to see which init services are supported.

#### Properties

| Name           | Class       |  Default value                                        | Consistent? |
|----------------|-------------|-------------------------------------------------------|-------------|
| instance_name  | String      | name_property                                         | Yes |
| cookbook       | String, nil | 'pdns'                                                | No |
| source         | String, nil | 'authoritative.init.debian.erb'                       | No |
| config_dir | String     | see `default_authoritative_config_directory` helper method | Yes |
| socket_dir | String     | lazy { |resource| "/var/run/#{resource.instance_name}" }   | Yes |

#### Usage example

```
pdns_authoritative_service 'server-01' do
  action [:enable, :start]
end
```

### pdns_authoritative_backend

Installs one backend package for the PowerDNS authoritative server. You'll still need to install and configure the backend itself in your wrapper cookbook.

#### Properties

| Name           | Class      |  Default value  | Consistent? |
|----------------|------------|-----------------|-------------|
| instance_name  | String     | name_property   | No |
| version        | String, nil| nil             | No |

#### Usage Example

Install a PostgreSQL backend for the PowerDNS authoritative server:

```
pdns_authoritative_backend 'postgresql' do
  action :install
end
```

### pdns_recursor_install

Installs PowerDNS recursor 4.X series using PowerDNS official repository in the supported platforms.

#### Properties

| Name           | Class       |  Default value  | Consistent? |
|----------------|-------------|-----------------|-------------|
| version        | String      | name_property   | Yes         |
| debug          | True, False | String, nil     | No          |

#### Usage Example

Install a 4. powerdns instance named 'my-recursor' on ubuntu 14.04:

    pdns_recursor_install 'my-recursor' do
      version '4.0.4-1pdns.trusty'
    end

### pdns_recursor_service

Sets up a PowerDNS recursor instance using the appropiate init system (SysV Init for now).

#### Properties

| Name           | Class      |  Default value                                        | Consistent? |
|----------------|------------|-------------------------------------------------------|-------------|
| instance_name  | String     | name_property                                         | Yes         |  
| cookbook       | String,nil | 'pdns'                                                | No          |
| source         | String,nil | 'recursor.init.debian.erb'                            | No          |
| config_dir     | String     | see `default_recursor_config_directory` helper method | Yes         |
| socket_dir     | String     | "/var/run/#{resource.instance_name}"                  | Yes         |
| instances_dir  | String     | 'recursor.d'                                          | Yes         |

- `cookbook` (C): Cookbook for a custom configuration template.
- `source` (C): Name of the recursor custom template.
- `config_dir` (C): Path of the recursor configuration directory.
- `instances_dir` (C): Directory under the recursor config path that holds recursor instances.
- `socket_dir`: Directory where sockets are created.

#### Usage Example

Configure a PowerDNS recursor service instance named 'my-recursor' in your wrapper cookbook for Acme Corp with a custom template named `my-recursor.erb`

    pdns_recursor_service 'my-recursor' do
      source 'my-recursor.erb'
      cookbook 'acme-pdns-recursor'
    end

### pdns_recursor_config

Creates a PowerDNS recursor configuration.

#### Properties

|           | Name           | Class       |  Default value                                         | Consistent? |
|----------------|-------------|--------------------------------------------------------|-------------|
| instance_name  | String      | name_property                                          | Yes         | 
| config_dir     | String      | see `default_recursor_config_directory` helper method  | Yes         |
| socket_dir     | String      | /var/run/#{resource.instance_name}                     | Yes         |
| run_group      | String      | see `default_recursor_run_user` helper method          | No          |
| run_user       | String      | see `default_recursor_run_user` helper method          | No          | 
| run_user_home  | String      | see `default_user_attributes` helper method            | No          |
| run_user_shell | String      | see `default_user_attributes` helper method            | No          |
| setuid         | String      | resource.run_user                                      | No          |
| setgid         | String      | resource.run_group                                     | No          | 
| instances_dir  | String, nil | 'recursor.d'                                           | Yes         |
| source         | String, nil | 'recursor_service.conf.erb'                            | No          |
| cookbook       | String, nil | 'pdns'                                                 | No          |
| variables      | Hash        | {}                                                     | No          |

#### Usage Example

Create a PowerDNS recursor configuration named 'my-recursor' in your wrapper cookbook for Acme Corp which uses a custom template named `my-recursor.erb` and a few attributes:

    pdns_recursor_config 'my-recursor' do
      source 'my-recursor.erb'
      cookbook 'acme-pdns-recursor'
      variables(client-tcp-timeout: '20', loglevel: '5', network-timeout: '2000')
    end

## Contributing

We are happy to accept contributions to this cookbook in form of bug fixes, new backends, init services, or platform support. We believe that barriers to contributing to this cookbook has been lowered since the release of the 3.0, resource based version. Please use the normal PR workflow for contributing. We will favour PRs with tests for the changes, we use both Chefspec and Inspec testing framewowrks.

License & Authors
-----------------
- Author:: Aaron Kalin (<aaron.kalin@dnsimple.com>)
- Author:: Jacobo García (<jacobo.garcia@dnsimple.com>)
- Author:: Anthony Eden (<anthony.eden@dnsimple.com>)

```text
Copyright:: 2010-2014, Chef Software, Inc & 2014-2016 Aetrion, LLC.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
