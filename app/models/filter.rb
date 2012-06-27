class Filter < ActiveRecord::Base
  has_many :task_remote_commands
  has_many :tasks,    :through => :task_remote_commands
  has_many :filters,  :through => :task_remote_commands

  validates :name, :interpreter, :code, :presence => true
  
  validates :name, :uniqueness => true

  validates :interpreter,
    :inclusion  => { :in => INTERPRETERS, :message => "\'%{value}\' is not a valid script interpreter" }

  default_scope order(["`name` ASC"])

  before_update  { |filter| return false if filter.name == DEFAULT_FILTER_NAME }
  before_destroy { |filter| return false if filter.name == DEFAULT_FILTER_NAME }
  before_destroy { |filter| return false if filter.task_remote_commands.count > 0 }

  def apply(data)
    filter_script = Tempfile.new("vybuddy_filter")
    filter_script.chmod(0700)
    filter_script.write("#!#{self.interpreter}\n")
    filter_script.write(self.code)
    filter_script.close
    filtered_data = String.new
    IO.popen(filter_script.path, "w+") do |pipe|
      pipe.puts data
      pipe.close_write
      filtered_data = pipe.read.strip
    end
    filter_script.unlink
    return filtered_data
  end

end
