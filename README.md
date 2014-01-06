getrbenv-installer
==================

Install rbenv including plugins and various Ruby versions.
Set local Ruby versions for different directories as well as the global version. All in one command.

This is the script behind getrbenv.com.

##Why you might want to use this installer

Normally a Ruby installation on a server means that it's a system wide installation. So all your scripts run on the same
Ruby version. Not so cool if you have some older and some newer scripts that need different Ruby versions to work
properly. Usually in the Ruby world this applies to different Rails projects that run on one server. For a Rails 3 app
you might want to use an older 1.8 version of Ruby whilst your brand new Rails 4 app is recommended to use Ruby > 2.0.

Therefore @sstephenson developed rbenv so you are able to choose between different Ruby versions for your applications
that run side by side on one system. Even in production environments.

In order to get rbenv working on your system some installation steps are necessary. Some of them include making changes
to your shell's config files. Afterwards rbenv supplies a variety of commands to configure your system.

This installer (and the corresponding configurator at http://getrbenv.com) shall provide a solution to configure your
whole system whithin one single shell command. The installer will perform all actions that are needed to get your
system fully configurated.

##Usage

1. Use the web based configurator at http://www.getrbenv.com to generate the shell command with all needed options OR
2. Use it standalone as a bash script and decide on your own what options you want to set.

The installer is provided as a bash script. It accepts a variety of options in order to install rubies, make version
bindings to different directories and much more.

###Prerequisites

You will need the following tools installed on your system. Keep in mind that you will need to execute a shell script.
Therefore you need shell access to the machine via SSH.

Needed tools
* git (in order to clone the repositories)
* make (otherwise you can't build the ruby versions)
* curl (in case you don't want to copy the script onto your machine)
* bash (the installer is written as a bash script)

If you don't know if these tools are installed or you want to do so, check your distributions package manager.

~~~ sh
$ sudo apt-get install -y curl git make
~~~

This will install all needed prerequisites on Ubuntu Linux. You need sudo rights for this.

The installer will clone some git repositories to your system. By default this will be done inside your users
home directory. If you prefer to install rbenv to some other folder please make sure that this folder is user writable.
The same requirement applies to directories where you want to use a specific ruby version.

###Options

####Installation directory `--install-dir`

Installs rbenv to a directory other than your users home directory `~/`

Example: `--install-dir /path/to/directory` installs rbenv to `/path/to/directory/.rbenv`

####Ruby versions `--rubies`

Defines the Ruby versions that will be installed using the `ruby-build` plugin. You can define one or more Ruby
version separated by a comma.

Examples:

`--rubies 1.9.3-p484` installs version 1.9.3-p484

`--rubies 1.9.3-p484,2.1.0` installs versions 1.9.3-p484 and 2.1.0

For a comprehensive list of supported rubies visit the [ruby-build repository](https://github.com/sstephenson/ruby-build/tree/master/share/ruby-build)

####rbenv plugins `--plugins`

Sets the list of plugins that will be automatically installed. You can define one or more plugins separated by a comma.
Each plugin is identified by its github id <user>/<repository>

Examples:

`--plugins sstephenson/rbenv-vars` installs the rbenv-vars plugin.

`--plugins sstephenson/rbenv-vars,rkh/rbenv-update` installs the rbenv-vars and rbenv-update plugin.

Currently supported plugins:

* [ruby-build](https://github.com/sstephenson/ruby-build) - compile and **install Ruby**
* [vars](https://github.com/sstephenson/rbenv-vars) - safely sets global and
  per-project **environment variables**
* [each](https://github.com/chriseppstein/rbenv-each) - execute the same command
  **with each** installed Ruby
* [update](https://github.com/rkh/rbenv-update) - **update rbenv** and installed
  plugins
* [use](https://github.com/rkh/rbenv-use) - **RVM-style** `use` command
* [whatis](https://github.com/rkh/rbenv-whatis) - **resolve abbreviations** to
  full Ruby identifiers (useful for other plugins)
* [aliases](https://github.com/tpope/rbenv-aliases) - **create aliases** for Ruby versions

RubyGems-related plugins:

* [gem-rehash](https://github.com/sstephenson/rbenv-gem-rehash) - **automatically run**
  `rbenv rehash` every time you install a new gem
* [default-gems](https://github.com/sstephenson/rbenv-default-gems) - **automatically
  install** specific gems after installing a new Ruby
* [communal-gems](https://github.com/tpope/rbenv-communal-gems) - **share gems** across multiple Ruby installs
* [user-gems](https://github.com/mislav/rbenv-user-gems) - **discover gems** installed under `~/.gem` or a custom `$GEM_HOME`
* [gemset](https://github.com/jf/rbenv-gemset) - basic **gemset support**


####Local Ruby versions for directories `--local-rubies`

Defines the ruby versions for specific directories/applications. Sets a `.ruby-version` file to the directory. So make
sure it's user writable. Local rubies are set through a combination of version and directory in the form of
`version@/path/to/directory`

Examples:

`--local-rubies 1.9.3-p484@/path/to/mylegacyapp` binds the directory `/path/to/mylegacyapp`
to Ruby version `1.9.3-p484`

`--local-rubies 1.9.3-p484@/path/to/mylegacyapp,2.1.0@/path/to/mybrandnewapp` binds the directory `/path/to/mylegacyapp`
to Ruby version `1.9.3-p484` and directory `/path/to/mybrandnewapp` to Ruby version `2.1.0`


####Globals Ruby version `--global-ruby`

Defines the globally used Ruby version. This version is used if no local or shell version is set by rbenv.

Example:

`--global-ruby 2.1.0` defines 2.1.0 as the system wide Ruby version.

### Example

Here is a full example for a bare server system.

~~~ sh
$ bash ./install.sh \
    --rubies 1.9.3-p484,2.1.0  \
    --global-ruby 2.1.0 \
    --local-rubies 1.9.3-p484@/path/to/mylegacyapp,2.1.0@/path/to/mybrandnewapp \
    --plugins sstephenson/rbenv-vars,rkh/rbenv-update
~~~

##Caveats

* **The installer is all beta. It doesn't do any crucial changes to your system but please be aware that it might need
some improvements. Drop me an [issue](https://github.com/martinsteinorth/getrbenv-installer/issues) if you run into
problems.**
* Currently the intent is to provide an installer for a bare system with no rbenv and or rubies installed at all.
The installer will be hardened in the future to work on already set up systems.


##Contribute

Fork it - If you are able to provide help making this installer better, drop me a pull request.

Test it - I'm glad if the script suits your needs. Please report any problems in the [issue tracker](https://github.com/martinsteinorth/getrbenv-installer/issues).

Share it - Spread the word if you like getrbenv :)


