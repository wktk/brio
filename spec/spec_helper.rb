require 'brio'
require 'rspec'
# require 'timecop'
require 'webmock/rspec'
require 'json'
require 'yaml'
require 'fileutils'


RSpec.configure do |config|
  config.before(:all) do
    @old_home = ENV['HOME']
    ENV['HOME'] = tmp_dir
  end

  config.after(:all) do
    ENV['HOME'] = @old_home
    delete_test_rc_file
  end

end


def create_test_rc_file
  Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)
  FileUtils.cp fixture("brio.rc"), test_rc_file
end

def delete_test_rc_file
  File.delete(test_rc_file) if File.exist?(test_rc_file)
end

def project_path
  File.expand_path("../..", __FILE__)
end

def test_rc_file
  tmp_dir + "/.brio.rc"
end

def tmp_dir
  project_path + "/tmp" 
end

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end

def fixture_as_json(file)
  JSON.parse(fixture(file).read)
end

def fixture_as_yaml(file)
  YAML.load_file( fixture(file) )
end


def stub_oauth_url
  stub_request(:get, "https://alpha.app.net/oauth/authenticate")
end

def stub_get(path, endpoint="https://alpha-api.app.net")
  stub_request(:get, endpoint + path)
end

def stub_post(path, endpoint="https://alpha-api.app.net")
  stub_request(:post, endpoint + path)
end

def stub_delete(path, endpoint="https://alpha-api.app.net")
  stub_request(:delete, endpoint + path)
end

def a_get(path, endpoint="https://alpha-api.app.net")
  a_request(:get, endpoint + path)
end

def a_post(path, endpoint="https://alpha-api.app.net")
  a_request(:post, endpoint + path)
end

def a_delete(path, endpoint="https://alpha-api.app.net")
  a_request(:delete, endpoint + path)
end


