require 'sinatra'
require 'json'

module AppLog
  module Mongo
    class Server < Sinatra::Base
      configure do
        @@log = AppLog::Mongo::Logger.new
      end

      before do
        content_type :json
      end

      get '/' do
        query = {"_id" => {"$gt" => ::BSON::ObjectID(params[:oid]) }} if params[:oid]
        return @@log.db.find(query).limit(100).to_a.to_json
      end
    end
  end
end