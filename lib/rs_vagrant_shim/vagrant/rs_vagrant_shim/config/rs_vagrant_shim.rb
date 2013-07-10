# Copyright (c) 2013 Ryan J. Geyer
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module VagrantPlugins
  module RsVagrantShim
    class Config < ::VagrantPlugins::Chef::Config::ChefSolo
      attr_accessor :shim_dir
      attr_accessor :run_list_dir
      attr_reader :one_time_runlist_file

      # TODO: Better error handling, verify shim dir and runlist dir exist, catch json errors when parsing runlists
      def validate(env, errors)

        errors.add(I18n.t("vagrant.config.rs_vagrant_shim.shim_dir_missing")) if !@shim_dir || @shim_dir.empty?
        errors.add(I18n.t("vagrant.config.rs_vagrant_shim.run_list_dir_missing")) if !@run_list_dir || @run_list_dir.empty?

        if @shim_dir && !@shim_dir.empty? && @run_list_dir && !@run_list_dir.empty?
          node_js_file = File.join(Dir.pwd, @shim_dir, 'node.js')
          dispatch_dir = File.join(Dir.pwd, @shim_dir, 'dispatch')
          FileUtils.mkdir_p dispatch_dir unless File.directory? dispatch_dir

          dispatch_files = Dir.entries(dispatch_dir).reject{|f| /^\.+/ =~ f}.sort_by{|f| File.mtime(File.join(dispatch_dir, f))}

          runlist = JSON.parse(File.read(File.join(Dir.pwd, @run_list_dir, 'default.json')))

          if File.exist? node_js_file
            runlist.merge! JSON.parse(File.read(node_js_file))["normal"]
          end

          # A specified runlist trumps all, but still inherits from default
          if ENV['runlist']
            runlist_file = File.join(Dir.pwd, @run_list_dir, "#{ENV['runlist']}.json")
            runlist.merge!(JSON.parse(File.read(runlist_file))) if File.exist? runlist_file
          elsif dispatch_files.length > 0
            dispatch_file = File.join(dispatch_dir, dispatch_files.first)
            runlist.merge!(JSON.parse(File.read(dispatch_file)))
            @one_time_runlist_file = dispatch_file
          end

          @json = {:rs_vagrant_shim => to_hash}.merge(runlist)
          @run_list = runlist['run_list']
        end

        super(env, errors)
      end

    end
  end
end