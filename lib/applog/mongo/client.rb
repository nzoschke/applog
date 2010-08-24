require 'json'
require 'restclient'
require 'thor'

module AppLog
  module Mongo
    class Client < Thor
      class_option :server, :type => :string, :aliases => "-s", :desc => "Default: http://localhost:9393/logs/"

      desc "tail [-f]", "Get the latest logs"
      method_option :follow, :type => :boolean, :aliases => '-f'
      def tail(since_oid=nil)
        params = {:oid => since_oid} if since_oid
        response = RestClient.get server, {:accept => :json, :params => params}
        logs = JSON.parse(response.body).reverse
        logs.each { |doc| log.write(doc.symbolize_keys) }

        if options["follow"]
          sleep(1)
          last_oid = logs.last[:_id]["$oid"] rescue since_oid
          tail(last_oid)
        end
      end

    private
      def log
        @log ||= AppLog::StdIO.new
      end

      def server
        options[:server] || 'http://localhost:9393/logs/'
      end
    end
  end
end