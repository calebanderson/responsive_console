require_relative 'lib/reactive_console/version'

Gem::Specification.new do |spec|
  spec.name        = 'reactive_console'
  spec.version     = ReactiveConsole::VERSION
  spec.authors     = ['calebanderson']
  spec.email       = ['caleb.r.anderson.1@gmail.com']
  spec.homepage    = 'https://github.com/calebanderson/reactive_console'
  spec.summary     = 'Formatters for displaying large objects in the console at any set width'
  spec.description = 'Formatters for displaying large objects in the console at any set width'
  spec.license     = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = 'TODO: Set to http://mygemserver.com'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/calebanderson/reactive_console'
  spec.metadata['changelog_uri'] = 'https://github.com/calebanderson/reactive_console/blob/master/CHANGELOG.md'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'rails', '~> 6.1.1'
end
