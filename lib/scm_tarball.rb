require "capistrano/scm/plugin"

# By convention, Capistrano plugins are placed in the
# Capistrano namespace. This is completely optional.
module Capistrano
  class ScmTarballPlugin < ::Capistrano::SCM::Plugin

    def set_defaults
      # Define any variables needed to configure the plugin.
      set_if_empty :archive_path, "archive.tar.gz"
    end

    def define_tasks
      # The namespace can be whatever you want, but its best
      # to choose a name that matches your plugin name.
      namespace :tarball do
        task :set_current_revision do
          set :current_revision, ENV['REVISION']
        end

        task :create_release do
          # Your code to create the release directory and copy
          # the source code into it goes here.
          on release_roles :all do
            execute :mkdir, "-p", release_path
            upload! fetch(:archive_path), '/tmp'
            @archive_name = File.basename(fetch(:archive_path))
            execute :tar, "-xzf", "/tmp/#{@archive_name}", "-C", release_path
            execute :chmod, "u+w", "#{@release_path}/docroot/sites/default"
            execute :rm, "/tmp/#{@archive_name}"
          end
        end
      end
    end

    def register_hooks
      # Tell Capistrano to run the custom create_release task
      # during deploy.
      after "deploy:new_release_path", "tarball:create_release"
      before "deploy:set_current_revision", "tarball:set_current_revision"
    end

  end
end
