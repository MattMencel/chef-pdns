# pdns Cookbook
Installs and configures PowerDNS (pdns). Sets up a recursor by default and can set up an Authoritative Server with multiple backends.

## Requirements

### Platforms:

* Ubuntu (12.04, 14.04)

### Required Cookbooks:

* build-essential (for source build)
* resolvconf (used in the server recipe for setting resolv.conf)

### Suggested Cookbooks:

* mysql (for the MySQL backend)
* sqlite (for the SQLite backend)
* postgres (for the PostgreSQL backend)

## Attributes

Depending on the type of server you are installing there are specific options you may want to set via attributes. Each
attribute file (other than default) corresponds to the type of PowerDNS server you are installing. This can be either
a PowerDNS recursor, or an authoritative DNS name server. The default attributes apply to both types of installations.

### default

Key                            | Type     | Description                                 | Default
-------------------------------| ---------|---------------------------------------------|---------
`node['pdns']['user']`         | String   | User to setuid the pdns daemons             | pdns
`node['pdns']['group']`        | String   | Group to setuid the pdns daemons            | pdns
`node['pdns']['build_method']` | String   | Type of installation, 'package' or 'source' | package

### authoritative

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['pdns']['authoritative']['config_dir']</tt></td>
    <td>String</td>
    <td>Path to the config directory</td>
    <td><tt>/etc/powerdns</tt></td>
  </tr>
  <tr>
    <td><tt>['pdns']['authoritative']['source']['url']</tt></td>
    <td>String</td>
    <td>URL to the PowerDNS Authoritative DNS Server Source Package</td>
    <td><tt>https://downloads.powerdns.com/releases/pdns-3.4.1.tar.bz2</tt></td>
  </tr>
  <tr>
    <td><tt>['pdns']['authoritative']['source']['path']</tt></td>
    <td>String</td>
    <td>The base path to setting up the source installation</td>
    <td><tt>/opt</tt></td>
  </tr>
  <tr>
    <td><tt>['pdns']['authoritative']['source']['backends']</tt></td>
    <td>Array</td>
    <td>List of backends to build and configure with PowerDNS</td>
    <td><tt>['pipe']</tt></td>
  </tr>
  <tr>
    <td><tt>['pdns']['authoritative']['package']['backends']</tt></td>
    <td>Array</td>
    <td>List of backends to setup and configure with PowerDNS</td>
    <td><tt>['pipe']</tt></td>
  </tr>
</table>

#### authoritative server configuration

The `['pdns']['authoritative']['config']` array directly maps to each
configuration directive in the configuration file. Of special note is
any configuration option that needs a hyphen (`-`) should be defined
as an underscore (`_`) and it will be converted at compilation time.

For example, if you want the version-string setting to be changed, you'll want
to define it like so:

`default['pdns']['authoritative']['config']['version_string'] = 'awesomedns'`

Another thing to note is boolean values are mapped to 'yes' and 'no'
respectively. If you want to remove a value, simply set it to 'nil' or do not
define the attribute entirely.

### recursor

Key                            | Type     | Description                                 | Default
-------------------------------| ---------|---------------------------------------------|---------
`node['pdns']['user']`         | String   | User to setuid the pdns daemons             | pdns
`node['pdns']['group']`        | String   | Group to setuid the pdns daemons            | pdns
`node['pdns']['build_method']` | String   | Type of installation, 'package' or 'source' | package

- `node["pdns"]["recursor"]["allow_from"]` - Array list of netmasks to recurse, corresponds to recursor.conf value `allow-from`, default ["127.0.0.0/8", "0.0.0.0/8", "92.168.0.0/16", "72.16.0.0/12", ":1/128", "e80::/10"].
- `node["pdns"]["recursor"]["auth_zones"]` - Array list of 'zonename=filename' pairs served authoritatively, corresponds to recursor.conf value `auth-zones`, default [].
- `node["pdns"]["recursor"]["forward_zones"]` - Array list of 'zonename=IP' pairs. Queries for the zone are forwarded to the specified IP, corresponds to recursor.conf value `forward-zones`, default [].
- `node["pdns"]["recursor"]["forward_zones_recurse"]` - Array list of 'zonename=IP' pairs. Like `forward_zones` above, sets the `recursion_desired` bit to 1, corresponds to recursor.conf value `forward-zones-recurse`, default [].
- `node["pdns"]["recursor"]["local_address"]` - Array list of the local IPv4 or IPv6 addresses to bind to, corresponds to the recursor.conf value `local-address` default [ipaddress] under the assumption that the recursor is used with an Authoritative Server on the same system.
- `node["pdns"]["recursor"]["local_port"]` - Local port to bind, default '53'.

## Recipes

### authoritative

Sets up a PowerDNS Authoritative Server. Uses the pipe backend by default.

### authoritative_source

Sets up a PowerDNS Authoritative Server from source. This is automatically selected
based upon the `node['pdns']['build_method']` attribute.

### authoritative_package

Sets up a PowerDNS Authoritative Server from packages. This is automatically selected
based upon the `node['pdns']['build_method']` attribute. It is also the default install
method.

### recursor

Sets up a PowerDNS Recursor from packages.

## Usage

To set up a Recursor, simply put `recipe[pdns::recursor]` in the run list. Modify the attributes via a role or on the node directly as required for the local configuration. If using the recursor with an Authoritative Server running on the same system, the local address and port should be changed to a public IP and the forward zones recurse setting to point at the loopback for the local zone. This is generally assumed, and the default listen interface for the recursor is set to the nodes ipaddress attribute.

To set up an authoritative server, put `recipe[pdns::authoritative]` in the run list. If another backend besides SQLite is desired, change the `node["pdns"]["server"]["backend"]` attribute.

License & Authors
-----------------
- Author:: Joshua Timberman (<joshua@opscode.com>)
- Author:: Aaron Kalin (<aaron.kalin@dnsimple.com>)
- Author:: Jacobo García (<jacobo.garcia@dnsimple.com>)
- Author:: Anthony Eden (<anthony.eden@dnsimple.com>)

```text
Copyright:: 2010-2014, Opscode, Inc & 2014 Aetrion, LLC.

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
