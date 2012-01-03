class Filter < ActiveRecord::Base
  has_many :task_remote_commands, :dependent => :destroy

  def apply(outputs)
    filter_script = Tempfile.new("vybuddy_filter")
    filter_script.chmod(0700)
    filter_script.write("#!#{self.interpreter}\n")
    filter_script.write(self.code)
    filter_script.close
    harvest = String.new
    IO.popen(filter_script.path, "w+") do |pipe|
      outputs.each { |output| pipe.puts output[:data] }
      pipe.close_write
      harvest = pipe.read.strip
    end
    filter_script.unlink
    return harvest
  end

end
