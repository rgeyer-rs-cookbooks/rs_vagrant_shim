# Can't be sure that Chef will load the stuff in the libs dir in a consistent order
require ::File.expand_path(::File.join(::File.dirname(__FILE__), "helper"))

class Chef
  class Provider
    class RemoteRecipe < Chef::Provider

      include ::RsVagrantShim::Helper

      def load_current_resource
        true
      end

      def action_run
        tags = @new_resource.recipients_tags
        recipients = @new_resource.recipients
        scope = @new_resource.scope
        payload = {
          :remote_recipe => {
            :tags => tags,
            :from => node['rightscale']['instance_uuid']
          },
          :run_list => "recipe[#{@new_resource.recipe}]"
        }.merge(@new_resource.attributes)

        target_files = []
        timestamp = Time.now.to_i

        if tags && !tags.empty?
          other_vm_shim_dirs(node).each do |shim_dir|
            break if scope == :single && target_files.length > 0
            persist_file = ::File.join(shim_dir, "persist.json")
            persist_hash = read_persist_file(persist_file)
            if persist_hash.key?("tags") && (persist_hash["tags"] & tags) == tags
              target_files << ::File.join(shim_dir, "dispatch", "#{timestamp}.json")
              Chef::Log.info("Scheduled the execution of #{@new_resource.recipe} on Vagrant VM with rs_vagrant_shim dir of #{shim_dir}.  Please run vagrant provision on that VM to execute this remote recipe")
            end
          end
        end

        if recipients && !recipients.empty?
          recipients_tags = recipients.map{|r| "server:uuid=#{r}" }
          puts recipients_tags
          other_vm_shim_dirs(node).each do |shim_dir|
            persist_file = ::File.join(shim_dir, "persist.json")
            persist_hash = read_persist_file(persist_file)
            if persist_hash.key?("tags") && (persist_hash["tags"] & recipients_tags).length > 0
              target_files << ::File.join(shim_dir, "dispatch", "#{timestamp}.json")
              Chef::Log.info("Scheduled the execution of #{@new_resource.recipe} on Vagrant VM with rs_vagrant_shim dir of #{shim_dir}.  Please run vagrant provision on that VM to execute this remote recipe")
            end
          end
        end

        target_files.each do |target_file|
          ::File.open(target_file, "w") do |file|
            file.write(JSON.pretty_generate(payload))
          end
        end
      end
    end
  end
end

Chef::Platform.platforms[:default].merge!(:remote_recipe => Chef::Provider::RemoteRecipe)