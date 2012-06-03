logger = Logger.new("log/mongodb-#{Rails.env}.log")
MongoMapper.connection = Mongo::Connection.new('localhost', 27017,
                                               :logger => logger)
MongoMapper.database = "api_pages-#{Rails.env}"

if defined?(PhusionPassenger)
   PhusionPassenger.on_event(:starting_worker_process) do |forked|
     MongoMapper.connection.connect if forked
   end
end
