require_relative "lib/sessy/version"

Gem::Specification.new do |spec|
  spec.name        = "sessy"
  spec.version     = Sessy::VERSION
  spec.authors     = [ "Medulla" ]
  spec.email       = [ "engineering@medulla.ca" ]
  spec.homepage    = "https://github.com/medulla-app/sessy"
  spec.summary     = "Self-hosted Amazon SES email observability as a mountable Rails engine."
  spec.description = "Sessy ingests Amazon SES event notifications (deliveries, bounces, " \
    "complaints, opens, clicks) over SNS and gives you a dashboard to inspect them. " \
    "Packaged as an isolated, mountable Rails engine you drop into any Rails app."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/medulla-app/sessy"
  spec.metadata["changelog_uri"] = "https://github.com/medulla-app/sessy/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0"

  # Dashboard UI. CSS ships precompiled (app/assets/builds/sessy.css), so the
  # host needs no Tailwind toolchain at runtime — tailwindcss-rails is a dev
  # dependency for rebuilding it (see Gemfile).
  spec.add_dependency "propshaft"
  spec.add_dependency "importmap-rails"
  spec.add_dependency "turbo-rails"
  spec.add_dependency "stimulus-rails"
  spec.add_dependency "pagy"
  spec.add_dependency "local_time"

  # SES event ingestion over SNS (signature verification).
  spec.add_dependency "aws-sdk-sns"
end
