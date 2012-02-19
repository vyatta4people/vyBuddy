class Log < ActiveRecord::Base

  validates :created_date, :application, :event_source, :severity, :message, :presence => true

  validates :application,
    :length     => { :minimum => 2 }, 
    :format     => { :with => /^[a-z_]+$/, :message => "must contain only lowercase letters and underscores" }

  validates :severity,
    :inclusion  => { :in => LOG_SEVERITIES, :message => "\'%{value}\' is not a valid log severity" }

  before_update { |log| raise ActiveRecord::ReadOnlyRecord, "Log record(id: #{log.id.to_s}) should NOT be changed" }

  scope :sorted, order(["`created_at` ASC"])

  def get_severity_color
    return Log.get_severity_color(self.severity)
  end

  def html_severity
    return Log.html_severity(self.severity)
  end

  def html_message
    Log.html_message(self.severity, self.message)
  end

  def as_text
    sprintf("%-30s| %-20s| %-40s| %-10s| %s", !self.new_record? ? self.created_at.to_s(:eu) : Time.now.to_s(:eu), self.application, self.event_source, self.severity, self.message)
  end

  class << self
    attr_accessor :application
    attr_accessor :event_source
    attr_accessor :duplicate_to_stderr

    def get_severity_color(severity)
      case severity
        when "DEBUG"  then return "#999999"
        when "ERROR"  then return "#ff4444"
        when "FATAL"  then return "#ff0000"
        when "INFO"   then return "#3c9351"
        when "WARN"   then return "#ff8c00"
        else return "#8b008b"
      end
    end

    def html_severity(severity)
      "<span style=\"background-color:#{get_severity_color(severity)};color:#ffffff;font-weight:bold;\">&nbsp;#{severity}&nbsp;</span>"
    end
  
    def html_message(severity, message)
      "<span style=\"color:#{get_severity_color(severity)};\">#{message}</span>" 
    end

    def debug(message)
      write_log('DEBUG', message, true)
    end

    def error(message)
      write_log('ERROR', message)
    end

    def fatal(message)
      write_log('FATAL', message)
    end

    def info(message)
      write_log('INFO', message)
    end

    def warn(message)
      write_log('WARN', message)
    end

    def custom(message)
      write_log('CUSTOM', message, true)
    end

  private

    def write_log(severity, message, is_verbose = false)
      self.application  = :system if !self.application
      self.event_source = 'n/a'   if !self.event_source
      log = Log.create(:created_date => Time.now.to_date, :application => self.application.to_s, :event_source => self.event_source, :severity => severity, :is_verbose => is_verbose, :message => message)
      $stderr.puts(log.as_text) if self.duplicate_to_stderr
      $stderr.puts("Failed to save [previous] log message: #{log.errors.full_messages.join(', ')}") if log.new_record?
    end

  end

end
