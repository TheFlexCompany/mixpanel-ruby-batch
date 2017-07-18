require File.join(File.dirname(__FILE__), 'lib/mixpanel-ruby-batch/version.rb')

spec = Gem::Specification.new do |spec|
  spec.name = 'mixpanel-ruby-batch'
  spec.version = MixpanelRubyBatch::VERSION
  spec.files = Dir.glob(`git ls-files`.split("\n"))
  spec.require_paths = ['lib']
  spec.summary = 'Simple batch interface for the official mixpanel-ruby gem'
  spec.description = 'Simple batch interface for the official mixpanel-ruby gem'
  spec.authors = [ 'Mark Wise' ]
  spec.email = 'markmediadude@gmail.com'
  spec.homepage = 'https://github.com/HealthTeacher/mixpanel-ruby-batch'
  spec.license = 'Apache License 2.0'
  spec.add_runtime_dependency 'mixpanel-ruby', '>= 1.7.0'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0.0'
  spec.add_development_dependency 'webmock', '~> 1.18.0'
end
