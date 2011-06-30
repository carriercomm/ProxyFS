
require "net/sftp"
require "config/logger"

module ProxyFS
  class ErrorHandler
    def initialize(mirror, task)
      @mirror = mirror
      @task = task
    end

    def handle(e)
      raise e
    rescue Timeout::Error
    rescue Net::SFTP::StatusException => e
      case e.code
        when Net::SFTP::Constants::StatusCodes::FX_NO_CONNECTION
        when Net::SFTP::Constants::StatusCodes::FX_CONNECTION_LOST
        else
          @task.block = true
      end
    rescue Errno::ECONNREFUSED
    rescue Errno::ECONNRESET
    rescue Errno::ENOTCONN
    rescue Errno::ECONNABORTED
    rescue Errno::EHOSTDOWN
    rescue Errno::EHOSTUNREACH
    rescue Errno::ENETDOWN
    rescue Exception
      @task.block = true
    ensure
      @task.save if @task.changed?

      if @task.block
        LOGGER.fatal "#{@mirror.hostname}: #{e}: manual fix required!"
      else
        LOGGER.error "#{@mirror.hostname}: #{e}"
      end

      loop do
        sleep 30

        @task.reload

        return unless @task.block
      end
    end
  end
end

