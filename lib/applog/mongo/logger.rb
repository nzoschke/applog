require 'mongo'

module AppLog
  module Mongo
    class Logger < AppLog::Logger
      MONGO_CONNECTION  = ::Mongo::Connection.from_uri(ENV['MONGO_URL'] || 'mongodb://127.0.0.1:27017') rescue nil
      MONGO_DBNAME      = MONGO_CONNECTION.auths.first['db_name'] rescue 'logs'
      MONGO             = MONGO_CONNECTION.db(MONGO_DBNAME) rescue nil

      attr_reader :db

      def initialize
        super(nil)
        @logdev = @db = MongoIO.new
      end

      class MongoIO
        include Logger::Severity

        def initialize
          # define MongoIO::debugs, ::warns, etc. as a filter to the mongo logs collection
          Logger::Severity.constants.each do |severity|
            (class << self; self; end).class_eval do
              define_method "#{severity.downcase}s" do |*args|
                find("severity" => severity)
              end
            end
          end
        end

        def find(query=nil)
          MONGO['logs'].find(query).sort(["$natural", ::Mongo::DESCENDING])
        end

        # IO interface
        def close ; end
        def write(doc)
          raise RuntimeError.new("MONGO_URL not set") if !MONGO
          MONGO['logs'].insert(doc)
        end

        def clear
          MONGO['logs'].drop
          MONGO.create_collection('logs', :strict => true, :capped => true, :size => 5000000, :max => 5000)
        end
      end
    end
  end
end