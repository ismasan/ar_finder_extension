$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module ArFinderExtension
  VERSION = '0.0.1'
  
  class << self
    def enable_activerecord
      return if ActiveRecord::Base.respond_to? :has_custom_finder
      ActiveRecord::Base.extend ArFinderExtension::Macro
      a = ActiveRecord::Associations
      returning([ a::AssociationCollection ]) { |classes|
        # detect http://dev.rubyonrails.org/changeset/9230
        unless a::HasManyThroughAssociation.superclass == a::HasManyAssociation
          classes << a::HasManyThroughAssociation
        end
      }.each do |klass|
        klass.send :include, ArFinderExtension::Finder
        klass.alias_method_chain :find, :slug#class_eval { alias_method_chain :find, :slug }
      end
    end
  end
  
  
  module Macro
    
    def has_custom_finder
      # don't allow multiple calls
      return if self.included_modules.include?(ArFinderExtension::InstanceMethods)
      extend ArFinderExtension::Finder
      include ArFinderExtension::InstanceMethods
      
      class << self
        alias_method_chain :find, :slug
      end
    end
    
  end
  
  module Finder
    
    def find_with_slug(*args)
      puts @reflection.klass.inspect if @reflection
      key = args.first
      if key.is_a?(String) && !(key =~ /\A\d+\Z/)
        puts "custom finder called on #{self.name} with #{key.inspect}"
        with_scope(:find => { :conditions => ["title = ?", key] }) do
          find_without_slug(:first) or raise ActiveRecord::RecordNotFound.new("Nonnononono!")
        end
      else
        puts "normal finder called on #{self.name} with #{key.inspect}"
        find_without_slug(*args)
      end
    end
    
  end
  
  module InstanceMethods
    
  end
end


require 'rubygems'
require 'active_record'

ArFinderExtension.enable_activerecord