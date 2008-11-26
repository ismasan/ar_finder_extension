database_config = {
  :adapter=>'sqlite3',
  :dbfile=> File.join(File.dirname(__FILE__),'..','spec','db','test.db')
}

ActiveRecord::Base.establish_connection(database_config)
# define a migration
class TestSchema < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :title
      t.timestamps
    end
    
    create_table :comments do |t|
      t.text :title
      t.integer :post_id
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
    drop_table :comments
  end
end


namespace :db do
  desc "migrate test schema"
  task :create do
    File.unlink(database_config[:dbfile]) if File.exists?(database_config[:dbfile])
    ActiveRecord::Base.connection # this creates the DB
    # run the migration
    TestSchema.migrate(:up)
  end
  
  desc "Destroy test schema"
  task :destroy do
    TestSchema.migrate(:down)
  end
end