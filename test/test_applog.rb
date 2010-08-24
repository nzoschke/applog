require 'helper'

class TestApplog < Test::Unit::TestCase
  def test_modules
    assert AppLog
    assert AppLog::Logger
    assert AppLog::StdIO::Logger
    assert AppLog::StdIO::Logger.new.is_a? AppLog::Logger
  end
end

class TestMongo < Test::Unit::TestCase
  def test_modules
    assert AppLog::Mongo::Logger
    assert AppLog::Mongo::Client
    assert AppLog::Mongo::Server
  end
end

class TestMultiIO < Test::Unit::TestCase
  def test_multi
    @log = AppLog::Logger.new(AppLog::Mongo::Logger.new, AppLog::StdIO::Logger.new)
    assert_equal AppLog::Mongo::Logger, @log.loggers[0].class
    assert_equal AppLog::StdIO::Logger, @log.loggers[1].class
  end
end