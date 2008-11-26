begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'ar_finder_extension'

ActiveRecord::Base.establish_connection(
  :adapter=>'sqlite3',
  :dbfile=> File.join(File.dirname(__FILE__),'db','test.db')
)

#ActiveRecord::Base.connection.query_cache_enabled = false

LOGGER = Logger.new(File.dirname(__FILE__)+'/log/test.log')
ActiveRecord::Base.logger = LOGGER

class Comment < ActiveRecord::Base
  
  has_custom_finder
  
  belongs_to :post
  
  named_scope :recent, lambda{|limit|
    {:order => 'created_at desc',:limit => limit}
  }
  
  named_scope :desc, :order => 'publish_at desc'
  
end

class Post < ActiveRecord::Base
  
  has_custom_finder
  
  has_many :comments, :dependent => :destroy
  
end