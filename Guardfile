# A sample Guardfile
# More info at https://github.com/guard/guard#readme
ignore /\/.#.+/

guard :rspec do
  watch(/^spec\/.+_spec\.rb$/)
  watch(/^lib\/(.+)\.rb$/)     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { 'spec' }
end

# guard 'spork', cucumber_env: { 'RAILS_ENV': 'test' }, rspec_env: { 'RAILS_ENV': 'test' } do
#   watch('config/application.rb')
#   watch('config/environment.rb')
#   watch('config/environments/test.rb')
#   watch(%r{^config/initializers/.+\.rb$})
#   watch('Gemfile.lock')
#   watch('spec/spec_helper.rb') { :rspec }
#   watch('test/test_helper.rb') { :test_unit }
#   watch(%r{features/support/}) { :cucumber }
# end
