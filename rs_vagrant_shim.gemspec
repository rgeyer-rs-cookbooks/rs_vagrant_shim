Gem::Specification.new do |gem|
  gem.name = "rs_vagrant_shim"
  gem.version = "0.0.2"
  gem.homepage = "https://github.com/rgeyer-rs-cookbooks/rs_vagrant_shim"
  gem.license = "MIT"
  gem.summary = %Q{Allows RightScale ServerTemplate development to be performed primarily within Vagrant}
  gem.description = gem.summary
  gem.email = "ryan.geyer@rightscale.com"
  gem.authors = ["Ryan J. Geyer"]
  gem.executables << 'rs_vagrant_shim'

  # BEGIN: These dependencies are duplicated in lib/rs_vagrant_shim/cli, make sure they're
  # in sync
  gem.add_dependency('berkshelf', '~> 1.1')
  gem.add_dependency('vagrant', '~> 1.0.5')
  # END

  gem.add_dependency('thor', '~> 0.16.0')

  gem.files = Dir.glob("{lib,bin,locales}/**/*") + ["LICENSE.txt", "README.rdoc"]
end